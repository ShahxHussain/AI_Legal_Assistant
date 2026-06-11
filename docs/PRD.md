# Product Requirements Document (PRD)

**Product:** Court Companion – AI Legal Assistant  
**Version:** 1.0 (Hackathon MVP)  
**Last updated:** 2026-06-10  
**Hackathon:** AI for Civic Innovation 2026 — Theme 3: Open Data & Access to Information

---

## 1. Executive Summary

Court Companion is an AI-powered legal information assistant that helps Pakistani citizens understand criminal law in plain language. Users ask questions via a Flutter mobile app; a deployed backend retrieves relevant statute text and generates simplified, source-grounded answers using RAG.

**MVP goal (by June 13, 2026):** A working demo — Flutter APK connected to a live FastAPI backend that answers criminal-law questions grounded in PPC, CrPC, and ATA sources.

> **Disclaimer:** Court Companion provides legal information only. It is not a substitute for licensed legal counsel.

---

## 2. Problem Statement

Millions of citizens in Pakistan cannot easily understand:

- Legal rights after arrest
- FIR registration and procedure
- Bail processes
- Pakistan Penal Code (PPC) sections (e.g., 302, 379, 420)

**Root causes:** Complex legal language, limited legal literacy, unaffordable consultation, and no AI assistant tailored to Pakistan's statutes.

**Impact:** Misinformation, delayed legal action, and reduced access to justice.

---

## 3. Goals & Success Metrics

### 3.1 Primary goals

| Goal | Description |
|------|-------------|
| **Accessibility** | Make public legal information reachable via a mobile app |
| **Understandability** | Translate statute language into citizen-friendly explanations |
| **Trust** | Ground every answer in retrieved legal text with source citations |
| **Demo readiness** | Ship a functional prototype for Round 2 screening (June 13) |

### 3.2 Success metrics (MVP)

| Metric | Target |
|--------|--------|
| API uptime | `/health` returns 200 on deployed backend |
| Response quality | Answers cite at least 1 relevant source chunk |
| Demo questions | 5+ sample questions answered correctly (FIR, arrest, bail, §302, theft) |
| End-to-end flow | Flutter APK → HTTPS API → answer displayed on device |
| Latency | < 15s per question on free-tier hosting (cold start acceptable) |

---

## 4. Target Users

### Primary

- General citizens seeking criminal-law awareness
- Students learning Pakistan's legal framework
- Rural and low-literacy communities (future: voice/Urdu)

### Secondary (post-MVP)

- Legal aid NGOs and community support groups
- Legal researchers

---

## 5. Scope

### 5.1 In scope (MVP)

| ID | Feature | Priority | Description |
|----|---------|----------|-------------|
| F1 | Legal Q&A (text) | P0 | User types a question; receives a simplified answer |
| F2 | RAG retrieval | P0 | Answers grounded in PPC, CrPC, ATA PDF corpus |
| F3 | Source citations | P0 | Response includes statute/source references |
| F4 | REST API | P0 | `GET /health`, `POST /ask` on deployed backend |
| F5 | Flutter chat UI | P0 | Minimal chat screen wired to live API |
| F6 | Release APK | P0 | Build installable Android APK for demo |
| F7 | Backend deployment | P0 | Public HTTPS URL (Render or equivalent) |

### 5.2 Out of scope (MVP — on hold)

| Feature | Reason |
|---------|--------|
| User accounts / Firebase Auth | No app data required for MVP |
| Chat history persistence | Requires database; stateless API for now |
| Urdu / multilingual | English-first for Round 2; add post-MVP |
| Voice (STT / TTS) | Accessibility feature; post-MVP |
| Legal document downloads | Resource center on hold |
| Lawyer recommendations | On hold |
| Feedback / ratings | On hold |

---

## 6. User Stories

| ID | As a… | I want to… | So that… | Priority |
|----|-------|------------|----------|----------|
| US-1 | Citizen | Ask "What is an FIR?" in plain English | I understand how to report a crime | P0 |
| US-2 | Citizen | Ask about my rights after arrest | I know what police can and cannot do | P0 |
| US-3 | Citizen | Ask "What is Section 302 PPC?" | I understand murder charges in simple terms | P0 |
| US-4 | Citizen | Ask how to apply for bail | I know the procedural basics | P0 |
| US-5 | Citizen | See which law the answer came from | I can trust the response | P0 |
| US-6 | Judge / reviewer | Open the APK and ask a live question | I can verify a working prototype | P0 |

