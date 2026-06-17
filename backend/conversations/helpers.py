"""Conversation resolution and history formatting."""

from __future__ import annotations

from typing import Any

from fastapi import HTTPException

from config import settings
from conversations.store import ConversationStore


def history_for_llm(rows: list[dict[str, Any]]) -> list[dict[str, str]]:
    """Map DB rows to OpenAI-style user/assistant messages."""
    out: list[dict[str, str]] = []
    for row in rows:
        role = row.get("role")
        content = (row.get("content") or "").strip()
        if role in ("user", "assistant") and content:
            out.append({"role": role, "content": content})
    limit = max(2, settings.conversation_history_limit * 2)
    return out[-limit:]


def build_search_query(question: str, history: list[dict[str, Any]]) -> str:
    """Enrich retrieval for follow-up turns."""
    if not history:
        return question
    prior_user = [
        (row.get("content") or "").strip()
        for row in history
        if row.get("role") == "user"
    ]
    parts = [p for p in prior_user[-2:] if p]
    parts.append(question.strip())
    return " ".join(parts)


def resolve_conversation(
    device_id: str | None,
    language: str,
    conversation_id: str | None,
) -> tuple[str | None, list[dict[str, Any]], ConversationStore | None]:
    """
    Return (conversation_id, prior_messages, store).
    When Supabase is off or device_id missing, returns (None, [], None).
    """
    if not settings.supabase_configured or not (device_id or "").strip():
        return None, [], None

    store = ConversationStore()
    did = device_id.strip()

    if conversation_id:
        conv = store.get_conversation(conversation_id, did)
        if conv is None:
            raise HTTPException(status_code=404, detail="Conversation not found")
        cid = conversation_id
    else:
        conv = store.create_conversation(did, language)
        cid = conv["id"]

    prior = store.get_messages(
        cid,
        did,
        limit=max(2, settings.conversation_history_limit * 2),
    )
    return cid, prior, store
