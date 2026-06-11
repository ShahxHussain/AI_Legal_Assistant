import json
from contextlib import asynccontextmanager

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field

from config import settings
from rag.document_parser import extract_document_text
from rag.embedder import Embedder
from rag.generator import Generator
from rag.language import (
    DEFAULT_LANGUAGE,
    SUPPORTED_LANGUAGES,
    detect_response_language,
)
from rag.output_guard import sanitize_llm_output
from rag.query_intent import is_conversational_query, is_legal_query
from rag.retriever import Retriever


def _language_override(value: str) -> str:
    """Resolve the requested response language; fall back to Urdu."""
    lang = (value or "").strip().lower()
    if lang in SUPPORTED_LANGUAGES:
        return lang
    return DEFAULT_LANGUAGE

embedder: Embedder | None = None
retriever: Retriever | None = None
generator: Generator | None = None
index_load_error: str | None = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global embedder, retriever, generator, index_load_error

    embedder = Embedder()
    retriever = Retriever(embedder)
    generator = Generator()

    try:
        retriever.load()
        index_load_error = None
    except FileNotFoundError as exc:
        index_load_error = str(exc)

    yield


app = FastAPI(
    title="Court Companion API",
    description="Court Companion | AI Legal Bilingual Assistant — RAG-backed legal information for Pakistan",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class AskRequest(BaseModel):
    question: str = Field(..., min_length=1, max_length=2000)
    language: str = Field(default=DEFAULT_LANGUAGE, max_length=20)


class SourceItem(BaseModel):
    document: str
    section: str = ""
    title: str = ""
    excerpt: str
    text: str


class AskResponse(BaseModel):
    answer: str
    sources: list[SourceItem]
    disclaimer: str
    document_name: str | None = None
    document_truncated: bool = False


class HealthResponse(BaseModel):
    status: str
    index_loaded: bool
    chunk_count: int
    llm_configured: bool
    index_error: str | None = None


def _ensure_llm_ready() -> None:
    if generator is None or not generator.is_configured:
        raise HTTPException(
            status_code=503,
            detail="TOGETHER_API_KEY is not configured on the server",
        )


@app.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    loaded = retriever is not None and retriever.is_loaded
    return HealthResponse(
        status="ok",
        index_loaded=loaded,
        chunk_count=retriever.chunk_count if loaded and retriever else 0,
        llm_configured=settings.llm_configured,
        index_error=index_load_error,
    )


@app.post("/ask", response_model=AskResponse)
def ask(body: AskRequest) -> AskResponse:
    question = body.question.strip()
    if not question:
        raise HTTPException(status_code=400, detail="Question cannot be empty")

    if retriever is None or not retriever.is_loaded:
        raise HTTPException(
            status_code=503,
            detail=index_load_error or "Search index is not loaded",
        )

    _ensure_llm_ready()
    lang = _language_override(body.language)

    if is_conversational_query(question):
        answer = generator.generate_conversational(question, language=lang)
        return AskResponse(
            answer=answer,
            sources=[],
            disclaimer=settings.disclaimer,
        )

    # The FAISS index is English-only; translate non-English queries first
    # so retrieval can find the right PPC/CrPC sections.
    search_query = question
    if detect_response_language(question) != "english":
        search_query = generator.translate_query(question)

    chunks = retriever.retrieve(search_query)
    if not chunks:
        raise HTTPException(
            status_code=503,
            detail="No relevant legal sources found for this question",
        )

    answer = generator.generate(question, chunks, language=lang)
    cited = [c for c in chunks if c.score >= settings.source_min_score]
    sources = [SourceItem(**c.to_source_dict()) for c in cited]

    return AskResponse(
        answer=answer,
        sources=sources,
        disclaimer=settings.disclaimer,
    )


def _ndjson(obj: dict) -> str:
    return json.dumps(obj, ensure_ascii=False) + "\n"


@app.post("/ask/stream")
def ask_stream(body: AskRequest) -> StreamingResponse:
    """
    Streaming version of /ask (NDJSON). Event order:
      {"type": "meta", "sources": [...], "disclaimer": "..."}
      {"type": "delta", "text": "..."}   (repeated)
      {"type": "done", "answer": "<full sanitized answer>"}
    On failure: {"type": "error", "detail": "..."}
    """
    question = body.question.strip()
    if not question:
        raise HTTPException(status_code=400, detail="Question cannot be empty")

    if retriever is None or not retriever.is_loaded:
        raise HTTPException(
            status_code=503,
            detail=index_load_error or "Search index is not loaded",
        )

    _ensure_llm_ready()
    lang = _language_override(body.language)

    def event_stream():
        try:
            if is_conversational_query(question):
                yield _ndjson(
                    {
                        "type": "meta",
                        "sources": [],
                        "disclaimer": settings.disclaimer,
                    }
                )
                parts: list[str] = []
                for delta in generator.generate_conversational_stream(
                    question, language=lang
                ):
                    parts.append(delta)
                    yield _ndjson({"type": "delta", "text": delta})
                yield _ndjson(
                    {"type": "done", "answer": sanitize_llm_output("".join(parts))}
                )
                return

            search_query = question
            if detect_response_language(question) != "english":
                search_query = generator.translate_query(question)

            chunks = retriever.retrieve(search_query)
            if not chunks:
                yield _ndjson(
                    {
                        "type": "error",
                        "detail": "No relevant legal sources found for this question",
                    }
                )
                return

            cited = [c for c in chunks if c.score >= settings.source_min_score]
            yield _ndjson(
                {
                    "type": "meta",
                    "sources": [c.to_source_dict() for c in cited],
                    "disclaimer": settings.disclaimer,
                }
            )

            parts = []
            for delta in generator.generate_stream(question, chunks, language=lang):
                parts.append(delta)
                yield _ndjson({"type": "delta", "text": delta})
            yield _ndjson(
                {"type": "done", "answer": sanitize_llm_output("".join(parts))}
            )
        except Exception as exc:  # surface mid-stream failures to the client
            yield _ndjson({"type": "error", "detail": str(exc)})

    return StreamingResponse(
        event_stream(),
        media_type="application/x-ndjson",
        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
    )


@app.post("/analyze-document", response_model=AskResponse)
async def analyze_document(
    file: UploadFile = File(...),
    question: str = Form(default=""),
    language: str = Form(default=DEFAULT_LANGUAGE),
) -> AskResponse:
    """
    Upload a PDF or TXT document for legal information analysis.
    Optional `question` — if omitted, returns a general document summary.
    """
    _ensure_llm_ready()

    if not file.filename:
        raise HTTPException(status_code=400, detail="Filename is required")

    raw = await file.read()
    try:
        doc_text, truncated = extract_document_text(raw, file.filename)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    q = question.strip()
    rag_chunks = []
    if (
        q
        and is_legal_query(q)
        and retriever is not None
        and retriever.is_loaded
    ):
        search_q = q
        if detect_response_language(q) != "english":
            search_q = generator.translate_query(q)
        retrieved = retriever.retrieve(search_q)
        rag_chunks = [c for c in retrieved if c.score >= settings.source_min_score]

    answer = generator.generate_document_analysis(
        document_text=doc_text,
        filename=file.filename,
        question=q or None,
        rag_chunks=rag_chunks or None,
        language=_language_override(language),
    )

    preview = doc_text[:280].strip()
    if len(doc_text) > 280:
        preview += "..."

    sources: list[SourceItem] = [
        SourceItem(
            document=file.filename,
            section="",
            title="Uploaded document",
            excerpt=preview,
            text=doc_text,
        )
    ]
    for chunk in rag_chunks:
        sources.append(SourceItem(**chunk.to_source_dict()))

    return AskResponse(
        answer=answer,
        sources=sources,
        disclaimer=settings.disclaimer,
        document_name=file.filename,
        document_truncated=truncated,
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host=settings.host, port=settings.port, reload=True)
