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
    llm_max_tokens: int = 550
    llm_conversational_max_tokens: int = 220
    llm_temperature: float = 0.25
    llm_repetition_penalty: float = 1.18
    llm_frequency_penalty: float = 0.35
    # "none" disables hidden thinking on reasoning models (e.g. Gemma 4),
    # cutting latency. Set empty to omit the parameter for models that
    # don't accept it.
    llm_reasoning_effort: str = "none"
    # Small fast model used only to translate non-English queries to English
    # before retrieval (the FAISS index + embeddings are English-only).
    translation_model: str = "meta-llama/Meta-Llama-3-8B-Instruct-Lite"
    embedding_model: str = "all-MiniLM-L6-v2"
    top_k: int = 5
    retrieval_min_score: float = 0.18
    source_min_score: float = 0.42
    chunk_size_words: int = 600
    chunk_overlap_words: int = 75
    section_chunk_min_words: int = 35
    section_chunk_max_words: int = 900
    data_dir: Path = PROJECT_ROOT / "data"
    index_dir: Path = BACKEND_DIR / "rag" / "index"
    host: str = "0.0.0.0"
    port: int = 8000
    upload_max_bytes: int = 5 * 1024 * 1024
    upload_max_chars: int = 14_000

    # Supabase (Module 1 + 2) — see docs/SUPABASE_SETUP.md
    supabase_url: str = ""
    supabase_service_role_key: str = ""
    conversation_history_limit: int = 10
    clarifying_enabled: bool = True
    admin_api_key: str = ""

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

    @property
    def supabase_configured(self) -> bool:
        url = self.supabase_url.strip()
        key = self.supabase_service_role_key.strip()
        if not url or not key:
            return False
        placeholders = {"your_key_here", "changeme", "eyj..."}
        return key.lower() not in placeholders and "your_project" not in url.lower()


settings = Settings()
