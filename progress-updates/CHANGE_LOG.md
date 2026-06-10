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

- `[2026-06-10] [Step 1] PRD and architecture documents added`
  - What changed: Created `docs/PRD.md` (goals, scope, user stories, requirements, demo script, risks) and `docs/ARCHITECTURE.md` (system diagrams, RAG pipeline, API spec, deployment, repo structure).
  - Why changed: Hackathon execution needs a single source of truth for product scope and technical design before backend implementation.
  - Impact: Team and judges can review MVP boundaries, API contract, and FAISS + FastAPI + Flutter deployment model in one place.
  - Related test(s): N/A
