"""Probe latency / reasoning behaviour of the configured Together model."""

import os
import sys
import time

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from dotenv import load_dotenv

load_dotenv()

from together import Together

client = Together()
MODEL = os.environ["LLM_MODEL"]
MSGS = [{"role": "user", "content": "What is an FIR in Pakistan? Answer in 2 sentences."}]

for kwargs in [{"reasoning_effort": "none"}, {"reasoning_effort": "low"}, {}]:
    label = kwargs.get("reasoning_effort", "default")
    try:
        t0 = time.time()
        r = client.chat.completions.create(
            model=MODEL, messages=MSGS, max_tokens=400, **kwargs
        )
        dt = time.time() - t0
        m = r.choices[0].message
        reasoning = getattr(m, "reasoning", None) or ""
        print(
            f"{label:>8} -> {dt:5.1f}s | content={len(m.content or '')} chars "
            f"| reasoning={len(reasoning)} chars | tokens={r.usage.completion_tokens}"
        )
    except Exception as exc:
        print(f"{label:>8} -> ERROR: {str(exc)[:200]}")
