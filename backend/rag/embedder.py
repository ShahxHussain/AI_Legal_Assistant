from sentence_transformers import SentenceTransformer

from config import settings


class Embedder:
    def __init__(self) -> None:
        self.model = SentenceTransformer(settings.embedding_model)

    def embed_texts(self, texts: list[str]) -> list[list[float]]:
        vectors = self.model.encode(texts, show_progress_bar=False)
        return vectors.tolist()

    def embed_query(self, query: str) -> list[float]:
        vector = self.model.encode([query], show_progress_bar=False)
        return vector[0].tolist()
