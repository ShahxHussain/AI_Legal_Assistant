# Change Log

Track meaningful implementation changes in chronological order.

**Update rule:** After every implementation step, add an entry here and sync `STATUS_TRACKER.md` + `DAILY_UPDATES.md`.

## Format

- `[YYYY-MM-DD] [Step X] <short change title>`
  - What changed:
  - Why changed:
  - Impact:
  - Related test(s):

---

- `[2026-06-11] [Step 6] Multilingual support (6 languages + auto-detect)`
  - What changed: Extended `rag/language.py` to detect/enforce English, Urdu (script), Roman Urdu, Pashto, Punjabi (Shahmukhi), Sindhi, Balochi — script detection via distinctive Pashto/Sindhi characters, Roman detection via per-language keyword sets with Roman-Urdu margin rule. Added `language` override field to `/ask` (JSON) and `/analyze-document` (form). Generator methods accept `language` override. Prompts updated: language rules + disclaimer now cover all 7 reply languages. Flutter chat app bar got a language selector (Auto + 7 languages) passed with every request.
  - Why changed: Assistant must serve citizens in all major Pakistani languages; Punjabi/Balochi script is visually identical to Urdu so a manual selector complements auto-detection.
  - Impact: One chat face, auto-detect by default; users can force any supported language. Reply language is enforced via mandatory system rule + user-message instruction.
  - Related test(s): Inline detection test — English/Roman Urdu/Urdu script/Sindhi script/Pashto script/Roman Punjabi all detected correctly; overrides honored.

- `[2026-06-10] [Step -] Initial tracker setup`
  - What changed: Created `progress-updates/` folder with `CHANGE_LOG.md`, `DAILY_UPDATES.md`, and `STATUS_TRACKER.md`.
  - Why changed: To keep execution updates structured and visible across the hackathon build.
  - Impact: Improves planning, reviewability, and handoff clarity for Court Companion.
  - Related test(s): N/A

- `[2026-06-10] [Step 1] README restructured`
  - What changed: Reorganized root `README.md` with table of contents, heading hierarchy, tables, active vs. on-hold feature sections, and RAG workflow diagrams.
  - Why changed: Original README used repeated H1 headings and loose formatting; a clearer structure helps judges and contributors onboard faster.
  - Impact: Project scope, architecture, and tech stack are easier to scan; on-hold modules are clearly separated from MVP work.
  - Related test(s): N/A

- `[2026-06-10] [Step 1] Hackathon updates documented`
  - What changed: Restructured `Hackathon_updates/HACKATHON_THEME.md` and `shortlisting_mail.md` with dates, evaluation criteria, Devpost checklist, and Theme 3 mapping.
  - Why changed: Shortlisting mail was raw text; key deadlines (June 13, June 18) and action items needed to be scannable.
  - Impact: Round 2 requirements and Court Companion theme alignment are documented in-repo.
  - Related test(s): N/A

- `[2026-06-10] [Step 3] Legal knowledge base inventoried`
  - What changed: Analyzed `data/` PDFs (PPC, CrPC, ATA); added `data/README.md` with corpus stats, topic coverage, and ingestion plan.
  - Why changed: Team needed clarity on whether existing statutes are sufficient for RAG MVP.
  - Impact: ~500 pages / ~252K tokens confirmed adequate; indexing order defined (CrPC → PPC → ATA).
  - Related test(s): N/A

- `[2026-06-10] [Step -] MVP architecture finalized`
  - What changed: Decided on FAISS vector store, stateless FastAPI backend, no app database, Groq/Gemini LLM, Render deployment, Flutter APK → HTTPS API.
  - Why changed: User needs live backend for APK; no user/chat data required; free-tier hosting for hackathon.
  - Impact: Simplified stack (FAISS over ChromaDB/Postgres); Firebase, Urdu, and voice moved to on-hold; `STATUS_TRACKER.md` steps realigned.
  - Related test(s): N/A

- `[2026-06-10] [Step -] LLM provider set to Together.ai`
  - What changed: Selected Together.ai with model `meta-llama/Meta-Llama-3-8B-Instruct-Lite`; updated `docs/PRD.md`, `docs/ARCHITECTURE.md`, and architecture decisions in `STATUS_TRACKER.md`.
  - Why changed: User has Together.ai API access; Llama 3 8B Instruct Lite fits RAG answer generation on free/low-cost inference.
  - Impact: Backend generator will use `together` Python SDK; env var `TOGETHER_API_KEY` on Render; Groq/Gemini removed from MVP plan.
  - Related test(s): N/A

