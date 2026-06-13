# Court Companion — Screening Phase Submission

**Project:** Court Companion | AI Legal Multilingual Assistant  
**Theme:** Open Data & Access to Information / Technology for Civic Good  
**Team:** *(add team name)*  
**Repository:** *(add GitHub link)*  
**Live backend:** `https://ai-legal-assistant-fes8.onrender.com`  
**Demo:** Flutter APK (Android) + Web (Chrome)

---

## 1. Problem & Solution (Brief)

**Problem:** Most citizens in Pakistan cannot easily understand criminal law, FIR procedures, bail rights, or PPC/CrPC sections — especially under pressure, in Urdu/regional languages, or without affordable legal help.

**Solution:** Court Companion is an AI legal information assistant that answers questions in **plain language**, grounded in **verified Pakistani statutes** (PPC, CrPC, ATA) via **RAG** — not generic AI guesses. Available through **text chat** and **voice**, in **7 languages**.

> *Disclaimer: Court Companion provides legal information only. It does not replace a qualified lawyer.*

---

## 2. AI Tools, Models & Techniques

### What we are using (feasibility & validation phase)

We are actively testing models through **Together.ai** to answer one question honestly:

> *Are we on the right track? Is this feasible at hackathon scale — and beyond?*

| Layer | Tool / Model | Role | Status |
|-------|----------------|------|--------|
| **LLM (answers)** | `google/gemma-4-31B-it` | Legal answer generation from retrieved context | **Implemented & testing** |
| **LLM (translation)** | `meta-llama/Meta-Llama-3-8B-Instruct-Lite` | Translate non-English queries → English before search | **Implemented** |
| **Embeddings** | `all-MiniLM-L6-v2` (sentence-transformers) | Vectorize statute chunks for retrieval | **Implemented** |
| **Vector search** | **FAISS** | Hybrid retrieval over 983 section-aware chunks | **Implemented** |
| **Technique** | **RAG** (Retrieval-Augmented Generation) | Ground every answer in PPC / CrPC / ATA text | **Implemented** |
| **Technique** | Section-aware chunking + metadata | Preserve section numbers, titles, topics | **Implemented** |
| **Technique** | Translate-before-retrieve | Urdu/Pashto/Sindhi queries hit English-only index correctly | **Implemented** |
| **Technique** | Streaming NDJSON (`/ask/stream`) | Real-time answer display in chat & voice | **Implemented** |
| **Technique** | Output guard | Sanitize LLM output; preserve Urdu punctuation & markdown | **Implemented** |
| **Voice (STT)** | `speech_to_text` | Microphone input (English) | **Implemented** |
| **Voice (TTS)** | Browser Speech API (web) / `flutter_tts` (Android) | Speak answers as they stream | **Implemented** |

### Why AI is appropriate here

- Legal statutes are long, dense, and multilingual — keyword search alone fails.
- Citizens ask in natural language; **RAG + LLM** retrieves the right section first, then explains it simply.
- **Translation + retrieval** makes an English-indexed corpus usable in Urdu, Pashto, Sindhi, and more.

### Current focus

We are **not claiming a final production model choice yet**. We are validating:

- Answer quality across languages (especially Urdu script)
- Latency on free-tier hosting (Render)
- Whether Gemma 4 31B is worth the cost vs. smaller models for civic-scale deployment

---

## 3. Progress Updates (As the Project Developed)

| Phase | What was done |
|-------|----------------|
| **Week 1 — Foundation** | FastAPI backend, legal PDF corpus (PPC, CrPC, ATA), section-aware indexing → **983 FAISS chunks** |
| **Week 1 — RAG pipeline** | Together.ai integration, `/ask` + `/health`, source citations, disclaimer |
| **Week 2 — Multilingual** | 7 response languages; translate-before-retrieve; language selector in Flutter |
| **Week 2 — UI** | Clean Flutter app: Home, Chat (streaming), Info; Urdu-first design |
| **Week 2 — Voice** | Voice screen: mic input, streaming answers, speak-as-you-stream TTS |
| **Week 2 — Deploy** | Backend on **Render**; **release APK** points to production URL automatically |
| **Now — Screening** | Feasibility testing with Together.ai models; polishing demo & submission materials |

---

## 4. Implemented vs Planned

### ✅ Implemented (working prototype)

