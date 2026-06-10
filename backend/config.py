from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

BACKEND_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = BACKEND_DIR.parent


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=BACKEND_DIR / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    together_api_key: str = ""
    llm_model: str = "meta-llama/Meta-Llama-3-8B-Instruct-Lite"
    embedding_model: str = "all-MiniLM-L6-v2"
    top_k: int = 5
    chunk_size_words: int = 600
    chunk_overlap_words: int = 75
    data_dir: Path = PROJECT_ROOT / "data"
    index_dir: Path = BACKEND_DIR / "rag" / "index"
    host: str = "0.0.0.0"
    port: int = 8000

    assistant_name: str = "Court Companion | AI Legal Bilingual Assistant"
    disclaimer: str = (
        "Yeh sirf general legal maloomat hai, legal advice nahi. "
        "This is informational guidance only, not legal advice. "
        "Serious cases ke liye qualified lawyer se mashwara karein."
    )

    @property
    def index_faiss_path(self) -> Path:
        return self.index_dir / "index.faiss"

    @property
    def chunks_json_path(self) -> Path:
        return self.index_dir / "chunks.json"

    @property
    def llm_configured(self) -> bool:
        key = self.together_api_key.strip()
        if not key:
            return False
        placeholders = {"your_together_api_key_here", "your_key_here", "changeme"}
        return key.lower() not in placeholders


settings = Settings()
