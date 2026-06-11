"""Expand legal queries and extract terms for hybrid retrieval."""

from __future__ import annotations

import re

# Common citizen questions → extra retrieval terms + preferred CrPC/PPC sections
LEGAL_TOPIC_HINTS: list[tuple[list[str], list[str], list[str], list[str]]] = [
    # triggers, extra terms, section numbers, exact phrase boosts in chunk text
    (
        ["fir", "first information"],
        ["first information report", "section 154", "cognizable", "police station", "complaint"],
        ["154"],
        [
            "154. information in cognizable",
            "information in cognisable",
            "reduced to writing",
            "officer incharge of a police station",
        ],
    ),
    (
        ["bail", "zamanat"],
        ["bail", "surety", "bond", "section 496", "section 497", "section 498"],
        ["496", "497", "498"],
        ["chapter xxxix of bail", "when bail may be taken", "released on bail"],
    ),
    (
        ["arrest", "girftari", "custody"],
        ["arrest", "warrant", "magistrate", "section 54", "section 61", "custody"],
        ["54", "61", "57"],
        ["arrest without warrant", "brought before a magistrate", "no unnecessary restraint"],
    ),
    (
        ["theft", "chori", "379"],
        ["theft", "section 379", "stolen property"],
        ["379"],
        ["379. theft", "punishable under section 379", "commits theft"],
    ),
    (
        ["302", "murder", "qatl"],
        ["section 302", "qatl", "murder", "punishment"],
        ["302"],
        ["302. punishment of qatl", "punishment of qatl-i-amd", "qatl-i-amd"],
    ),
    (
        ["420", "fraud", "cheating"],
        ["section 420", "cheating", "fraud"],
        ["420"],
        ["420. cheating", "cheating and dishonestly"],
    ),
    (
        ["assault", "hurt"],
        ["assault", "hurt", "section 337", "grievous hurt"],
        ["337"],
        ["hurt", "grievous hurt"],
    ),
    (
        ["terrorism", "ata"],
        ["anti-terrorism", "terrorism", "scheduled offence"],
        [],
        ["anti-terrorism act", "terrorism"],
    ),
]


def extract_section_numbers(text: str) -> set[str]:
    sections: set[str] = set()
    for match in re.finditer(r"(?:section|§)\s*(\d+[A-Za-z]?)", text, re.I):
        sections.add(match.group(1))
    for match in re.finditer(r"\b(\d{2,4})\b", text):
        num = match.group(1)
        if 1 <= int(num) <= 999:
            sections.add(num)
    return sections


def analyze_query(query: str) -> dict:
    q = query.lower().strip()
    extra_terms: list[str] = []
    phrase_hints: list[str] = []
    section_hints: set[str] = extract_section_numbers(query)
    prefer_ata = False

    for triggers, terms, sections, phrases in LEGAL_TOPIC_HINTS:
        if any(t in q for t in triggers):
            extra_terms.extend(terms)
            section_hints.update(sections)
            phrase_hints.extend(phrases)
            if triggers == ["terrorism", "ata"]:
                prefer_ata = True

    # Dedupe while preserving order
    seen: set[str] = set()
    unique_extra: list[str] = []
    for term in extra_terms:
        key = term.lower()
        if key not in seen:
            seen.add(key)
            unique_extra.append(term)

    expanded_query = query
    if unique_extra:
        expanded_query = f"{query} {' '.join(unique_extra)}"

    base_terms = set(re.findall(r"[a-z0-9]+", q))
    base_terms.update(t.lower() for t in unique_extra)
    base_terms.discard("")

    return {
        "expanded_query": expanded_query,
        "terms": base_terms,
        "section_hints": section_hints,
        "phrase_hints": [p.lower() for p in phrase_hints],
        "prefer_ata": prefer_ata,
    }
