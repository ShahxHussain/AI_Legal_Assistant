# Status Tracker

Update this file **after every working step** (along with `CHANGE_LOG.md` and `DAILY_UPDATES.md`).

**Status legend:** `NOT_STARTED` | `IN_PROGRESS` | `BLOCKED` | `DONE` | `ON_HOLD`

| Step | Phase | Status | Start Date | Target Date | Actual End Date | Notes |
|---|---|---|---|---|---|---|
| 1 | Project Bootstrap & Documentation | DONE | 2026-06-10 | 2026-06-13 | 2026-06-10 | README, `docs/PRD.md`, `docs/ARCHITECTURE.md`, tracking folders. |
| 2 | Backend Foundation (FastAPI) | DONE | 2026-06-10 | 2026-06-11 | 2026-06-10 | `backend/` scaffold, venv, `.env.example`, `/health`, CORS, Dockerfile. |
| 3 | Legal Knowledge Base Collection | DONE | 2026-06-10 | - | 2026-06-10 | PPC, CrPC, ATA PDFs in `data/`; `data/README.md`. |
| 4 | Data Processing & Chunking Pipeline | DONE | 2026-06-10 | 2026-06-11 | 2026-06-10 | Section-aware `build_index.py` — 983 statute chunks with section/title/topic metadata. |
| 5 | Embeddings & FAISS Vector Index | DONE | 2026-06-10 | 2026-06-11 | 2026-06-10 | `all-MiniLM-L6-v2`; 983 vectors in `index.faiss` + `chunks.json`. |
| 6 | RAG Pipeline & LLM Integration | DONE | 2026-06-10 | 2026-06-12 | 2026-06-10 | Together.ai + production prompt v2; language detection. |
| 7 | Core Legal Q&A API | DONE | 2026-06-10 | 2026-06-12 | 2026-06-10 | `POST /ask` tested locally with sources. |
| 8 | Backend Deployment (Render) | NOT_STARTED | - | 2026-06-12 | - | Deploy stateless FastAPI + FAISS; public HTTPS URL for Flutter APK. |
| 9 | Flutter App Shell & Chat UI | DONE | 2026-06-10 | 2026-06-13 | 2026-06-17 | Home: Ask in chat · voice · Pro (beta). Chat sidebar, Pro info screen. |
| 9b | Court Companion Pro (planning + app info) | IN_PROGRESS | 2026-06-17 | - | - | `docs/COURT_COMPANION_PRO.md`, `ProScreen`, home card. Workspace not built. |
| 10 | Module 1 — Chat history (partial) | IN_PROGRESS | 2026-06-16 | - | - | Supabase conversations, sidebar, session follow-up; fresh chat from home. |
| 11 | Hackathon Submission Packaging | NOT_STARTED | - | 2026-06-13 | - | Devpost submission, demo script, screenshots, repo links. |

## Architecture decisions (MVP)

| Decision | Choice | Rationale |
|---|---|---|
| Vector store | **FAISS** (not ChromaDB) | ~983 section chunks; lightest deploy; file-based index |
| App database | **Supabase** (optional) | Conversations/messages for multi-turn context; Pro schema planned separately |
| LLM | **Together.ai** — `meta-llama/Meta-Llama-3-8B-Instruct-Lite` | `TOGETHER_API_KEY` in server env |
| Hosting | **Render** (or similar free tier) | Public URL required for Flutter APK |
| Client | **Flutter APK** (`Frontend/`) | Calls deployed backend over HTTPS |

## On Hold (Not in MVP)

| Module | Status | Notes |
|---|---|---|
| Firebase Auth & Firestore | ON_HOLD | No app data for MVP |
| Voice Support (STT / TTS) | ON_HOLD | Post-MVP accessibility feature |
| Legal Resource Center | ON_HOLD | Downloadable templates — post-MVP |
| Lawyer Recommendation | ON_HOLD | Category-based matching — post-MVP |
| Chat History | IN_PROGRESS | Sidebar + Supabase; agentic clarifying → Pro module |
| Court Companion Pro | IN_PROGRESS | Planning doc + Flutter info screen; workspace not built |
| Feedback System | DONE | 👍/👎 in chat; admin KPIs |
