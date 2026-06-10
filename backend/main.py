from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from config import settings
from rag.embedder import Embedder
from rag.generator import Generator
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
    section: str
    excerpt: str


class AskResponse(BaseModel):
    answer: str
    sources: list[SourceItem]
    disclaimer: str


class HealthResponse(BaseModel):
    status: str
    index_loaded: bool
    chunk_count: int
    llm_configured: bool
    index_error: str | None = None


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

    if generator is None or not generator.is_configured:
        raise HTTPException(
            status_code=503,
            detail="TOGETHER_API_KEY is not configured on the server",
        )

    chunks = retriever.retrieve(question)
    if not chunks:
        raise HTTPException(
            status_code=503,
            detail="No relevant legal sources found for this question",
        )

    answer = generator.generate(question, chunks)
    sources = [SourceItem(**c.to_source_dict()) for c in chunks]

    return AskResponse(
        answer=answer,
        sources=sources,
        disclaimer=settings.disclaimer,
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host=settings.host, port=settings.port, reload=True)
