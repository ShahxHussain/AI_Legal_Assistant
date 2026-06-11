import json
import re
from dataclasses import dataclass

import faiss
import numpy as np

from config import settings
from rag.embedder import Embedder
from rag.query_analysis import analyze_query


@dataclass
class RetrievedChunk:
    document: str
    section: str
    text: str
    score: float
    title: str = ""

    def to_source_dict(self) -> dict:
        preview = self.text[:280].strip()
        if len(self.text) > 280:
            preview += "..."
        return {
            "document": self.document,
            "section": self.section,
            "title": self.title,
            "excerpt": preview,
            "text": self.text,
        }


_SECTION_HEADER = re.compile(r"\b\d{1,4}\.\s+[A-Z]")
_SECTION_BODY = re.compile(
    r"\b(\d{1,4}[A-Za-z]?)\.\s+([^.:]{3,90}):\s*(\S.{60,})",
    re.IGNORECASE | re.DOTALL,
)


def _toc_penalty(text: str) -> float:
    """Penalize index/TOC chunks that list many section titles without body text."""
    headers = _SECTION_HEADER.findall(text[:1200])
    if len(headers) < 4:
        return 0.0
    bodies = _SECTION_BODY.findall(text)
    if len(headers) >= 5 and len(bodies) <= 1:
        return 0.35
    if len(headers) >= 4 and len(bodies) == 0:
        return 0.25
    return 0.0


def _section_body_score(section_hints: set[str], text: str) -> float:
    """Strong boost when a hinted section appears with substantive body text."""
    if not section_hints:
        return 0.0
    best = 0.0
    for match in _SECTION_BODY.finditer(text):
        if match.group(1) in section_hints:
            best = max(best, 1.0)
    for hint in section_hints:
        if re.search(rf"\b{re.escape(hint)}\.\s+[^.:]{{3,90}}:\s*\S", text, re.I):
            best = max(best, 0.95)
    return best


def _preferred_documents(terms: set[str], section_hints: set[str]) -> set[str]:
    """All statutes relevant to the query — multi-topic questions (e.g. theft
    offence + FIR procedure) legitimately span both PPC and CrPC."""
    prefs: set[str] = set()
    if "fir" in terms or "154" in section_hints:
        prefs.add("criminal_procedure")
    if "bail" in terms or {"496", "497", "498"} & section_hints:
        prefs.add("criminal_procedure")
    if any(t in terms for t in ("arrest", "warrant", "custody", "girftari")):
        prefs.add("criminal_procedure")
    if any(t in terms for t in ("302", "379", "420", "ppc", "penal", "theft", "murder", "qatl")):
        prefs.add("penal")
    return prefs


def _direct_section_hits(
    chunks: list[dict],
    section_hints: set[str],
    prefer_docs: set[str],
) -> list[tuple[int, float]]:
    """Scan index for chunks that contain the actual section statute text."""
    if not section_hints:
        return []

    hits: list[tuple[int, float]] = []
    for idx, chunk in enumerate(chunks):
        text = chunk.get("text", "")
        document = chunk.get("document", "").lower()
        if prefer_docs and not any(p in document for p in prefer_docs):
            continue

        body_score = _section_body_score(section_hints, text)
        if body_score >= 0.95:
            hits.append((idx, body_score))
            continue

        for hint in section_hints:
            if chunk.get("section") == hint and len(text) > 180:
                if _toc_penalty(text) < 0.2:
                    hits.append((idx, 0.82))
                break

    return hits


def _keyword_score(
    terms: set[str],
    section_hints: set[str],
    phrase_hints: list[str],
    chunk: dict,
) -> float:
    text = chunk.get("text", "")
    text_lower = text.lower()
    section = chunk.get("section", "")
    document = chunk.get("document", "").lower()

    hits = sum(1 for term in terms if len(term) > 2 and term in text_lower)
    term_score = hits / max(len(terms), 1) if terms else 0.0

    section_score = 0.0
    if section and section in section_hints:
        section_score = 0.7 if _toc_penalty(text) > 0 else 1.0
    else:
        for hint in section_hints:
            if re.search(rf"\b{re.escape(hint)}\b", text_lower):
                section_score = max(section_score, 0.5)
                break

    section_score = max(section_score, _section_body_score(section_hints, text) * 0.9)

    phrase_boost = 0.0
    for phrase in phrase_hints:
        if phrase in text_lower:
            phrase_boost = max(phrase_boost, 0.75 if _toc_penalty(text) > 0 else 0.92)

    doc_score = 0.0
    if "fir" in terms or "154" in section_hints:
        if "criminal_procedure" in document:
            doc_score = 0.2
    if "bail" in terms or {"496", "497", "498"} & section_hints:
        if "criminal_procedure" in document:
            doc_score = max(doc_score, 0.2)
    if any(t in terms for t in ("302", "379", "420", "ppc", "penal", "theft", "murder")):
        if "penal" in document:
            doc_score = max(doc_score, 0.25)

    raw = term_score * 0.25 + section_score * 0.35 + phrase_boost + doc_score
    return max(0.0, min(1.0, raw - _toc_penalty(text)))


