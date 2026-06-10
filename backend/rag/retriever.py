import json
from dataclasses import dataclass

import faiss
import numpy as np

from config import settings
from rag.embedder import Embedder


@dataclass
class RetrievedChunk:
    document: str
    section: str
    text: str
    score: float

    def to_source_dict(self) -> dict:
        excerpt = self.text[:300] + ("..." if len(self.text) > 300 else "")
        return {
            "document": self.document,
            "section": self.section,
            "excerpt": excerpt,
        }


class Retriever:
    def __init__(self, embedder: Embedder) -> None:
        self.embedder = embedder
        self.index: faiss.Index | None = None
        self.chunks: list[dict] = []

    @property
    def is_loaded(self) -> bool:
        return self.index is not None and len(self.chunks) > 0

    @property
    def chunk_count(self) -> int:
        return len(self.chunks)

    def load(self) -> None:
        faiss_path = settings.index_faiss_path
        chunks_path = settings.chunks_json_path

        if not faiss_path.exists() or not chunks_path.exists():
            raise FileNotFoundError(
                f"Index not found. Run: python scripts/build_index.py "
                f"(expected {faiss_path})"
            )

        self.index = faiss.read_index(str(faiss_path))
        with chunks_path.open(encoding="utf-8") as f:
            self.chunks = json.load(f)

    def retrieve(self, query: str, top_k: int | None = None) -> list[RetrievedChunk]:
        if not self.is_loaded:
            raise RuntimeError("Retriever index is not loaded")

        k = top_k or settings.top_k
        query_vector = np.array([self.embedder.embed_query(query)], dtype=np.float32)
        faiss.normalize_L2(query_vector)

        scores, indices = self.index.search(query_vector, k)
        results: list[RetrievedChunk] = []

        for score, idx in zip(scores[0], indices[0]):
            if idx < 0 or idx >= len(self.chunks):
                continue
            chunk = self.chunks[idx]
            results.append(
                RetrievedChunk(
                    document=chunk.get("document", "unknown"),
                    section=chunk.get("section", ""),
                    text=chunk.get("text", ""),
                    score=float(score),
                )
            )

        return results
