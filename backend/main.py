import json
from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field

from config import settings
from conversations.helpers import (
    build_search_query,
    history_for_llm,
    resolve_conversation,
)
from conversations.store import ConversationStore
from db.supabase_client import ping_supabase
from admin.auth import require_admin
from admin.stats import AdminStatsService
from analytics.events import UsageEventStore
from analytics.topics import detect_topics
from feedback.store import FeedbackStore
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
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)


class AskRequest(BaseModel):
    question: str = Field(..., min_length=1, max_length=2000)
    language: str = Field(default=DEFAULT_LANGUAGE, max_length=20)
    voice_mode: bool = False
    device_id: str | None = Field(default=None, max_length=128)
    conversation_id: str | None = Field(default=None, max_length=64)


class CreateConversationRequest(BaseModel):
    device_id: str = Field(..., min_length=8, max_length=128)
    language: str = Field(default=DEFAULT_LANGUAGE, max_length=20)


class ConversationItem(BaseModel):
    id: str
    device_id: str
    language: str
    status: str
    created_at: str | None = None
    updated_at: str | None = None


class MessageItem(BaseModel):
    id: str
    role: str
    content: str
    phase: str | None = None
    sources: list = Field(default_factory=list)
    created_at: str | None = None


class ConversationDetailResponse(BaseModel):
    conversation: ConversationItem
    messages: list[MessageItem]


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
    db_configured: bool = False
    db_connected: bool = False
    db_error: str | None = None
    admin_configured: bool = False


class FeedbackRequest(BaseModel):
    message_id: str = Field(..., min_length=8, max_length=64)
    device_id: str = Field(..., min_length=8, max_length=128)
    rating: str = Field(..., pattern="^(up|down)$")
    conversation_id: str | None = Field(default=None, max_length=64)
    comment: str | None = Field(default=None, max_length=200)
    language: str | None = Field(default=None, max_length=20)
    topics: list[str] = Field(default_factory=list)
    channel: str = Field(default="chat", pattern="^(chat|voice)$")


def _ensure_llm_ready() -> None:
    if generator is None or not generator.is_configured:
        raise HTTPException(
            status_code=503,
            detail="TOGETHER_API_KEY is not configured on the server",
        )


@app.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    loaded = retriever is not None and retriever.is_loaded
    db_configured = settings.supabase_configured
    db_connected = False
    db_error: str | None = None
    if db_configured:
        db_connected, db_error = ping_supabase()
    return HealthResponse(
        status="ok",
        index_loaded=loaded,
        chunk_count=retriever.chunk_count if loaded and retriever else 0,
        llm_configured=settings.llm_configured,
        index_error=index_load_error,
        db_configured=db_configured,
        db_connected=db_connected,
        db_error=db_error,
        admin_configured=bool((settings.admin_api_key or "").strip()),
    )


def _require_db() -> ConversationStore:
    if not settings.supabase_configured:
        raise HTTPException(status_code=503, detail="Database is not configured")
    return ConversationStore()


def _log_usage_event(
    event_type: str,
    device_id: str | None,
    *,
    conversation_id: str | None = None,
    language: str | None = None,
    topics: list[str] | None = None,
    metadata: dict | None = None,
) -> None:
    if not settings.supabase_configured or not (device_id or "").strip():
        return
    try:
        UsageEventStore().log_event(
            event_type,
            device_id.strip(),
            conversation_id=conversation_id,
            language=language,
            topics=topics,
            metadata=metadata,
        )
    except Exception:
        pass


@app.post("/feedback", status_code=204)
def submit_feedback(body: FeedbackRequest) -> None:
    if not settings.supabase_configured:
        raise HTTPException(status_code=503, detail="Database is not configured")
    topics = body.topics if body.topics else []
    FeedbackStore().upsert_feedback(
        message_id=body.message_id,
        device_id=body.device_id.strip(),
        rating=body.rating,
        conversation_id=body.conversation_id,
        comment=body.comment,
        language=body.language,
        topics=topics,
        channel=body.channel,
    )
    _log_usage_event(
        "feedback_given",
        body.device_id,
        conversation_id=body.conversation_id,
        language=body.language,
        topics=topics,
        metadata={"rating": body.rating, "message_id": body.message_id},
    )


