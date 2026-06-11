"""Detect which language the assistant should reply in."""

import re

_URDU_SCRIPT = re.compile(r"[\u0600-\u06FF]")
_ROMAN_URDU = re.compile(
    r"\b("
    r"kya|kaise|kab|kahan|kyun|kyon|hai|hain|ho|hoga|hogi|hoti|hota|"
    r"ka|ki|ke|ko|se|mein|main|par|aur|yeh|woh|aap|mujhe|mera|meri|mere|"
    r"nahi|nahin|sawal|jawab|matlab|karna|karni|chahiye|baad|process|hota|hoti|"
    r"thanay|girftari|zamanat"
    r")\b",
    re.IGNORECASE,
)


def detect_response_language(question: str) -> str:
    """
    Return 'english', 'urdu_script', or 'roman_urdu'.
    """
    text = question.strip()
    if not text:
        return "english"

    urdu_script_chars = len(_URDU_SCRIPT.findall(text))
    if urdu_script_chars >= 3:
        return "urdu_script"

    roman_hits = len(_ROMAN_URDU.findall(text))
    english_words = len(re.findall(r"\b[A-Za-z]{2,}\b", text))

    if roman_hits >= 2 and roman_hits >= max(english_words * 0.15, 1):
        return "roman_urdu"

    return "english"


def language_instruction(lang: str) -> str:
    if lang == "urdu_script":
        return (
            "IMPORTANT: Jawab sirf Urdu script (اردو) mein likhein. "
            "English ya Roman Urdu bilkul na likhein."
        )
    if lang == "roman_urdu":
        return (
            "IMPORTANT: Jawab sirf Roman Urdu mein likhein (Latin letters). "
            "Urdu script (اردو) ya English sentences bilkul na likhein."
        )
    return (
        "IMPORTANT: Reply in English only. "
        "Do not use Urdu script or Roman Urdu."
    )


def language_system_rule(lang: str) -> str:
    if lang == "urdu_script":
        return (
            "MANDATORY LANGUAGE FOR THIS REPLY: URDU SCRIPT (اردو) ONLY. "
            "No English. No Roman Urdu."
        )
    if lang == "roman_urdu":
        return (
            "MANDATORY LANGUAGE FOR THIS REPLY: ROMAN URDU ONLY (Latin letters). "
            "No English sentences. No Urdu script."
        )
    return (
        "MANDATORY LANGUAGE FOR THIS REPLY: ENGLISH ONLY. "
        "No Urdu script. No Roman Urdu."
    )
