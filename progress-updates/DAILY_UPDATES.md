# Daily Updates

Record what was done each day in short bullets.

**Update rule:** Add or extend the current day's section after every working step.

## Template

### YYYY-MM-DD

- Steps worked:
- Completed:
- Blockers:
- Decisions made:
- Next action:

---

### 2026-06-10

- Steps worked: Steps 1, 3; architecture planning; progress tracking
- Completed:
  - Restructured root `README.md` (TOC, tables, active vs. on-hold features)
  - Created and maintained `progress-updates/` (changelog, daily log, status tracker)
  - Restructured `Hackathon_updates/` (theme mapping, shortlisting mail, June 13 deadline)
  - Inventoried `data/` corpus — PPC, CrPC, ATA PDFs (~252K tokens)
  - Added `data/README.md` (inventory, topic coverage, ingestion plan)
  - Added `docs/PRD.md` (product requirements, MVP scope, user stories, demo script)
  - Added `docs/ARCHITECTURE.md` (system design, RAG pipeline, API spec, deployment)
- Blockers: None
- Decisions made:
  - **Vector store:** FAISS (not ChromaDB or traditional DB)
  - **No app database:** stateless API only (Firebase on hold)
  - **LLM:** Together.ai — `meta-llama/Meta-Llama-3-8B-Instruct-Lite`; `TOGETHER_API_KEY` server-side
  - **Deploy:** Render (or similar) for public HTTPS URL
  - **Client:** Flutter APK calls deployed backend
  - Legal Resource Center, Lawyer Recommendation, Chat History, Feedback on hold
  - Multilingual and voice support on hold for Round 2 demo
  - Scaffolded full `backend/` (FastAPI, FAISS, Together.ai RAG pipeline)
  - Built FAISS index: 501 chunks from PPC, CrPC, ATA PDFs
  - Verified locally: `/health` OK, `/ask` returns FIR answer with sources
  - Built `Frontend/` Flutter app (chat UI, API service, sources display)
  - Rebuilt index with **section-aware chunking** (983 chunks); retrieval now hits correct PPC/CrPC sections
  - Flutter source UI shows optional statute `title` from API
- Next action: Restart backend + hot-restart Flutter; Step 8 — Deploy to Render; Step 10 — E2E test; Step 11 — Devpost