@app.get("/admin/stats/overview")
def admin_stats_overview(
    days: int = 7,
    _: None = Depends(require_admin),
) -> dict:
    if not settings.supabase_configured:
        raise HTTPException(status_code=503, detail="Database is not configured")
    return AdminStatsService().overview(days=max(1, min(days, 90)))


@app.get("/admin/stats/questions-per-day")
def admin_questions_per_day(
    days: int = 30,
    _: None = Depends(require_admin),
) -> list[dict]:
    if not settings.supabase_configured:
        raise HTTPException(status_code=503, detail="Database is not configured")
    return AdminStatsService().questions_per_day(days=max(1, min(days, 90)))


@app.get("/admin/stats/languages")
def admin_language_stats(
    days: int = 30,
    _: None = Depends(require_admin),
) -> list[dict]:
    if not settings.supabase_configured:
        raise HTTPException(status_code=503, detail="Database is not configured")
    return AdminStatsService().language_breakdown(days=max(1, min(days, 90)))


@app.get("/admin/stats/topics")
def admin_topic_stats(
    days: int = 30,
    _: None = Depends(require_admin),
) -> list[dict]:
    if not settings.supabase_configured:
        raise HTTPException(status_code=503, detail="Database is not configured")
    return AdminStatsService().topic_breakdown(days=max(1, min(days, 90)))


@app.get("/admin/feedback/recent")
def admin_recent_feedback(
    limit: int = 50,
    _: None = Depends(require_admin),
) -> list[dict]:
    if not settings.supabase_configured:
        raise HTTPException(status_code=503, detail="Database is not configured")
    return AdminStatsService().recent_feedback(limit=max(1, min(limit, 200)))


@app.post("/conversations", response_model=ConversationItem)
def create_conversation(body: CreateConversationRequest) -> ConversationItem:
    row = _require_db().create_conversation(body.device_id.strip(), _language_override(body.language))
    return ConversationItem(**row)


@app.get("/conversations", response_model=list[ConversationItem])
def list_conversations(device_id: str) -> list[ConversationItem]:
    if not (device_id or "").strip():
        raise HTTPException(status_code=400, detail="device_id is required")
    if not settings.supabase_configured:
        return []
    rows = _require_db().list_conversations(device_id.strip())
    return [ConversationItem(**r) for r in rows]


@app.get("/conversations/{conversation_id}", response_model=ConversationDetailResponse)
def get_conversation(conversation_id: str, device_id: str) -> ConversationDetailResponse:
    if not (device_id or "").strip():
        raise HTTPException(status_code=400, detail="device_id is required")
    store = _require_db()
    conv = store.get_conversation(conversation_id, device_id.strip())
    if conv is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    messages = store.get_messages(conversation_id, device_id.strip(), limit=100)
    return ConversationDetailResponse(
        conversation=ConversationItem(**conv),
        messages=[MessageItem(**m) for m in messages],
    )


@app.delete("/conversations/{conversation_id}")
def delete_conversation(conversation_id: str, device_id: str) -> dict:
    if not (device_id or "").strip():
        raise HTTPException(status_code=400, detail="device_id is required")
    store = _require_db()
    if not store.delete_conversation(conversation_id, device_id.strip()):
        raise HTTPException(status_code=404, detail="Conversation not found")
    return {"ok": True}


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
        answer = generator.generate_conversational(
            question, language=lang, voice_mode=body.voice_mode
        )
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

    answer = generator.generate(
        question, chunks, language=lang, voice_mode=body.voice_mode
    )
    cited = [c for c in chunks if c.score >= settings.source_min_score]
    sources = [SourceItem(**c.to_source_dict()) for c in cited]

    return AskResponse(
        answer=answer,
        sources=sources,
        disclaimer=settings.disclaimer,
    )


def _ndjson(obj: dict) -> str:
    return json.dumps(obj, ensure_ascii=False) + "\n"


