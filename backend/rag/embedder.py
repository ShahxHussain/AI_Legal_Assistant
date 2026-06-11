import threading

from sentence_transformers import SentenceTransformer

from config import settings


class Embedder:
    """Lazy-loads the embedding model on first use to keep startup RAM low."""

    def __init__(self) -> None:
        self._model: SentenceTransformer | None = None
        self._lock = threading.Lock()

    @property
    def is_loaded(self) -> bool:
        return self._model is not None

    def _ensure_model(self) -> SentenceTransformer:
        if self._model is not None:
            return self._model
        with self._lock:
            if self._model is None:
                self._model = SentenceTransformer(settings.embedding_model)
            return self._model

    def embed_texts(self, texts: list[str]) -> list[list[float]]:
        vectors = self._ensure_model().encode(texts, show_progress_bar=False)
        return vectors.tolist()

    def embed_query(self, query: str) -> list[float]:
        vector = self._ensure_model().encode([query], show_progress_bar=False)
        return vector[0].tolist()
