"""Map citizen questions to analytics topic buckets."""

from __future__ import annotations

from rag.query_analysis import LEGAL_TOPIC_HINTS
from rag.query_intent import is_legal_query

_BUCKET_NAMES = [
    "fir",
    "bail",
    "arrest_rights",
    "theft",
    "ppc_sections",
    "fraud",
    "assault",
    "terrorism",
]

_HINT_INDEX = {
    0: "fir",
    1: "bail",
    2: "arrest_rights",
    3: "theft",
    4: "ppc_sections",
    5: "fraud",
    6: "assault",
    7: "terrorism",
}


def detect_topics(text: str) -> list[str]:
    q = (text or "").lower().strip()
    if not q:
        return []

    found: list[str] = []
    for idx, (triggers, *_rest) in enumerate(LEGAL_TOPIC_HINTS):
        if any(t in q for t in triggers):
            bucket = _HINT_INDEX.get(idx, "other")
            if bucket not in found:
                found.append(bucket)

    if "ppc_sections" not in found:
        import re

        if re.search(r"(?:section|§)\s*\d+", q) or re.search(
            r"\b(302|379|420|154|496|497)\b", q
        ):
            found.append("ppc_sections")

    if not found and is_legal_query(q):
        found.append("other")
    return found
