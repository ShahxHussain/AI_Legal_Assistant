from together import Together

from config import settings
from rag.prompts import SYSTEM_PROMPT
from rag.retriever import RetrievedChunk


def build_context(chunks: list[RetrievedChunk]) -> str:
    blocks: list[str] = []
    for i, chunk in enumerate(chunks, start=1):
        header = f"[Source {i}: {chunk.document}"
        if chunk.section:
            header += f", Section {chunk.section}"
        header += "]"
        blocks.append(f"{header}\n{chunk.text}")
    return "\n\n".join(blocks)


class Generator:
    def __init__(self) -> None:
        self._client: Together | None = None

    @property
    def is_configured(self) -> bool:
        return settings.llm_configured

    def _get_client(self) -> Together:
        if not settings.llm_configured:
            raise RuntimeError("TOGETHER_API_KEY is not configured")
        if self._client is None:
            self._client = Together(api_key=settings.together_api_key)
        return self._client

    def generate(self, question: str, chunks: list[RetrievedChunk]) -> str:
        context = build_context(chunks)
        system_content = SYSTEM_PROMPT.format(context=context)

        client = self._get_client()
        user_message = (
            f"{question}\n\n"
            "(Reply in the same language as the question. Keep it short and voice-friendly.)"
        )

        response = client.chat.completions.create(
            model=settings.llm_model,
            messages=[
                {"role": "system", "content": system_content},
                {"role": "user", "content": user_message},
            ],
            temperature=0.25,
            max_tokens=512,
        )
        return response.choices[0].message.content or ""
