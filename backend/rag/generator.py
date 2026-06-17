from together import Together

from config import settings
from rag.language import (
    detect_response_language,
    language_instruction,
    language_system_rule,
)
from rag.output_guard import sanitize_llm_output
from rag.prompts import (
    CONVERSATIONAL_PROMPT,
    DOCUMENT_ANALYSIS_PROMPT,
    SYSTEM_PROMPT,
    VOICE_REPLY_APPEND,
)
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
            # Reasoning-capable models can be slow; retry transient timeouts.
            self._client = Together(
                api_key=settings.together_api_key,
                timeout=90,
                max_retries=2,
            )
        return self._client

    def _completion_params(self) -> dict:
        params = {
            "model": settings.llm_model,
            "temperature": settings.llm_temperature,
            "repetition_penalty": settings.llm_repetition_penalty,
            "frequency_penalty": settings.llm_frequency_penalty,
        }
        if settings.llm_reasoning_effort:
            params["reasoning_effort"] = settings.llm_reasoning_effort
        return params

    def translate_query(self, question: str) -> str:
        """
        Translate a non-English question to English for retrieval.
        The FAISS index and embedding model are English-only, so Urdu /
        Pashto / Sindhi etc. queries must be translated before search.
        Falls back to the original question on any failure.
        """
        try:
            client = self._get_client()
            response = client.chat.completions.create(
                model=settings.translation_model,
                messages=[
                    {
                        "role": "system",
                        "content": (
                            "You translate questions about Pakistani law into "
                            "clear English search queries. Output ONLY the "
                            "English translation — no preamble, no notes. Keep "
                            "legal terms like FIR, bail, PPC, CrPC as-is. "
                            "Preserve EVERY legal topic in the question: name "
                            "each offence (theft, murder, fraud...), each "
                            "procedure (FIR registration, bail, arrest...), and "
                            "any section numbers or amounts mentioned. If the "
                            "question mentions FIR (ایف آئی آر), the translation "
                            "MUST contain the word 'FIR'."
                        ),
                    },
                    {"role": "user", "content": question.strip()},
                ],
                max_tokens=250,
                temperature=0.0,
            )
            text = (response.choices[0].message.content or "").strip()
            return text or question
        except Exception:
            return question

    def _chat(self, messages: list[dict], *, max_tokens: int) -> str:
        client = self._get_client()
        response = client.chat.completions.create(
            messages=messages,
            max_tokens=max_tokens,
            **self._completion_params(),
        )
        raw = response.choices[0].message.content or ""
        return sanitize_llm_output(raw)

    def _chat_stream(self, messages: list[dict], *, max_tokens: int):
        """Yield raw text deltas from the LLM as they arrive."""
        client = self._get_client()
        response = client.chat.completions.create(
            messages=messages,
            max_tokens=max_tokens,
            stream=True,
            **self._completion_params(),
        )
        for part in response:
            choices = getattr(part, "choices", None)
            if not choices:
                continue
            delta = getattr(choices[0], "delta", None)
            text = getattr(delta, "content", None) if delta else None
            if text:
                yield text

    def _inject_history(
        self, messages: list[dict], history: list[dict[str, str]]
    ) -> list[dict]:
        if not history:
            return messages
        system = messages[0]
        tail = messages[1:]
        return [system, *history, *tail]

    def _rag_messages(
        self,
        question: str,
        chunks: list[RetrievedChunk],
        language: str | None = None,
        *,
        voice_mode: bool = False,
        history: list[dict[str, str]] | None = None,
    ) -> list[dict]:
        context = build_context(chunks)
        lang = detect_response_language(question, override=language)
        lang_rule = language_system_rule(lang)

        system_content = (
            SYSTEM_PROMPT.format(context=context)
            + f"\n\n---\n## {lang_rule}\n"
            + "CRITICAL: Never repeat the same phrase or sentence. "
            "If you finish the answer, stop immediately. No loops.\n"
        )
        if voice_mode:
            system_content += VOICE_REPLY_APPEND

        user_message = (
            f"{question.strip()}\n\n"
            f"{language_instruction(lang)}\n"
            + (
                "Give a clear spoken-style answer the user will hear aloud."
                if voice_mode
                else "Give a clear, realistic answer. Address all parts of the question if it has multiple points."
            )
        )

        return self._inject_history(
            [
                {"role": "system", "content": system_content},
                {"role": "user", "content": user_message},
            ],
            history or [],
        )

    def generate(
        self,
        question: str,
        chunks: list[RetrievedChunk],
        language: str | None = None,
        *,
        voice_mode: bool = False,
        history: list[dict[str, str]] | None = None,
    ) -> str:
        return self._chat(
            self._rag_messages(
                question, chunks, language, voice_mode=voice_mode, history=history
            ),
            max_tokens=settings.llm_max_tokens,
        )

    def generate_stream(
        self,
        question: str,
        chunks: list[RetrievedChunk],
        language: str | None = None,
        *,
        voice_mode: bool = False,
        history: list[dict[str, str]] | None = None,
    ):
        """Yield raw answer deltas; caller sanitizes the joined result."""
        yield from self._chat_stream(
            self._rag_messages(
                question, chunks, language, voice_mode=voice_mode, history=history
            ),
            max_tokens=settings.llm_max_tokens,
        )

    def _conversational_messages(
        self,
        question: str,
        language: str | None = None,
        *,
        voice_mode: bool = False,
        history: list[dict[str, str]] | None = None,
    ) -> list[dict]:
        lang = detect_response_language(question, override=language)
        lang_rule = language_system_rule(lang)

        system_content = (
            CONVERSATIONAL_PROMPT
            + f"\n\n---\n## {lang_rule}\n"
            + "CRITICAL: Keep the reply short. Never repeat words or phrases.\n"
        )
        if voice_mode:
            system_content += VOICE_REPLY_APPEND
        user_message = f"{question.strip()}\n\n{language_instruction(lang)}"

        return self._inject_history(
            [
                {"role": "system", "content": system_content},
                {"role": "user", "content": user_message},
            ],
            history or [],
        )

    def generate_conversational(
        self,
        question: str,
        language: str | None = None,
        *,
        voice_mode: bool = False,
        history: list[dict[str, str]] | None = None,
    ) -> str:
        """Reply to greetings / meta questions without RAG context or sources."""
        return self._chat(
            self._conversational_messages(
                question, language, voice_mode=voice_mode, history=history
            ),
            max_tokens=settings.llm_conversational_max_tokens,
        )

    def generate_conversational_stream(
        self,
        question: str,
        language: str | None = None,
        *,
        voice_mode: bool = False,
        history: list[dict[str, str]] | None = None,
    ):
        yield from self._chat_stream(
            self._conversational_messages(
                question, language, voice_mode=voice_mode, history=history
            ),
            max_tokens=settings.llm_conversational_max_tokens,
        )

    def generate_document_analysis(
        self,
        document_text: str,
        filename: str,
        question: str | None = None,
        rag_chunks: list[RetrievedChunk] | None = None,
        language: str | None = None,
    ) -> str:
        """Analyze an uploaded document, optionally with a user question + statutes."""
        q = (question or "").strip()
        lang = detect_response_language(
            q or document_text[:600], override=language
        )
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