| Feature | Details |
|---------|---------|
| **Text chat** | Streaming answers, source chips, markdown formatting |
| **7 text languages** | English, Urdu (script), Roman Urdu, Pashto, Punjabi, Sindhi, Balochi |
| **1 voice language** | English input + spoken output (other languages: coming soon) |
| **Document upload** | PDF/TXT analysis via `/analyze-document` |
| **Legal corpus** | PPC, CrPC, ATA — 983 indexed chunks |
| **RAG pipeline** | Hybrid retrieval, section metadata, output guard |
| **Backend API** | `/health`, `/ask`, `/ask/stream`, deployed on Render |
| **Flutter client** | Web + **Android APK** (release build uses Render URL) |
| **API status** | Online/Offline badge in chat & voice screens |

### 🔜 Planned (post-screening / roadmap)

| Feature | Details |
|---------|---------|
| **Admin dashboard** | Usage analytics — active users, sessions, language breakdown |
| **Feedback per answer** | 👍 / 👎 after each conversation → measure real-world helpfulness |
| **Impact metrics** | Charts: questions asked, satisfaction rate, top topics (FIR, bail, theft…) |
| **Voice — all 7 languages** | STT + TTS for Urdu, Roman Urdu, Pashto, Punjabi, Sindhi, Balochi |
| **Conversational memory** | Chat history preserved; context carried across turns |
| **Agentic follow-ups** | Assistant asks clarifying questions when input is incomplete |
| **Open source** | Public repo + contribution guidelines |
| **Multi-instance deployment** | Redundant hosting so downtime is minimized; always accessible |
| **Auth & history** | User accounts + saved conversations (Firebase — designed, not built yet) |

### ⚠️ Constraints (honest)

- No dedicated funding yet — relying on **free / minimal-cost** resources (Render free tier, Together.ai API credits).
- First request after idle can be slow (~30s) while Render wakes up.
- Model choice still under evaluation — quality vs. cost vs. latency.

---

## 5. MUST Answers — Dependencies & Feasibility

*(Submission Guidelines — s1: So you have a ground-breaking idea, now what?)*

### What problem are you fixing?

Citizens cannot access understandable legal information when they need it most — especially in regional languages and under stress.

### What are your dependencies?

| Dependency | What we rely on | Risk if it changes |
|------------|-----------------|---------------------|
| **Together.ai** | LLM + API for generation & translation | Model deprecation → swap model name in config; API key rotation |
| **Render** | Free-tier HTTPS hosting for FastAPI + FAISS | Cold starts; may need paid tier or second provider for uptime |
| **sentence-transformers** | Local embeddings (`all-MiniLM-L6-v2`) | Model is pinned; index would need rebuild if changed |
| **FAISS index** | File-based vector store (983 chunks) | Rebuilt from `build_index.py` if corpus changes |
| **Flutter** | Cross-platform client (APK + web) | Standard; no vendor lock-in |

**E-g. What AI model are you relying on?**  
Currently testing **`google/gemma-4-31B-it`** for answers and **`Meta-Llama-3-8B-Instruct-Lite`** for query translation — both via Together.ai. We are evaluating whether this stack is the right balance of quality, speed, and cost.

**Will any update break it?**  
- LLM model swaps are config-only (`LLM_MODEL` in `.env`).  
- Translation has a **fallback**: if translation fails, the original query is used.  
- FAISS index is versioned in-repo; rebuild script is documented.  
- Main risk: **API pricing / rate limits** on free tiers — mitigated by caching common questions later.

### How novel is the data?

