"""Quick retrieval quality check."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from rag.embedder import Embedder
from rag.retriever import Retriever

QUESTIONS = [
    "What is an FIR?",
    "How can I apply for bail?",
    "What is Section 302 PPC?",
    "Can police arrest without a warrant?",
]


def main() -> None:
    r = Retriever(Embedder())
    r.load()
    for q in QUESTIONS:
        print("=" * 70)
        print("Q:", q)
        for i, c in enumerate(r.retrieve(q), 1):
            doc = c.document.replace(".pdf", "")[:40]
            sec = c.section or "n/a"
            preview = c.text[:100].replace("\n", " ")
            print(f"  [{i}] {doc} | sec {sec} | score {c.score:.3f}")
            print(f"      {preview}...")


if __name__ == "__main__":
    main()
