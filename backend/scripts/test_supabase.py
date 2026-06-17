#!/usr/bin/env python3
"""Verify Supabase credentials and round-trip conversation storage."""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from config import settings
from conversations.store import ConversationStore
from db.supabase_client import ping_supabase


def main() -> int:
    print("Supabase configured:", settings.supabase_configured)
    if not settings.supabase_configured:
        print("FAIL: Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in backend/.env")
        return 1

    ok, err = ping_supabase()
    if not ok:
        print("FAIL: ping:", err)
        return 1
    print("OK: ping")

    store = ConversationStore()
    device_id = "supabase-test-device"
    conv = store.create_conversation(device_id, "urdu_script")
    conv_id = conv["id"]
    print("OK: created conversation", conv_id)

    msg = store.append_message(
        conv_id,
        device_id,
        role="user",
        content="Test message from test_supabase.py",
    )
    print("OK: appended message", msg["id"])

    messages = store.get_messages(conv_id, device_id)
    assert len(messages) >= 1
    print("OK: read back", len(messages), "message(s)")

    deleted = store.delete_conversation(conv_id, device_id)
    assert deleted
    print("OK: deleted test conversation")
    print("\nAll Supabase checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