- Not generic web scraping — a **curated corpus** of Pakistani criminal statutes (PPC, CrPC, ATA).
- **Section-aware chunking** with metadata (section number, document, topic) — not naive paragraph splits.
- **983 chunks** indexed with legal structure preserved.
- Multilingual **query path** (translate → retrieve → answer in user's language) tailored to Pakistan's language landscape.

### Can anyone replicate it in a month?

- A **basic ChatGPT wrapper** — yes, in days.
- Our stack — **curated legal RAG + 7-language pipeline + voice + APK + deployed API** — would take meaningful effort: legal corpus preparation, indexing pipeline, multilingual prompts, Flutter app, and hosting. The **legal data curation and section-aware indexing** are the harder part to copy quickly.

---

## 6. Motivation — Why We Are Here

*(Submission Guidelines — s2: More Advice)*

### Why are we participating?

This hackathon is a chance to turn a **personal frustration** into something **useful for everyone**.

### Our story

At one point, some of us had an unsettling experience during travel — we were stopped and questioned in a way that felt intimidating. The officer brought up **legal sections, offence numbers, and procedural language** we did not fully understand. For ordinary citizens who are not lawyers, that moment is confusing and frightening. You want nothing more than to **resolve the situation peacefully and move on** — but you are not sure what your rights are, what the cited laws actually mean, or how to respond calmly.

We are **not making accusations** against any institution; many officers serve the public with integrity. But that experience stayed with us. It showed how easily a **lack of legal literacy** can leave ordinary people feeling powerless — even when they have done nothing wrong.

When we saw the **AI for Civic Innovation Hackathon**, it clicked: *what if legal rights and procedures were accessible to anyone, in their own language, on their phone — before or during a stressful moment?*

That is why **Court Companion** exists.

### Does the solution work on other people's systems?

- **Yes for the prototype:** Flutter APK (Android 7+) and web (Chrome/Edge) call the deployed Render API over HTTPS.
- **Planned:** Offline FAQ cache for common questions; lighter builds for low-end devices (relevant for rural users and older government-office hardware).

### Doesn't need to be perfect

We are submitting a **working prototype** with a clear roadmap — not a finished product. The screening phase is exactly for showing **how far we have come** and **where we are going**.

---

## 7. Data Visualization & Impact Measurement

*(Submission Guidelines — s3: Visualize your data!)*

### Planned: Admin analytics panel

Because any civic project needs and uses data, we plan an **admin-side dashboard** (not yet built — designed for post-screening):

| Metric | Source |
|--------|--------|
| **Active users** | Session / device counts |
| **Questions asked** | Per day, per language |
| **Top topics** | FIR, bail, theft, arrest rights, PPC sections… |
| **Helpfulness** | 👍 / 👎 icon after each answer → satisfaction rate |
| **Response latency** | Time to first token, full answer |
| **Language breakdown** | Which of the 7 languages citizens use most |

**Charts:** clearly labelled bar/line charts — no tiny fonts; clean visual hierarchy (per webinar advice).

**Purpose:** Answer *"Is this actually helping people?"* with data, not assumptions.

---

## 8. Languages

| Mode | Supported now | Planned |
|------|---------------|---------|
| **Text (chat)** | 7 languages: English, Urdu (script), Roman Urdu, Pashto, Punjabi, Sindhi, Balochi | — |
| **Voice** | English only (input + spoken output) | All 7 languages for STT + TTS |

---

## 9. Next: Agentic & Conversational AI

**Current behaviour:** Each question is mostly **stateless** — the assistant does not remember earlier messages in a session.

**Planned improvements:**

1. **Chat history** — preserve conversation context across turns.
2. **Follow-up questions** — if a user says *"someone took my phone"*, the assistant asks: *Was it taken by force? Do you know the person?* before citing the right PPC section.
3. **More agentic flow** — proactive clarification instead of guessing or giving vague answers.
4. **Session memory** — authenticated users can return to past conversations (Firebase — on roadmap).

---

## 10. Infrastructure & Sustainability

| Item | Now | Future |
|------|-----|--------|
| **Hosting** | Render (single instance, free tier) | Multi-deployment instances for uptime |
| **Open source** | Private dev repo | Public release with docs + contribution guide |
| **Cost** | Together.ai API + Render free tier | Seek grants / civic partnerships for scale |
| **Goal** | Minimal resources, maximum accessibility | No single point of failure; always reachable |

---

## 11. Screening Summary

| Question | Answer |
|----------|--------|
| **Working prototype?** | Yes — chat, voice (EN), 7 text languages, APK, deployed API |
| **AI used meaningfully?** | Yes — RAG over 983 legal chunks + multilingual LLM pipeline |
| **Feasibility validated?** | In progress — testing Together.ai models for quality & cost |
| **Civic impact?** | Legal rights accessible in plain language, 7 languages, on mobile |
| **What's left?** | Admin analytics, feedback, full voice languages, memory, multi-deploy |

---

## 12. Links & Assets

| Asset | Link / location |
|-------|-----------------|
| Source code | *(GitHub URL)* |
| Backend health | `https://ai-legal-assistant-fes8.onrender.com/health` |
| APK | `Frontend/build/app/outputs/flutter-apk/app-release.apk` |
| Demo video | *(add when ready — max 3 min)* |
| Pitch deck | *(add when ready)* |
| Screenshots | *(add when ready)* |

---

*Last updated: June 2026 — Screening phase, AI for Civic Innovation Hackathon*
