"""Build FAISS index from legal PDFs using section-aware chunking."""

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

# Statute section starts: 154. Title: body | 45. "Life": body | 1. Title. - (1)
SECTION_START = re.compile(
    r"(?<![\d/])"
    r"(\d{1,4}[A-Za-z]?)\.\s+"
    r"(?:"
    r'"[^"]+":\s*'
    r"|[A-Z(][^:]{2,130}:\s*"
    r"|[A-Z][^.\n]{5,130}\.\s*[-\u2013\u2014]\s*"
    r")",
    re.MULTILINE,
)

SUBSECTION_SPLIT = re.compile(r"(?<=\s)\((\d{1,2})\)\s+(?=[A-Z\"(])")

PPC_TOPIC_KEYWORDS: dict[str, list[str]] = {
    "state": ["treason", "sedition", "waging war", "state"],
    "human_body": ["qatl", "murder", "hurt", "assault", "grievous"],
    "property": ["theft", "robbery", "cheating", "trust", "stolen"],
    "documents": ["forgery", "document", "counterfeit"],
    "public_tranquility": ["riot", "unlawful assembly", "affray"],
    "religion": ["religion", "blasphemy", "295", "296", "298"],
    "defamation": ["defamation", "intimidation", "criminal intimidation"],
}


def normalize_text(text: str) -> str:
    text = text.replace("\x00", " ")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def extract_pdf_full_text(pdf_path: Path) -> tuple[str, list[tuple[int, int]]]:
    """Return merged document text and (char_offset, page_num) markers."""
    reader = PdfReader(str(pdf_path))
    parts: list[str] = []
    page_offsets: list[tuple[int, int]] = []
    offset = 0

    for page_num, page in enumerate(reader.pages, start=1):
        text = normalize_text(page.extract_text() or "")
        if len(text) < 30:
            continue
        page_offsets.append((offset, page_num))
        parts.append(text)
        offset += len(text) + 1

    return " ".join(parts), page_offsets


def page_for_offset(offset: int, page_offsets: list[tuple[int, int]]) -> int:
    page = page_offsets[0][1] if page_offsets else 1
    for start, page_num in page_offsets:
        if start <= offset:
            page = page_num
    return page


def parse_section_header(match: re.Match[str], text: str) -> tuple[str, str]:
    section = match.group(1)
    rest = text[match.end() : match.end() + 140]
    title_match = re.match(
        r'(?:"([^"]+)"|([A-Z(][^:]{2,120}?))(?::|\.)',
        rest,
        re.DOTALL,
    )
    title = ""
    if title_match:
        title = (title_match.group(1) or title_match.group(2) or "").strip()
        title = re.sub(r"\s+", " ", title)[:120]
    return section, title


def is_toc_only(text: str) -> bool:
    """Drop index/table-of-contents blocks that list titles without statute body."""
    words = text.split()
    if len(words) < 50:
        return False

    headers = re.findall(r"\b\d{1,4}[A-Za-z]?\.", text[:2500])
    substantive = re.findall(
        r"\b\d{1,4}[A-Za-z]?\.[^:]{2,100}:\s*(?:\(|\"|[A-Za-z]{8,})",
        text,
    )
    if len(headers) >= 6 and len(substantive) == 0:
        return True
    if len(headers) >= 10 and len(substantive) <= 1 and len(words) < 300:
        return True
    return False


def infer_topic(text: str, document: str) -> str:
    if "penal" not in document.lower():
        return ""
    lower = text.lower()
    for topic, keywords in PPC_TOPIC_KEYWORDS.items():
        if any(kw in lower for kw in keywords):
            return topic
    return ""


def split_oversized_section(text: str, section: str, title: str) -> list[str]:
    """Split very long sections at numbered subsections."""
    max_words = settings.section_chunk_max_words
    words = text.split()
    if len(words) <= max_words:
        return [text]

    parts: list[str] = []
    splits = list(SUBSECTION_SPLIT.finditer(text))
    if len(splits) < 2:
        # Fall back to fixed windows preserving section header
        header = text[:120]
        start = 0
        while start < len(words):
            end = min(start + max_words, len(words))
            chunk_words = words[start:end]
            if start == 0:
                parts.append(" ".join(chunk_words))
            else:
                prefix = f"{section}. {title}: " if title else f"{section}. "
                parts.append(prefix + " ".join(chunk_words))
            if end >= len(words):
                break
            start += max_words - settings.chunk_overlap_words
        return parts

    boundaries = [0] + [m.start() for m in splits[1:]] + [len(text)]
    for i in range(len(boundaries) - 1):
        segment = text[boundaries[i] : boundaries[i + 1]].strip()
        if len(segment.split()) >= 30:
            parts.append(segment)
    return parts or [text]


