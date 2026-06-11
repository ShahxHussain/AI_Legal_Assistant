from contextlib import asynccontextmanager

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from config import settings
from rag.document_parser import extract_document_text
from rag.embedder import Embedder
from rag.generator import Generator
from rag.query_intent import is_conversational_query, is_legal_query
from rag.retriever import Retriever

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

    if is_conversational_query(question):
        answer = generator.generate_conversational(question)
        return AskResponse(
            answer=answer,
            sources=[],
            disclaimer=settings.disclaimer,
        )

    chunks = retriever.retrieve(question)
    if not chunks:
        raise HTTPException(
            status_code=503,
            detail="No relevant legal sources found for this question",
        )

    answer = generator.generate(question, chunks)
    cited = [c for c in chunks if c.score >= settings.source_min_score]
    sources = [SourceItem(**c.to_source_dict()) for c in cited]

    return AskResponse(
        answer=answer,
        sources=sources,
        disclaimer=settings.disclaimer,
    )


@app.post("/analyze-document", response_model=AskResponse)
async def analyze_document(
    file: UploadFile = File(...),
    question: str = Form(default=""),
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
        retrieved = retriever.retrieve(q)
        rag_chunks = [c for c in retrieved if c.score >= settings.source_min_score]

    answer = generator.generate_document_analysis(
        document_text=doc_text,
        filename=file.filename,
        question=q or None,
        rag_chunks=rag_chunks or None,
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