- `[2026-06-10] [Step 9] Flutter UI overhaul — ChatGPT-style + source popups`
  - What changed: Redesigned chat UI (Glean/ChatGPT style); `ValueKey` per message fixes stale sources; source chips with bottom-sheet popup; full chunk `text` in API sources; suggestion chips; `SelectableText` for full answers.
  - Why changed: UI answers/sources looked generic vs CLI; same sources reused due to ListView widget recycling; excerpts were truncated in bubbles.
  - Impact: UI now shows same API payload as CLI; tap source chip for full legal excerpt popup.
  - Related test(s): `flutter analyze` clean; restart backend + hot restart Flutter.

- `[2026-06-10] [Step 9] Flutter frontend in Frontend/`
  - What changed: Created `Frontend/` Flutter app — chat screen, `ApiService` (`/health`, `/ask`), source citations UI, `API_BASE_URL` dart-define, Android INTERNET + cleartext for dev, `Frontend/README.md`.
  - Why changed: User requested separate Frontend folder wired to RAG backend for APK demo.
  - Impact: Mobile chat client ready; emulator default `http://10.0.2.2:8000`; release APK needs deployed URL via `--dart-define`.
  - Related test(s): `flutter analyze` clean; widget test loads Court Companion title.

- `[2026-06-10] [Step 6] Prompt v2 — detailed answers + strict language`
  - What changed: Expanded `rag/prompts.py` for detailed realistic answers (120–500 words by complexity); added `rag/language.py` for English/Urdu detection; generator enforces language-only replies and `max_tokens=900`.
  - Why changed: User wanted proper detailed answers and strict rule—English question → English only, Urdu → Urdu only.
  - Impact: Multi-part and scenario questions get structured paragraphs; no language mixing in single answer.
  - Related test(s): `ask_cli.py` English FIR + Roman Urdu FIR questions.

- `[2026-06-10] [Step 6] Production prompt — Court Companion`
  - What changed: Replaced `rag/prompts.py` with production system prompt (bilingual, voice-friendly, safety rules, RAG grounding); tuned generator (`max_tokens=512`, language mirroring); branding **Court Companion | AI Legal Bilingual Assistant**.
  - Why changed: User provided reference persona for citizen-facing, voice-ready legal explanations; product name remains Court Companion.
  - Impact: Shorter spoken-style answers; Urdu/English mix; stricter context-only answers; safer refusal patterns.
  - Related test(s): Manual `ask_cli.py` — Urdu FIR + English arrest questions.

- `[2026-06-10] [Steps 2–7] Backend RAG implementation`
  - What changed: Added `backend/` with FastAPI (`/health`, `/ask`), `scripts/build_index.py`, RAG modules (embedder, retriever, generator), `requirements.txt`, `.env.example`, `Dockerfile`; built FAISS index (501 chunks from 3 PDFs).
  - Why changed: Start implementation — stateless RAG API for Flutter APK to call.
  - Impact: Local API runs on port 8000; `/ask` returns Together.ai answers with source citations; ready for Render deploy.
  - Related test(s): `GET /health` → 200, `index_loaded: true`; `POST /ask` "What is an FIR?" → answer + 5 sources.

- `[2026-06-10] [Step 4] Section-aware chunking + index rebuild`
  - What changed: Rewrote `scripts/build_index.py` to split PDFs by statute section boundaries (not fixed word windows); added `section`, `title`, `topic` metadata; rebuilt FAISS index (**983 chunks**, was 501); hybrid retriever returns `title` in sources; Flutter source chips show section titles.
  - Why changed: Fixed-word chunking bundled multiple sections and TOC pages, causing irrelevant sources for FIR, bail, §302, etc.
  - Impact: Retrieval now returns correct sections (e.g. CrPC §154 for FIR, PPC §302 for murder, §496–498 for bail); 981/983 chunks have section metadata; 261 PPC chunks topic-tagged.
  - Related test(s): `scripts/test_retrieval.py` — FIR/bail/302/arrest all rank correct statute first.

- `[2026-06-10] [Step 1] PRD and architecture documents added`
  - What changed: Created `docs/PRD.md` (goals, scope, user stories, requirements, demo script, risks) and `docs/ARCHITECTURE.md` (system diagrams, RAG pipeline, API spec, deployment, repo structure).
  - Why changed: Hackathon execution needs a single source of truth for product scope and technical design before backend implementation.
  - Impact: Team and judges can review MVP boundaries, API contract, and FAISS + FastAPI + Flutter deployment model in one place.
  - Related test(s): N/A