def merge_small_sections(sections: list[dict]) -> list[dict]:
    """Merge consecutive tiny fragments (often PDF artifacts) with the next section."""
    min_words = settings.section_chunk_min_words
    if not sections:
        return sections

    merged: list[dict] = []
    buffer: dict | None = None

    for section in sections:
        word_count = len(section["text"].split())
        if buffer is not None:
            buffer["text"] = f'{buffer["text"]} {section["text"]}'.strip()
            buffer["section"] = section["section"] or buffer["section"]
            buffer["title"] = section["title"] or buffer["title"]
            buffer["page"] = section["page"]
            word_count = len(buffer["text"].split())
            if word_count >= min_words:
                merged.append(buffer)
                buffer = None
            continue

        if word_count < min_words:
            buffer = section
        else:
            merged.append(section)

    if buffer is not None:
        if merged:
            merged[-1]["text"] = f'{merged[-1]["text"]} {buffer["text"]}'.strip()
        else:
            merged.append(buffer)

    return merged


def split_document_into_sections(
    document: str,
    full_text: str,
    page_offsets: list[tuple[int, int]],
) -> list[dict]:
    matches = list(SECTION_START.finditer(full_text))
    if not matches:
        return fallback_word_chunks(document, full_text, page_offsets)

    raw_sections: list[dict] = []

    if matches[0].start() > 80:
        preamble = full_text[: matches[0].start()].strip()
        if len(preamble.split()) >= 40 and not is_toc_only(preamble):
            raw_sections.append(
                {
                    "document": document,
                    "page": page_for_offset(0, page_offsets),
                    "section": "",
                    "title": "Preamble",
                    "topic": "",
                    "text": preamble,
                }
            )

    for i, match in enumerate(matches):
        start = match.start()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(full_text)
        text = full_text[start:end].strip()
        if len(text) < 40 or is_toc_only(text):
            continue

        section, title = parse_section_header(match, full_text)
        page = page_for_offset(start, page_offsets)
        topic = infer_topic(text, document)

        for part in split_oversized_section(text, section, title):
            raw_sections.append(
                {
                    "document": document,
                    "page": page,
                    "section": section,
                    "title": title,
                    "topic": topic,
                    "text": part,
                }
            )

    return merge_small_sections(raw_sections)


def fallback_word_chunks(
    document: str,
    full_text: str,
    page_offsets: list[tuple[int, int]],
) -> list[dict]:
    """Word-window fallback when section boundaries are not detected."""
    chunks: list[dict] = []
    size = settings.chunk_size_words
    overlap = settings.chunk_overlap_words
    words = full_text.split()
    start = 0

    while start < len(words):
        end = min(start + size, len(words))
        chunk_text = " ".join(words[start:end])
        if len(chunk_text) >= 100:
            offset = full_text.find(chunk_text[:80])
            if offset < 0:
                offset = 0
            chunks.append(
                {
                    "document": document,
                    "page": page_for_offset(offset, page_offsets),
                    "section": _guess_section(chunk_text),
                    "title": "",
                    "topic": infer_topic(chunk_text, document),
                    "text": chunk_text,
                }
            )
        if end >= len(words):
            break
        start += max(1, size - overlap)

    return chunks


def _guess_section(text: str) -> str:
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


def build_chunks_from_pdfs(pdf_files: list[Path]) -> list[dict]:
    all_chunks: list[dict] = []
    for pdf_path in pdf_files:
        print(f"  Section-splitting: {pdf_path.name}")
        full_text, page_offsets = extract_pdf_full_text(pdf_path)
        sections = split_document_into_sections(pdf_path.name, full_text, page_offsets)
        print(f"    -> {len(sections)} section chunks")
        all_chunks.extend(sections)
    return all_chunks


def build_index() -> None:
    pdf_files = sorted(settings.data_dir.glob("*.pdf"))
    if not pdf_files:
        raise FileNotFoundError(f"No PDF files found in {settings.data_dir}")

    print(f"Found {len(pdf_files)} PDF(s) in {settings.data_dir}")

    chunks = build_chunks_from_pdfs(pdf_files)
    print(f"Created {len(chunks)} section-aware chunks")

    if not chunks:
        raise RuntimeError("No chunks created — check PDF extraction")

    with_section = sum(1 for c in chunks if c.get("section"))
    with_topic = sum(1 for c in chunks if c.get("topic"))
    print(f"  Chunks with section metadata: {with_section}/{len(chunks)}")
    print(f"  PPC topic-tagged chunks: {with_topic}")

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
