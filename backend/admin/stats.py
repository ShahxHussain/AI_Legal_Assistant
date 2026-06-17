"""Admin dashboard aggregate queries."""

from __future__ import annotations

from collections import Counter
from datetime import date, datetime, timedelta, timezone
from typing import Any, Callable, TypeVar

from db.supabase_client import get_supabase

T = TypeVar("T")


def _utc_now() -> datetime:
    return datetime.now(timezone.utc)


def _iso_since(days: int) -> str:
    return (_utc_now() - timedelta(days=days)).isoformat()


def _parse_ts(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None


def _safe_query(fn: Callable[[], T], default: T) -> T:
    """Retry once — Supabase/HTTP2 can flake with 'Server disconnected'."""
    for attempt in range(2):
        try:
            return fn()
        except Exception:
            if attempt == 1:
                return default
    return default


class AdminStatsService:
    def overview(self, *, days: int = 7) -> dict[str, Any]:
        since = _iso_since(days)

        def load() -> dict[str, Any]:
            client = get_supabase()
            conv_rows = (
                client.table("conversations")
                .select("device_id, created_at")
                .gte("created_at", since)
                .execute()
                .data
                or []
            )
            sessions_7d = len(conv_rows)
            active_users = len({r["device_id"] for r in conv_rows if r.get("device_id")})

            msg_rows = (
                client.table("messages")
                .select("created_at, role")
                .eq("role", "user")
                .gte("created_at", since)
                .execute()
                .data
                or []
            )
            today = _utc_now().date()
            questions_today = sum(
                1
                for row in msg_rows
                if (_parse_ts(row.get("created_at")) or _utc_now()).date() == today
            )

            feedback_rows = (
                client.table("answer_feedback")
                .select("rating, created_at")
                .gte("created_at", since)
                .execute()
                .data
                or []
            )
            up = sum(1 for r in feedback_rows if r.get("rating") == "up")
            down = sum(1 for r in feedback_rows if r.get("rating") == "down")
            total_fb = up + down
            helpfulness_pct = round((up / total_fb) * 100, 1) if total_fb else None

            return {
                "active_users_7d": active_users,
                "sessions_7d": sessions_7d,
                "questions_today": questions_today,
                "questions_7d": len(msg_rows),
                "feedback_up_7d": up,
                "feedback_down_7d": down,
                "helpfulness_pct_7d": helpfulness_pct,
            }

        return _safe_query(
            load,
            {
                "active_users_7d": 0,
                "sessions_7d": 0,
                "questions_today": 0,
                "questions_7d": 0,
                "feedback_up_7d": 0,
                "feedback_down_7d": 0,
                "helpfulness_pct_7d": None,
            },
        )

    def questions_per_day(self, *, days: int = 30) -> list[dict[str, Any]]:
        since = _iso_since(days)

        def load() -> list[dict[str, Any]]:
            rows = (
                get_supabase()
                .table("messages")
                .select("created_at")
                .eq("role", "user")
                .gte("created_at", since)
                .execute()
                .data
                or []
            )
            counts: Counter[date] = Counter()
            for row in rows:
                ts = _parse_ts(row.get("created_at"))
                if ts:
                    counts[ts.date()] += 1

            start = (_utc_now() - timedelta(days=days - 1)).date()
            series: list[dict[str, Any]] = []
            for offset in range(days):
                day = start + timedelta(days=offset)
                series.append(
                    {
                        "date": day.isoformat(),
                        "count": counts.get(day, 0),
                    }
                )
            return series

        empty = [
            {
                "date": (_utc_now() - timedelta(days=days - 1 - offset)).date().isoformat(),
                "count": 0,
            }
            for offset in range(days)
        ]
        return _safe_query(load, empty)

    def language_breakdown(self, *, days: int = 30) -> list[dict[str, Any]]:
        since = _iso_since(days)

        def load() -> list[dict[str, Any]]:
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

        return _safe_query(load, [])

    def topic_breakdown(self, *, days: int = 30) -> list[dict[str, Any]]:
        since = _iso_since(days)

        def load() -> list[dict[str, Any]]:
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
                if not topics:
                    counts["other"] += 1
                    continue
                for topic in topics:
                    counts[str(topic)] += 1
            total = sum(counts.values()) or 1
            return [
                {
                    "topic": topic,
                    "count": count,
                    "pct": round((count / total) * 100, 1),
                }
                for topic, count in counts.most_common(12)
            ]

        return _safe_query(load, [])

    def recent_feedback(self, *, limit: int = 50) -> list[dict[str, Any]]:
        from feedback.store import FeedbackStore

        return _safe_query(lambda: FeedbackStore().recent(limit=limit), [])
