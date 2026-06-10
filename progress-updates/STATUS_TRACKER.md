# Status Tracker

Update this file **after every working step** (along with `CHANGE_LOG.md` and `DAILY_UPDATES.md`).

**Status legend:** `NOT_STARTED` | `IN_PROGRESS` | `BLOCKED` | `DONE` | `ON_HOLD`

| Step | Phase | Status | Start Date | Target Date | Actual End Date | Notes |
|---|---|---|---|---|---|---|
| 1 | Project Bootstrap & Documentation | DONE | 2026-06-10 | 2026-06-13 | 2026-06-10 | README, `docs/PRD.md`, `docs/ARCHITECTURE.md`, `progress-updates/`, `Hackathon_updates/`. |
| 2 | Backend Foundation (FastAPI) | NOT_STARTED | - | 2026-06-11 | - | Scaffold API app, env config, `/health` endpoint, dev run scripts. |
| 3 | Legal Knowledge Base Collection | DONE | 2026-06-10 | - | 2026-06-10 | PPC, CrPC, ATA PDFs in `data/`; `data/README.md` inventory and topic coverage. |
| 4 | Data Processing & Chunking Pipeline | NOT_STARTED | - | 2026-06-11 | - | Extract PDFs, normalize text, chunk (500–1000 tokens, 50–100 overlap). |
| 5 | Embeddings & FAISS Vector Index | NOT_STARTED | - | 2026-06-11 | - | Sentence Transformers (`all-MiniLM-L6-v2`); persist `index.faiss` + `chunks.json`. |
| 6 | RAG Pipeline & LLM Integration | NOT_STARTED | - | 2026-06-12 | - | Retrieve → context → prompt → Groq/Gemini; API keys server-side only. |
| 7 | Core Legal Q&A API | NOT_STARTED | - | 2026-06-12 | - | `POST /ask` with grounded answers and source citations. |
| 8 | Backend Deployment (Render) | NOT_STARTED | - | 2026-06-12 | - | Deploy stateless FastAPI + FAISS; public HTTPS URL for Flutter APK. |
| 9 | Flutter App Shell & Chat UI | NOT_STARTED | - | 2026-06-13 | - | Chat UI wired to deployed API; release APK build. |
| 10 | Testing & Quality Assurance | NOT_STARTED | - | 2026-06-13 | - | Smoke tests for `/health`, `/ask`, and APK → API flow. |
| 11 | Hackathon Submission Packaging | NOT_STARTED | - | 2026-06-13 | - | Devpost submission, demo script, screenshots, repo links. |

## Architecture decisions (MVP)

| Decision | Choice | Rationale |
|---|---|---|
| Vector store | **FAISS** (not ChromaDB) | ~400 chunks; lightest deploy; file-based index |
| App database | **None** | Stateless API; no user/chat storage needed |
| LLM | **Groq or Gemini** (free tier) | No GPU hosting; key in server env vars |
| Hosting | **Render** (or similar free tier) | Public URL required for Flutter APK |
| Client | **Flutter APK** | Calls deployed backend over HTTPS |

## On Hold (Not in MVP)

| Module | Status | Notes |
|---|---|---|
| Firebase Auth & Firestore | ON_HOLD | No app data for MVP |
| Multilingual (EN / Urdu) | ON_HOLD | English-first for Round 2 demo |
| Voice Support (STT / TTS) | ON_HOLD | Post-MVP accessibility feature |
| Legal Resource Center | ON_HOLD | Downloadable templates — post-MVP |
| Lawyer Recommendation | ON_HOLD | Category-based matching — post-MVP |
| Chat History | ON_HOLD | Requires auth + database |
| Feedback System | ON_HOLD | Ratings and reports — post-MVP |
