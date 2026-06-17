"""Feedback, usage events, and admin analytics queries."""

from __future__ import annotations

from collections import Counter, defaultdict
from datetime import date, datetime, timedelta, timezone
from typing import Any

from db.supabase_client import get_supabase


class AnalyticsStore:
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
    ) -> None:
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
            payload["comment"] = comment.strip()
        if language:
            payload["language"] = language

        get_supabase().table("answer_feedback").upsert(
            payload,
            on_conflict="message_id,device_id",
        ).execute()

        self.log_event(
            "feedback_given",
            device_id,
            conversation_id=conversation_id,
            language=language,
            topics=topics,
            metadata={"rating": rating, "message_id": message_id, "channel": channel},
        )

    def _since_iso(self, days: int) -> str:
        since = datetime.now(timezone.utc) - timedelta(days=days)
        return since.isoformat()

    def _today_start_iso(self) -> str:
        today = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
        return today.isoformat()

    def overview_stats(self) -> dict[str, Any]:
        since_7d = self._since_iso(7)
        today_start = self._today_start_iso()

        conv_rows = (
            get_supabase()
            .table("conversations")
            .select("device_id, created_at, updated_at")
            .gte("updated_at", since_7d)
            .execute()
            .data
            or []
        )
        device_ids: set[str] = {
            r["device_id"]
            for r in conv_rows
            if (r.get("device_id") or "").strip()
        }
        event_rows = (
            get_supabase()
            .table("usage_events")
            .select("device_id")
            .eq("event_type", "question_asked")
            .gte("created_at", since_7d)
            .execute()
            .data
            or []
        )
        for row in event_rows:
            did = (row.get("device_id") or "").strip()
            if did:
                device_ids.add(did)
        active_users = len(device_ids)

        sessions_7d = (
            get_supabase()
            .table("conversations")
            .select("id", count="exact")
            .gte("created_at", since_7d)
            .execute()
            .count
            or 0
        )

        questions_today = (
            get_supabase()
            .table("messages")
            .select("id", count="exact")
            .eq("role", "user")
            .gte("created_at", today_start)
            .execute()
            .count
            or 0
        )

        feedback_rows = (
            get_supabase()
            .table("answer_feedback")
            .select("rating")
            .gte("created_at", since_7d)
            .execute()
            .data
            or []
        )
        up = sum(1 for r in feedback_rows if r.get("rating") == "up")
        down = sum(1 for r in feedback_rows if r.get("rating") == "down")
        total_fb = up + down
        helpfulness_pct = round((up / total_fb) * 100, 1) if total_fb else None

        total_questions_7d = (
            get_supabase()
            .table("messages")
            .select("id", count="exact")
            .eq("role", "user")
            .gte("created_at", since_7d)
            .execute()
            .count
            or 0
        )

        return {
            "active_users_7d": active_users,
            "sessions_7d": sessions_7d,
            "questions_today": questions_today,
            "questions_7d": total_questions_7d,
            "feedback_up_7d": up,
            "feedback_down_7d": down,
            "helpfulness_pct_7d": helpfulness_pct,
        }

    def questions_per_day(self, days: int = 30) -> list[dict[str, Any]]:
        since = self._since_iso(days)
        rows = (
            get_supabase()
            .table("messages")
            .select("created_at")
            .eq("role", "user")
            .gte("created_at", since)
            .order("created_at")
            .execute()
            .data
            or []
        )
        counts: Counter[str] = Counter()
        for row in rows:
            raw = row.get("created_at")
            if not raw:
                continue
            dt = datetime.fromisoformat(raw.replace("Z", "+00:00"))
            counts[dt.date().isoformat()] += 1

        start = date.today() - timedelta(days=days - 1)
        series: list[dict[str, Any]] = []
        for i in range(days):
            d = start + timedelta(days=i)
            key = d.isoformat()
            series.append({"date": key, "count": counts.get(key, 0)})
        return series

    def language_breakdown(self, days: int = 30) -> list[dict[str, Any]]:
        since = self._since_iso(days)
        rows = (
            get_supabase()
            .table("conversations")
            .select("language, created_at")
            .gte("created_at", since)
            .execute()
            .data
            or []
        )
        counts: Counter[str] = Counter()
        for row in rows:
            lang = (row.get("language") or "unknown").strip() or "unknown"
            counts[lang] += 1
        total = sum(counts.values()) or 1
        return [
            {
                "language": lang,
                "count": count,
                "pct": round((count / total) * 100, 1),
            }
            for lang, count in counts.most_common()
        ]

    def topic_breakdown(self, days: int = 30) -> list[dict[str, Any]]:
        since = self._since_iso(days)
        rows = (
            get_supabase()
            .table("usage_events")
            .select("topics, created_at")
            .eq("event_type", "question_asked")
            .gte("created_at", since)
            .execute()
            .data
            or []
        )
        counts: Counter[str] = Counter()
        for row in rows:
            topics = row.get("topics") or []
            if topics:
                counts[topics[0]] += 1
            else:
                counts["other"] += 1
        total = sum(counts.values()) or 1
        return [
            {
                "topic": topic,
                "count": count,
                "pct": round((count / total) * 100, 1),
            }
            for topic, count in counts.most_common()
        ]

    def recent_feedback(self, limit: int = 50) -> list[dict[str, Any]]:
        rows = (
            get_supabase()
            .table("answer_feedback")
            .select(
                "id, rating, comment, language, topics, channel, created_at, device_id"
            )
            .order("created_at", desc=True)
            .limit(limit)
            .execute()
            .data
            or []
        )
        return rows
