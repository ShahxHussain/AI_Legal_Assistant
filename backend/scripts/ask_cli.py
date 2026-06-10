"""Ask a legal question via the API and print answer + sources in the terminal."""

import argparse
import json
import sys
import urllib.error
import urllib.request

DEFAULT_URL = "http://127.0.0.1:8000/ask"


def ask(question: str, api_url: str = DEFAULT_URL) -> None:
    payload = json.dumps({"question": question}).encode("utf-8")
    req = urllib.request.Request(
        api_url,
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8")
        print(f"Error {exc.code}: {body}", file=sys.stderr)
        sys.exit(1)
    except urllib.error.URLError as exc:
        print(f"Cannot reach API at {api_url}", file=sys.stderr)
        print(f"  {exc.reason}", file=sys.stderr)
        print("Start the server: uvicorn main:app --reload --port 8000", file=sys.stderr)
        sys.exit(1)

    print("=" * 70)
    print("QUESTION")
    print("=" * 70)
    print(question)
    print()
    print("=" * 70)
    print("ANSWER")
    print("=" * 70)
    print(data.get("answer", ""))
    print()
    print("=" * 70)
    print(f"SOURCES ({len(data.get('sources', []))})")
    print("=" * 70)
    for i, src in enumerate(data.get("sources", []), start=1):
        doc = src.get("document", "unknown")
        section = src.get("section") or "n/a"
        excerpt = src.get("excerpt", "")
        print(f"\n[{i}] {doc}  |  Section: {section}")
        print("-" * 70)
        print(excerpt)
    print()
    print("=" * 70)
    print("DISCLAIMER")
    print("=" * 70)
    print(data.get("disclaimer", ""))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ask Court Companion from the terminal")
    parser.add_argument("question", help="Legal question to ask")
    parser.add_argument(
        "--url",
        default=DEFAULT_URL,
        help=f"API URL (default: {DEFAULT_URL})",
    )
    args = parser.parse_args()
    ask(args.question, args.url)