def _begin_turn(
    body: AskRequest, question: str, lang: str
) -> tuple[str | None, ConversationStore | None, list[dict[str, str]], dict | None, list]:
    cid, prior, store = resolve_conversation(
        body.device_id, lang, body.conversation_id
    )
    llm_history = history_for_llm(prior)
    user_row = None
    if store and cid and body.device_id:
        user_row = store.append_message(
            cid,
            body.device_id.strip(),
            role="user",
            content=question,
        )
        _log_usage_event(
            "question_asked",
            body.device_id,
            conversation_id=cid,
            language=lang,
            topics=detect_topics(question),
            metadata={
                "channel": "voice" if body.voice_mode else "chat",
                "word_count": len(question.split()),
            },
        )
    return cid, store, llm_history, user_row, prior


def _meta_payload(
  cid: str | None,
  user_row: dict | None,
  *,
  sources: list,
  disclaimer: str,
  phase: str = "answering",
) -> dict:
    payload = {
        "type": "meta",
        "sources": sources,
        "disclaimer": disclaimer,
        "phase": phase,
    }
    if cid:
        payload["conversation_id"] = cid
    if user_row:
        payload["user_message_id"] = user_row.get("id")
    return payload


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
            cid, store, llm_history, user_row, prior_rows = _begin_turn(
                body, question, lang
            )

            if is_conversational_query(question):
                yield _ndjson(
                    _meta_payload(
                        cid,
                        user_row,
                        sources=[],
                        disclaimer=settings.disclaimer,
                        phase="conversational",
                    )
                )
                parts: list[str] = []
                for delta in generator.generate_conversational_stream(
                    question,
                    language=lang,
                    voice_mode=body.voice_mode,
                    history=llm_history,
                ):
                    parts.append(delta)
                    yield _ndjson({"type": "delta", "text": delta})
                answer = sanitize_llm_output("".join(parts))
                assistant_row = None
                if store and cid and body.device_id:
                    assistant_row = store.append_message(
                        cid,
                        body.device_id.strip(),
                        role="assistant",
                        content=answer,
                        phase="conversational",
                    )
                done = {"type": "done", "answer": answer}
                if cid:
                    done["conversation_id"] = cid
                if assistant_row:
                    done["assistant_message_id"] = assistant_row.get("id")
                _log_usage_event(
                    "answer_completed",
                    body.device_id,
                    conversation_id=cid,
                    language=lang,
                    metadata={
                        "channel": "voice" if body.voice_mode else "chat",
                        "phase": "conversational",
                    },
                )
                yield _ndjson(done)
                return

            search_query = build_search_query(question, prior_rows or [])
            if detect_response_language(search_query) != "english":
                search_query = generator.translate_query(search_query)

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
            source_dicts = [c.to_source_dict() for c in cited]
            yield _ndjson(
                _meta_payload(
                    cid,
                    user_row,
                    sources=source_dicts,
                    disclaimer=settings.disclaimer,
                )
            )

            parts = []
            for delta in generator.generate_stream(
                question,
                chunks,
                language=lang,
                voice_mode=body.voice_mode,
                history=llm_history,
            ):
                parts.append(delta)
                yield _ndjson({"type": "delta", "text": delta})
            answer = sanitize_llm_output("".join(parts))
            assistant_row = None
            if store and cid and body.device_id:
                assistant_row = store.append_message(
                    cid,
                    body.device_id.strip(),
                    role="assistant",
                    content=answer,
                    phase="answering",
                    sources=source_dicts,
                )
            done = {"type": "done", "answer": answer}
            if cid:
                done["conversation_id"] = cid
            if assistant_row:
                done["assistant_message_id"] = assistant_row.get("id")
            _log_usage_event(
                "answer_completed",
                body.device_id,
                conversation_id=cid,
                language=lang,
                topics=detect_topics(question),
                metadata={
                    "channel": "voice" if body.voice_mode else "chat",
                    "source_count": len(source_dicts),
                    "phase": "answering",
                },
            )
            yield _ndjson(done)
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
