"""Extract plain text from user-uploaded documents."""

from __future__ import annotations

import io
import re
from pathlib import Path

from pypdf import PdfReader

from config import settings

_ALLOWED_SUFFIXES = {".pdf", ".txt"}


def normalize_text(text: str) -> str:
    text = text.replace("\x00", " ")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def _extract_pdf(data: bytes) -> str:
    reader = PdfReader(io.BytesIO(data))
    parts: list[str] = []
    for page in reader.pages:
        parts.append(page.extract_text() or "")
    return normalize_text(" ".join(parts))


def _extract_txt(data: bytes) -> str:
    for encoding in ("utf-8", "utf-16", "latin-1"):
        try:
            return normalize_text(data.decode(encoding))
        except UnicodeDecodeError:
            continue
    return normalize_text(data.decode("utf-8", errors="replace"))


def validate_upload(filename: str, size_bytes: int) -> None:
    suffix = Path(filename).suffix.lower()
    if suffix not in _ALLOWED_SUFFIXES:
        raise ValueError(
            f"Unsupported file type '{suffix or 'unknown'}'. "
            "Upload a PDF or TXT file."
        )
    if size_bytes <= 0:
        raise ValueError("File is empty.")
    if size_bytes > settings.upload_max_bytes:
        max_mb = settings.upload_max_bytes // (1024 * 1024)
        raise ValueError(f"File too large. Maximum size is {max_mb} MB.")


def extract_document_text(data: bytes, filename: str) -> tuple[str, bool]:
    """Return (text, was_truncated)."""
    validate_upload(filename, len(data))
    suffix = Path(filename).suffix.lower()

    if suffix == ".pdf":
        text = _extract_pdf(data)
    else:
        text = _extract_txt(data)

    if len(text) < 40:
        raise ValueError(
            "Could not extract enough text from this file. "
            "Try a text-based PDF or a TXT file."
        )

    truncated = len(text) > settings.upload_max_chars
    if truncated:
        text = (
            text[: settings.upload_max_chars]
            + "\n\n[Document truncated for analysis — full file may be longer.]"
        )
    return text, truncated
