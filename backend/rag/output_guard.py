"""Post-process LLM output to stop repetition loops and runaway text."""

from __future__ import annotations

import re


def _truncate_at_runaway_ngram(words: list[str], n: int, max_repeats: int = 4) -> list[str]:
    """Cut text when an n-gram repeats too many times in a row."""
    if len(words) < n * (max_repeats + 1):
        return words

    i = 0
    while i <= len(words) - n * max_repeats:
        gram = tuple(words[i : i + n])
        repeats = 1
        j = i + n
        while j + n <= len(words) and tuple(words[j : j + n]) == gram:
            repeats += 1
            j += n
        if repeats >= max_repeats:
            return words[:i]
        i += 1
    return words


# Sentence enders incl. Urdu full stop "۔" and Arabic question mark "؟"
_SENT_END = ".!?؟۔*"


def _guard_line(line: str) -> str:
    words = line.split()
    for n in (2, 1):
        words = _truncate_at_runaway_ngram(words, n=n, max_repeats=5)
    return " ".join(words)


def sanitize_llm_output(text: str) -> str:
    """
    Remove degenerate repetition (e.g. 'kisi ne kisi ne kisi ne...').
    Returns cleaned text; may truncate if a loop is detected.
    """
    if not text:
        return text

    cleaned = text.strip()
    cleaned = re.sub(r"\n{3,}", "\n\n", cleaned)

    # Collapse inline repeated short phrases (regex back-reference)
    for n in (3, 2, 1):
        if n == 1:
            pattern = r"(\b\w+\b)(?:\s+\1){4,}"
        else:
            pattern = rf"((?:\b\w+\b\s+){{{n - 1}}}\b\w+\b)(?:\s+\1){{3,}}"
        cleaned = re.sub(pattern, r"\1", cleaned, flags=re.IGNORECASE)

    # Runaway-ngram guard per line so markdown lists/headings keep their
    # line breaks (loops happen within a line, not across them).
    cleaned = "\n".join(
        _guard_line(line) if line.strip() else line
        for line in cleaned.split("\n")
    ).strip()

    # Drop a dangling half-sentence after aggressive truncation
    if cleaned and cleaned[-1] not in _SENT_END:
        last_stop = max(cleaned.rfind(ch) for ch in _SENT_END)
        if last_stop > len(cleaned) * 0.45:
            cleaned = cleaned[: last_stop + 1].strip()

    return cleaned