---

## 7. Functional Requirements

### 7.1 Mobile app (Flutter)

| Req ID | Requirement |
|--------|-------------|
| APP-1 | Display a chat-style interface with message input |
| APP-2 | Send user questions to the deployed backend API over HTTPS |
| APP-3 | Display AI response and source citations in the chat |
| APP-4 | Show loading state while waiting for API response |
| APP-5 | Show error message if API is unreachable |
| APP-6 | Use configurable API base URL (dev vs production) |
| APP-7 | Build release APK for Android distribution |

### 7.2 Backend API (FastAPI)

| Req ID | Requirement |
|--------|-------------|
| API-1 | `GET /health` — returns service status and index readiness |
| API-2 | `POST /ask` — accepts `{ "question": string }`, returns answer + sources |
| API-3 | Embed user question using Sentence Transformers |
| API-4 | Retrieve top-K relevant chunks from FAISS index |
| API-5 | Construct LLM prompt using retrieved context only |
| API-6 | Return structured JSON: `answer`, `sources[]`, `disclaimer` |
| API-7 | Together.ai API key (`TOGETHER_API_KEY`) stored in server env only |
| API-8 | CORS enabled for Flutter web (optional); APK uses direct HTTPS |

### 7.3 Knowledge base & RAG

| Req ID | Requirement |
|--------|-------------|
| RAG-1 | Ingest PPC, CrPC, and ATA PDFs from `data/` |
| RAG-2 | Chunk documents (500–1000 tokens, 50–100 overlap) |
| RAG-3 | Build FAISS index with `all-MiniLM-L6-v2` embeddings |
| RAG-4 | Persist `index.faiss` + `chunks.json` for server startup load |
| RAG-5 | Top-K retrieval (default K=5) per query |
| RAG-6 | LLM instructed to answer only from provided context |

---

## 8. Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| **Cost** | Free-tier hosting; Together.ai API for LLM inference |
| **Security** | No secrets in Flutter APK; HTTPS only in production |
| **Statelessness** | No database; each request is independent |
| **Maintainability** | Pre-built index; no PDF reprocessing on every deploy |
| **Legal safety** | Every response includes informational disclaimer |
| **Accuracy** | Prefer "I don't have enough information" over hallucination |

---

## 9. Sample Demo Script

Questions to validate during demo and judging:

1. What is an FIR?
2. What are my rights after arrest?
3. What is Section 302 of the Pakistan Penal Code?
4. How can I apply for bail?
5. What is the punishment for theft under PPC?

---

## 10. Hackathon Alignment

| Criterion | How Court Companion addresses it |
|-----------|----------------------------------|
| Theme 3: Access to Information | Makes statute text accessible and understandable |
| Narrow problem | Criminal law awareness only — not full legal ecosystem |
| Specific audience | Pakistani citizens without legal training |
| Working prototype | APK + live RAG API |
| Innovation | RAG over Pakistani statutes with source citations |

**Key dates:**

| Event | Date |
|-------|------|
| Round 2 submission | June 13, 2026 |
| Final judging | June 18, 2026 |

---

## 11. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Free-tier backend cold start | Slow first request | Show loading UI; warm up before demo |
| LLM hallucination | Incorrect legal info | Strict RAG prompt; cite sources; disclaimer |
| PDF text extraction noise | Poor retrieval | Normalize whitespace; section-aware chunking |
| Render free tier limits | Downtime | Document backup host; test before submission |
| APK can't reach localhost | Broken demo | Always use deployed HTTPS URL in release build |

---

## 12. Future Roadmap (Post-MVP)

- Urdu language support
- Voice input/output (STT/TTS)
- Firebase auth and chat history
- Legal resource downloads
- Lawyer recommendations by category
- Constitutional, civil, and family law expansion

---

## 13. Open Questions

| # | Question | Owner | Status |
|---|----------|-------|--------|
| 1 | LLM provider | Dev | **Resolved** — Together.ai, `meta-llama/Meta-Llama-3-8B-Instruct-Lite` |
| 2 | Exact Render service plan? | Dev | Open |
| 3 | Devpost official URL? | Team | Pending organizer email |

---

## 14. References

- [README.md](../README.md) — Project overview
- [ARCHITECTURE.md](./ARCHITECTURE.md) — Technical design
- [data/README.md](../data/README.md) — Knowledge base inventory
- [Hackathon_updates/HACKATHON_THEME.md](../Hackathon_updates/HACKATHON_THEME.md) — Theme alignment
