from together import Together

from config import settings
from rag.language import (
    detect_response_language,
    language_instruction,
    language_system_rule,
)
from rag.output_guard import sanitize_llm_output
from rag.prompts import CONVERSATIONAL_PROMPT, DOCUMENT_ANALYSIS_PROMPT, SYSTEM_PROMPT
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

    def _completion_params(self) -> dict:
        return {
            "model": settings.llm_model,
            "temperature": settings.llm_temperature,
            "repetition_penalty": settings.llm_repetition_penalty,
            "frequency_penalty": settings.llm_frequency_penalty,
        }

    def _chat(self, messages: list[dict], *, max_tokens: int) -> str:
        client = self._get_client()
        response = client.chat.completions.create(
            messages=messages,
            max_tokens=max_tokens,
            **self._completion_params(),
        )
        raw = response.choices[0].message.content or ""
        return sanitize_llm_output(raw)

    def generate(self, question: str, chunks: list[RetrievedChunk]) -> str:
        context = build_context(chunks)
        lang = detect_response_language(question)
        lang_rule = language_system_rule(lang)

        system_content = (
            SYSTEM_PROMPT.format(context=context)
            + f"\n\n---\n## {lang_rule}\n"
            + "CRITICAL: Never repeat the same phrase or sentence. "
            "If you finish the answer, stop immediately. No loops.\n"
        )

        user_message = (
            f"{question.strip()}\n\n"
            f"{language_instruction(lang)}\n"
            "Give a clear, realistic answer. Address all parts of the question if it has multiple points."
        )

        return self._chat(
            [
                {"role": "system", "content": system_content},
                {"role": "user", "content": user_message},
            ],
            max_tokens=settings.llm_max_tokens,
        )

    def generate_conversational(self, question: str) -> str:
        """Reply to greetings / meta questions without RAG context or sources."""
        lang = detect_response_language(question)
        lang_rule = language_system_rule(lang)

        system_content = (
            CONVERSATIONAL_PROMPT
            + f"\n\n---\n## {lang_rule}\n"
            + "CRITICAL: Keep the reply short. Never repeat words or phrases.\n"
        )
        user_message = f"{question.strip()}\n\n{language_instruction(lang)}"

        return self._chat(
            [
                {"role": "system", "content": system_content},
                {"role": "user", "content": user_message},
            ],
            max_tokens=settings.llm_conversational_max_tokens,
        )

    def generate_document_analysis(
        self,
        document_text: str,
        filename: str,
        question: str | None = None,
        rag_chunks: list[RetrievedChunk] | None = None,
    ) -> str:
        """Analyze an uploaded document, optionally with a user question + statutes."""
        q = (question or "").strip()
        lang = detect_response_language(q or document_text[:600])
        lang_rule = language_system_rule(lang)

        doc_context = f"### File: {filename}\n{document_text}"
        if rag_chunks:
            doc_context += (
                "\n\n### Related statutes (PPC / CrPC / ATA)\n"
                + build_context(rag_chunks)
            )

        if q:
            task = (
                f"Answer this question using the uploaded document"
                f"{' and statute sources' if rag_chunks else ''}:\n\n{q}"
            )
        else:
            task = (
                "No specific question was asked. Provide a clear legal information "
                "summary of the uploaded document for an ordinary citizen."
            )

        system_content = (
            DOCUMENT_ANALYSIS_PROMPT.format(
                task=task,
                document_context=doc_context,
            )
            + f"\n\n---\n## {lang_rule}\n"
            + "CRITICAL: Never repeat phrases. Write once, clearly.\n"
        )
        user_message = (
            f"{language_instruction(lang)}\n"
            "Use headings or bullet points where helpful."
        )

        return self._chat(
            [
                {"role": "system", "content": system_content},
                {"role": "user", "content": user_message},
            ],
            max_tokens=settings.llm_max_tokens,
        )
