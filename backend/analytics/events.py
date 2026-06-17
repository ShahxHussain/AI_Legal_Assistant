"""Append-only usage events for admin analytics."""

from __future__ import annotations

from typing import Any

from db.supabase_client import get_supabase


class UsageEventStore:
    def log_event(
        self,
        event_type: str,
        device_id: str,
        *,
        conversation_id: str | None = None,
        language: str | None = None,
        topics: list[str] | None = None,
        metadata: dict | None = None,
    ) -> None:
        payload: dict[str, Any] = {
            "event_type": event_type,
            "device_id": device_id,
            "topics": topics or [],
            "metadata": metadata or {},
        }
        if conversation_id:
            payload["conversation_id"] = conversation_id
        if language:
            payload["language"] = language
        get_supabase().table("usage_events").insert(payload).execute()
