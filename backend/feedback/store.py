"""Per-answer thumbs up/down persistence."""

from __future__ import annotations

from typing import Any

from db.supabase_client import get_supabase


class FeedbackStore:
    def upsert_feedback(
        self,
        *,
        message_id: str,
        device_id: str,
        rating: str,
        conversation_id: str | None = None,
        comment: str | None = None,
        language: str | None = None,
        topics: list[str] | None = None,
        channel: str = "chat",
    ) -> dict[str, Any]:
        payload: dict[str, Any] = {
            "message_id": message_id,
            "device_id": device_id,
            "rating": rating,
            "topics": topics or [],
            "channel": channel,
        }
        if conversation_id:
            payload["conversation_id"] = conversation_id
        if comment:
            payload["comment"] = comment[:200]
        if language:
            payload["language"] = language

        result = (
            get_supabase()
            .table("answer_feedback")
            .upsert(payload, on_conflict="message_id,device_id")
            .execute()
        )
        rows = result.data or []
        return rows[0] if rows else payload

    def recent(self, limit: int = 50) -> list[dict[str, Any]]:
        result = (
            get_supabase()
            .table("answer_feedback")
            .select("*")
            .order("created_at", desc=True)
            .limit(limit)
            .execute()
        )
        return result.data or []
