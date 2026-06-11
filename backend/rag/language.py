"""Detect and enforce the assistant's response language.

Supported: English, Urdu (script), Roman Urdu, Pashto, Punjabi, Sindhi, Balochi.
Auto-detection is reliable for English / Urdu script / Roman Urdu and for
Pashto & Sindhi script (they have distinctive characters). Punjabi (Shahmukhi)
and Balochi script look like Urdu, so users should pick them via the app's
language selector for guaranteed output.
"""

import re

SUPPORTED_LANGUAGES = {
    "english",
    "urdu_script",
    "roman_urdu",
    "pashto",
    "punjabi",
    "sindhi",
    "balochi",
}

DEFAULT_LANGUAGE = "urdu_script"

_ARABIC_SCRIPT = re.compile(r"[\u0600-\u06FF]")
# Characters unique (or near-unique) to Pashto orthography
_PASHTO_CHARS = re.compile(r"[\u067C\u0689\u0693\u0696\u069A\u06AB\u06BC\u06D0\u06CD\u0681\u0685]")
# Characters unique to Sindhi orthography
_SINDHI_CHARS = re.compile(r"[\u067B\u0680\u067A\u067D\u067F\u0684\u0683\u0687\u068A\u068C\u068D\u068F\u0699\u06A6\u06BB\u06B3\u06B1\u06FD\u06FE]")

_ROMAN_URDU = re.compile(
    r"\b("
    r"kya|kaise|kab|kahan|kyun|kyon|hai|hain|ho|hoga|hogi|hoti|hota|"
    r"ka|ki|ke|ko|se|mein|main|par|aur|yeh|woh|aap|mujhe|mera|meri|mere|"
    r"nahi|nahin|sawal|jawab|matlab|karna|karni|chahiye|baad|process|"
    r"thanay|girftari|zamanat"
    r")\b",
    re.IGNORECASE,
)

_ROMAN_PUNJABI = re.compile(
    r"\b("
    r"tusi|tussi|tuhanu|tuhada|tuhadi|sanu|assi|asi|saada|saadi|"
    r"kiven|kithe|kithon|haiga|haigi|painda|paindi|wekho|dasso|"
    r"changa|changi|menu|ohnu|ehnu|jandey|karde|kardi"
    r")\b",
    re.IGNORECASE,
)

_ROMAN_PASHTO = re.compile(
    r"\b("
    r"zama|staso|sta|munga|moong|tasu|taso|sanga|tsanga|"
    r"dera|der|khe|kha|wale|walay|chirta|charta|kawal|kawom|kawi|"
    r"raza|warza|shta|shte|na shta|zh|pohegi|pohezhi"
    r")\b",
    re.IGNORECASE,
)

_ROMAN_SINDHI = re.compile(
    r"\b("
    r"awhan|tawhan|tohan|asaan|asan jo|cha|chho|chaa|"
    r"aahe|aahin|aayo|wendo|wendi|kiyan|kean|"
    r"munhinjo|munhinji|panhinjo|panhinji|sandho"
    r")\b",
    re.IGNORECASE,
)


def detect_response_language(question: str, override: str | None = None) -> str:
    """
    Return one of: 'english', 'urdu_script', 'roman_urdu', 'pashto',
    'punjabi', 'sindhi', 'balochi'.

    `override` (from the app's language selector) wins over detection.
    """
    if override and override in SUPPORTED_LANGUAGES:
        return override

    text = question.strip()
    if not text:
        return "english"

    arabic_chars = len(_ARABIC_SCRIPT.findall(text))
    if arabic_chars >= 3:
        # Distinctive letters identify Pashto / Sindhi within Arabic script
        if len(_SINDHI_CHARS.findall(text)) >= 2:
            return "sindhi"
        if len(_PASHTO_CHARS.findall(text)) >= 2:
            return "pashto"
        # Punjabi (Shahmukhi) and Balochi look like Urdu — default to Urdu;
        # the user can force them via the language selector.
        return "urdu_script"

    english_words = len(re.findall(r"\b[A-Za-z]{2,}\b", text))

    punjabi_hits = len(_ROMAN_PUNJABI.findall(text))
    pashto_hits = len(_ROMAN_PASHTO.findall(text))
    sindhi_hits = len(_ROMAN_SINDHI.findall(text))
    urdu_hits = len(_ROMAN_URDU.findall(text))

    best_lang, best_hits = max(
        [
            ("punjabi", punjabi_hits),
            ("pashto", pashto_hits),
            ("sindhi", sindhi_hits),
            ("roman_urdu", urdu_hits),
        ],
        key=lambda x: x[1],
    )

    if best_hits >= 2 and best_hits >= max(english_words * 0.15, 1):
        # Roman Urdu shares many words with Roman Punjabi/Sindhi; require a
        # clear margin before picking a regional language over Roman Urdu.
        if best_lang != "roman_urdu" and best_hits < urdu_hits + 2:
            return "roman_urdu"
        return best_lang

    return "english"


_LANG_LABELS = {
    "english": "ENGLISH",
    "urdu_script": "URDU SCRIPT (اردو)",
    "roman_urdu": "ROMAN URDU (Latin letters)",
    "pashto": "PASHTO (پښتو script)",
    "punjabi": "PUNJABI (Shahmukhi script پنجابی)",
    "sindhi": "SINDHI (سنڌي script)",
    "balochi": "BALOCHI (بلوچی, Arabic script)",
}

_LANG_USER_NOTES = {
    "english": "Reply in English only. Do not use any other language.",
    "urdu_script": (
        "Jawab sirf Urdu script (اردو) mein likhein. "
        "English ya Roman Urdu bilkul na likhein."
    ),
    "roman_urdu": (
        "Jawab sirf Roman Urdu mein likhein (Latin letters). "
        "Urdu script (اردو) ya English sentences bilkul na likhein."
    ),
    "pashto": (
        "Reply ONLY in Pashto using Pashto (Arabic-derived) script. "
        "Do not reply in Urdu, English, or any other language."
    ),
    "punjabi": (
        "Reply ONLY in Punjabi using Shahmukhi (Arabic-derived) script. "
        "Do not reply in Urdu, English, or any other language."
    ),
    "sindhi": (
        "Reply ONLY in Sindhi using Sindhi (Arabic-derived) script. "
        "Do not reply in Urdu, English, or any other language."
    ),
    "balochi": (
        "Reply ONLY in Balochi using Arabic-derived script. "
        "Do not reply in Urdu, English, or any other language."
    ),
}


def language_instruction(lang: str) -> str:
    note = _LANG_USER_NOTES.get(lang, _LANG_USER_NOTES["english"])
    return f"IMPORTANT: {note}"


def language_system_rule(lang: str) -> str:
    label = _LANG_LABELS.get(lang, _LANG_LABELS["english"])
    return (
        f"MANDATORY LANGUAGE FOR THIS REPLY: {label} ONLY. "
        "Write the ENTIRE answer (including the disclaimer) in this language. "
        "Never mix languages. If you cannot write fluently in this language, "
        "still answer simply and clearly in it — do NOT switch to another language."
    )
