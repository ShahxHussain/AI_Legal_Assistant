"""Detect greetings vs legal questions — avoid irrelevant sources on small talk."""

from __future__ import annotations

import re

from rag.query_analysis import LEGAL_TOPIC_HINTS, extract_section_numbers

# Tokens that indicate a real legal question
_LEGAL_SIGNALS: set[str] = {
    "fir",
    "bail",
    "zamanat",
    "arrest",
    "girftari",
    "custody",
    "warrant",
    "police",
    "court",
    "magistrate",
    "murder",
    "qatl",
    "theft",
    "chori",
    "fraud",
    "cheating",
    "ppc",
    "crpc",
    "ata",
    "terrorism",
    "section",
    "offence",
    "offense",
    "crime",
    "criminal",
    "complaint",
    "investigation",
    "trial",
    "punishment",
    "penal",
    "procedure",
    "cognizable",
    "cognisable",
    "hurt",
    "assault",
    "forgery",
    "defamation",
    "riot",
    "law",
    "legal",
    "statute",
    "thanay",
    "thana",
    "lawyer",
    "vakeel",
}

# Legal keywords in Urdu / Pashto / Sindhi / Punjabi script (Arabic-derived)
_LEGAL_SIGNALS_SCRIPT = re.compile(
    r"چوری|ضمانت|گرفتار|قتل|پولیس|عدالت|دفعہ|دفعه|وکیل|مقدمہ|مقدمه|سزا|جرم|"
    r"قانون|تفتیش|تحقیقات|تھانہ|تھانے|ایف\s*آئی\s*آر|شکایت|ملزم|جیل|حراست|"
    r"وارنٹ|ڈکیتی|دھوکہ|فراڈ|اغوا|تعزیرات|ضابطہ|فوجداری|انصاف|حقوق"
)

_ARABIC_SCRIPT = re.compile(r"[\u0600-\u06FF]")

_CONVERSATIONAL_PATTERNS: list[re.Pattern[str]] = [
    re.compile(p, re.I)
    for p in (
        r"^(hi|hello|hey|hola|salam|assalam|aoa|adaab|salam-o-alaikum|ahan|acha|achha)\b",
        r"\bhow can you help\b",
        r"\bhow do you help\b",
        r"\bwhat can you do\b",
        r"\bwhat do you do\b",
        r"\bwho are you\b",
        r"\bwhat are you\b",
        r"\btell me about yourself\b",
        r"\bthank(s| you)\b",
        r"\bshukriya\b",
        r"\b(bye|goodbye|see you)\b",
        r"\bgood (morning|evening|afternoon|night)\b",
        r"\bnice to meet\b",
        r"\bhow are you\b",
        r"\bkaise ho\b",
        r"\bkya hal\b",
        r"\b(barhay|bohat|bahut)\s+tez\b",
        r"\b(wah|waah|great|awesome|nice|good)\s+(job|bot|app|assistant)\b",
        r"\baap\s+(tw|toh|tau|bhi)?\s*(tez|fast|achhay|achhe)\b",
        r"\b(zabardast|kamaal|kamal|shandar)\b",
        r"^(سلام|السلام|آداب|ہیلو|ہائے)",
        r"شکریہ|مہربانی",
    )
]


def _has_legal_topic_trigger(query: str) -> bool:
    q = query.lower()
    for triggers, *_ in LEGAL_TOPIC_HINTS:
        if any(t in q for t in triggers):
            return True
    return False


def is_legal_query(query: str) -> bool:
    """True when the message asks about law — should run RAG and may show sources."""
    q = query.lower().strip()
    if not q:
        return False

    if extract_section_numbers(query):
        return True

    if _has_legal_topic_trigger(query):
        return True

    if _LEGAL_SIGNALS_SCRIPT.search(query):
        return True

    words = set(re.findall(r"[a-z0-9]+", q))
    if words & _LEGAL_SIGNALS:
        return True

    return False


def is_conversational_query(query: str) -> bool:
    """Greetings, thanks, or meta questions — no statute sources needed."""
    if is_legal_query(query):
        return False

    q = query.lower().strip()
    if any(pat.search(q) for pat in _CONVERSATIONAL_PATTERNS):
        return True

    # Short casual messages without legal terms (compliments, small talk).
    # Skip this heuristic for Arabic-script text — our legal-keyword coverage
    # there is thin, so short Urdu/Pashto/Sindhi questions could be real
    # legal queries that we'd wrongly treat as small talk.
    if _ARABIC_SCRIPT.search(q):
        return False

    word_count = len(q.split())
    if word_count <= 10:
        return True

    return False
