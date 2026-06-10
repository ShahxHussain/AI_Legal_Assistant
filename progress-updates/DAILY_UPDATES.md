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
  - **LLM:** Groq or Gemini free tier; API key server-side
  - **Deploy:** Render (or similar) for public HTTPS URL
  - **Client:** Flutter APK calls deployed backend
  - Legal Resource Center, Lawyer Recommendation, Chat History, Feedback on hold
  - Multilingual and voice support on hold for Round 2 demo
- Next action: Step 2 — Bootstrap FastAPI backend with `/health` endpoint and project layout
