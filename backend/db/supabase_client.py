"""Supabase client — service role only; never expose to Flutter."""

from __future__ import annotations

from functools import lru_cache

from supabase import Client, create_client

from config import settings


@lru_cache(maxsize=1)
def get_supabase() -> Client:
    if not settings.supabase_configured:
        raise RuntimeError(
            "Supabase is not configured. Set SUPABASE_URL and "
            "SUPABASE_SERVICE_ROLE_KEY in backend/.env"
        )
    return create_client(
        settings.supabase_url.strip(),
        settings.supabase_service_role_key.strip(),
    )


def ping_supabase() -> tuple[bool, str | None]:
    """Return (ok, error_message)."""
    if not settings.supabase_configured:
        return False, "SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY missing"
    try:
        client = get_supabase()
        client.table("conversations").select("id", count="exact").limit(1).execute()
        return True, None
    except Exception as exc:  # noqa: BLE001 — surface connection errors to /health
        return False, str(exc)
