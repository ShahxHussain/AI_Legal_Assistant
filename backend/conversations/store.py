"""Conversation persistence — device-scoped, no citizen login."""

from __future__ import annotations

from typing import Any

from db.supabase_client import get_supabase


class ConversationStore:
    def create_conversation(self, device_id: str, language: str) -> dict[str, Any]:
        row = (
            get_supabase()
            .table("conversations")
            .insert({"device_id": device_id, "language": language})
            .execute()
        )
        return row.data[0]

    def list_conversations(self, device_id: str, limit: int = 20) -> list[dict[str, Any]]:
        result = (
            get_supabase()
            .table("conversations")
            .select("*")
            .eq("device_id", device_id)
            .order("updated_at", desc=True)
            .limit(limit)
            .execute()
        )
        return result.data or []

    def get_conversation(self, conversation_id: str, device_id: str) -> dict[str, Any] | None:
        result = (
            get_supabase()
            .table("conversations")
            .select("*")
            .eq("id", conversation_id)
            .eq("device_id", device_id)
            .limit(1)
            .execute()
        )
        rows = result.data or []
        return rows[0] if rows else None

    def get_messages(
        self,
        conversation_id: str,
        device_id: str,
        limit: int = 50,
    ) -> list[dict[str, Any]]:
        if self.get_conversation(conversation_id, device_id) is None:
            return []
        result = (
            get_supabase()
            .table("messages")
            .select("*")
            .eq("conversation_id", conversation_id)
            .order("created_at")
            .limit(limit)
            .execute()
        )
        return result.data or []

    def append_message(
        self,
        conversation_id: str,
        device_id: str,
        *,
        role: str,
        content: str,
        phase: str | None = None,
        sources: list | None = None,
        metadata: dict | None = None,
    ) -> dict[str, Any]:
        conv = self.get_conversation(conversation_id, device_id)
        if conv is None:
            raise PermissionError("Conversation not found for this device")

        payload: dict[str, Any] = {
            "conversation_id": conversation_id,
            "role": role,
            "content": content,
            "sources": sources or [],
            "metadata": metadata or {},
        }
        if phase:
            payload["phase"] = phase

        row = get_supabase().table("messages").insert(payload).execute()

        # Touch parent row so updated_at trigger fires.
        get_supabase().table("conversations").update(
            {"language": conv["language"]}
        ).eq("id", conversation_id).execute()

        return row.data[0]

    def delete_conversation(self, conversation_id: str, device_id: str) -> bool:
        result = (
            get_supabase()
            .table("conversations")
            .delete()
            .eq("id", conversation_id)
            .eq("device_id", device_id)
            .execute()
        )
        return bool(result.data)