class Retriever:
    def __init__(self, embedder: Embedder) -> None:
        self.embedder = embedder
        self.index: faiss.Index | None = None
        self.chunks: list[dict] = []

    @property
    def is_loaded(self) -> bool:
        return self.index is not None and len(self.chunks) > 0

    @property
    def chunk_count(self) -> int:
        return len(self.chunks)

    def load(self) -> None:
        faiss_path = settings.index_faiss_path
        chunks_path = settings.chunks_json_path

        if not faiss_path.exists() or not chunks_path.exists():
            raise FileNotFoundError(
                f"Index not found. Run: python scripts/build_index.py "
                f"(expected {faiss_path})"
            )

        self.index = faiss.read_index(str(faiss_path))
        with chunks_path.open(encoding="utf-8") as f:
            self.chunks = json.load(f)

    def retrieve(self, query: str, top_k: int | None = None) -> list[RetrievedChunk]:
        if not self.is_loaded:
            raise RuntimeError("Retriever index is not loaded")

        k = top_k or settings.top_k
        analysis = analyze_query(query)
        search_query = analysis["expanded_query"]
        prefer_docs = _preferred_documents(
            analysis["terms"], analysis["section_hints"]
        )

        # Pull a wider pool, then re-rank with legal keyword/section signals
        candidate_k = min(max(k * 6, 24), len(self.chunks))
        query_vector = np.array(
            [self.embedder.embed_query(search_query)], dtype=np.float32
        )
        faiss.normalize_L2(query_vector)

        scores, indices = self.index.search(query_vector, candidate_k)
        ranked: list[tuple[float, dict, float]] = []
        seen_indices: set[int] = set()

        for faiss_score, idx in zip(scores[0], indices[0]):
            if idx < 0 or idx >= len(self.chunks):
                continue
            seen_indices.add(int(idx))
            chunk = self.chunks[idx]
            document = chunk.get("document", "")

            # Skip ATA unless query is terrorism-related
            if (
                "anti-terrorism" in document.lower()
                and not analysis["prefer_ata"]
                and "ata" not in analysis["terms"]
            ):
                faiss_score *= 0.55

            kw_score = _keyword_score(
                analysis["terms"],
                analysis["section_hints"],
                analysis["phrase_hints"],
                chunk,
            )
            combined = 0.35 * float(faiss_score) + 0.65 * kw_score
            ranked.append((combined, chunk, float(faiss_score)))

        # Inject chunks that contain the actual statute text for hinted sections
        for idx, direct_score in _direct_section_hits(
            self.chunks, analysis["section_hints"], prefer_docs
        ):
            if idx in seen_indices:
                for i, (score, chunk, faiss_score) in enumerate(ranked):
                    if chunk is self.chunks[idx]:
                        ranked[i] = (max(score, direct_score), chunk, faiss_score)
                        break
                continue
            ranked.append((direct_score, self.chunks[idx], direct_score * 0.5))

        ranked.sort(key=lambda x: x[0], reverse=True)

        # Drop very weak matches
        min_score = settings.retrieval_min_score
        filtered = [r for r in ranked if r[0] >= min_score]

        if len(filtered) < k:
            filtered = ranked[:k]
        else:
            filtered = filtered[:k]

        results: list[RetrievedChunk] = []
        for combined, chunk, faiss_score in filtered:
            results.append(
                RetrievedChunk(
                    document=chunk.get("document", "unknown"),
                    section=chunk.get("section", ""),
                    text=chunk.get("text", ""),
                    score=combined,
                    title=chunk.get("title", ""),
                )
            )

        return results
