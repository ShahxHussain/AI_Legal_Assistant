"""Build FAISS index from legal PDFs in data/."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import faiss
import numpy as np
from pypdf import PdfReader

BACKEND_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND_DIR))

from config import settings  # noqa: E402
from rag.embedder import Embedder  # noqa: E402


def normalize_text(text: str) -> str:
    text = text.replace("\x00", " ")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def guess_section(text: str) -> str:
    match = re.search(
        r"(?:Section|§)\s*(\d+[A-Za-z]?)",
        text[:400],
        re.IGNORECASE,
    )
    if match:
        return match.group(1)
    match = re.search(r"\b(\d{1,4})\.\s+[A-Z]", text[:200])
    if match:
        return match.group(1)
    return ""


def extract_pdf_pages(pdf_path: Path) -> list[dict]:
    reader = PdfReader(str(pdf_path))
    pages: list[dict] = []
    for page_num, page in enumerate(reader.pages, start=1):
        raw = page.extract_text() or ""
        text = normalize_text(raw)
        if len(text) < 80:
            continue
        pages.append(
            {
                "document": pdf_path.name,
                "page": page_num,
                "text": text,
            }
        )
    return pages


def chunk_pages(pages: list[dict]) -> list[dict]:
    chunks: list[dict] = []
    size = settings.chunk_size_words
    overlap = settings.chunk_overlap_words

    for page in pages:
        words = page["text"].split()
        if not words:
            continue

        start = 0
        while start < len(words):
            end = min(start + size, len(words))
            chunk_words = words[start:end]
            chunk_text = " ".join(chunk_words)

            if len(chunk_text) >= 100:
                chunks.append(
                    {
                        "document": page["document"],
                        "page": page["page"],
                        "section": guess_section(chunk_text),
                        "text": chunk_text,
                    }
                )

            if end >= len(words):
                break
            start += max(1, size - overlap)

    return chunks


def build_index() -> None:
    pdf_files = sorted(settings.data_dir.glob("*.pdf"))
    if not pdf_files:
        raise FileNotFoundError(f"No PDF files found in {settings.data_dir}")

    print(f"Found {len(pdf_files)} PDF(s) in {settings.data_dir}")

    all_pages: list[dict] = []
    for pdf_path in pdf_files:
        print(f"  Extracting: {pdf_path.name}")
        all_pages.extend(extract_pdf_pages(pdf_path))

    print(f"Extracted {len(all_pages)} pages with text")

    chunks = chunk_pages(all_pages)
    print(f"Created {len(chunks)} chunks")

    if not chunks:
        raise RuntimeError("No chunks created — check PDF extraction")

    texts = [c["text"] for c in chunks]
    print("Embedding chunks (this may take a few minutes on first run)...")
    embedder = Embedder()
    vectors = np.array(embedder.embed_texts(texts), dtype=np.float32)
    faiss.normalize_L2(vectors)

    index = faiss.IndexFlatIP(vectors.shape[1])
    index.add(vectors)

    settings.index_dir.mkdir(parents=True, exist_ok=True)
    faiss.write_index(index, str(settings.index_faiss_path))
    with settings.chunks_json_path.open("w", encoding="utf-8") as f:
        json.dump(chunks, f, ensure_ascii=False, indent=2)

    print(f"Saved index: {settings.index_faiss_path}")
    print(f"Saved chunks: {settings.chunks_json_path}")
    print(f"Done. {len(chunks)} vectors indexed.")


if __name__ == "__main__":
    build_index()
