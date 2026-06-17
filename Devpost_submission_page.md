# Court Companion | AI Legal Multilengual Assistant for Pakistan
<span style="color: red;">If the AI sounded like it was arguing with itself in the demo, that was my headset echoing, not Court Companion having an existential crisis, my headset turned the legal assistant into a very confused echo chamber: )</span>

### `LIVE Here:` https://ai-legal-assistant-seven.vercel.app/
---
## Why I Built This

Here's the honest story behind this project.

At some point, I — along with some people I know — had an unsettling experience during travel. We were stopped and questioned in a way that felt intimidating. The officer brought up **legal sections, offence numbers, and procedural language** that I didn't fully understand. That moment was confusing and frightening. You just want to resolve the situation and move on — but you don't know what your rights are, what those law sections actually mean, or how to respond calmly.

I'm not making accusations against anyone — many officers serve with integrity. But that experience stayed with me. It showed how easily a **lack of legal literacy** can leave ordinary people feeling powerless, even when they've done nothing wrong.

When I saw the **AI for Civic Innovation Hackathon**, it clicked: *what if legal rights and procedures were accessible to anyone, in their own language, on their phone — before or during a stressful moment?*

That's why **Court Companion** exists.
> #### Disclaimer: Court Companion provides legal *information* only. 

## The Problem

Most citizens in Pakistan can't easily understand criminal law — **FIR procedures, bail rights, PPC/CrPC sections** — especially when they're under pressure, communicating in Urdu or a regional language.
Keyword search doesn't work on dense legal documents. And generic AI just makes things up.

---

## What I Built

Court Companion is an **AI legal information assistant** that:

- Answers questions in **plain, simple language**
- Is grounded in **real Pakistani statutes** (PPC, CrPC, ATA) — not guesses
- Uses **RAG (Retrieval-Augmented Generation)** to find the right law section first, then explain it
- Works in **7 languages** — including Urdu script, Pashto, Sindhi, and more
- Supports both **text chat** and **voice**
- Runs on **Android (APK) and web (Chrome)**

Court Companion is an AI-powered multilingual legal assistant that helps Pakistani citizens understand their rights, FIR procedures, bail, and criminal laws (PPC, CrPC, ATA) in plain language. Built with Flutter for Android and Web, users can ask questions by text or voice in seven languages — English, Urdu, Roman Urdu, Pashto, Punjabi, Sindhi, and Balochi. Behind the app, a FastAPI backend on Render uses Retrieval-Augmented Generation (RAG): non-English questions are translated to English for search across 983 indexed statute chunks, then the model explains the retrieved legal sources in the user's chosen language with live streaming and source citations.
~ it makes trustworthy legal information accessible when people need it most.

---
## Target Audience

| Primary Users | Secondary Users |
|--------------|-----------------|
| General citizens — people seeking quick and simple legal guidance | Legal aid organizations — groups providing free or low-cost legal help |
| Students — learners exploring basic legal awareness and rights | NGOs — organizations working on legal awareness and social justice |
| Rural communities — users with limited access to legal resources | Community support groups — local bodies assisting people with legal issues |
| Low-literacy users — individuals needing easy, simplified legal explanations | Legal researchers — professionals studying laws, cases, and legal systems |
| Individuals under stress or intimidation — people needing urgent legal clarity in difficult situations | — |





## How It Works — The Tech Stack
#####  `Before I commit to a final stack, I'm testing all these things to answer two honest question — is this actually feasible , or not? am I on right track, or not? Everything here is still being evaluated. Later on, the plan is to replace all of this with open source alternatives.`


### Step-by-step (what happens when you ask a question)

| Step | Layer | What happens |
|------|-------|--------------|
| **1** | User | Types a question or speaks into the mic (voice → speech-to-text). |
| **2** | Flutter | User picks **response language** (Urdu, English, Pashto, etc.). |
| **3** | Flutter | Sends `POST /ask/stream` with `{ question, language }` to Render. |
| **4** | API | Validates request; checks FAISS index and Together.ai API key. |
| **5** | API | **IF** greeting/small talk → skip search, LLM replies briefly. **ELSE** → legal RAG path. |
| **6** | API | **IF** question is not English → **Llama 8B** translates it to an English search query. |
| **7** | API | Embeds the English query → **FAISS** retrieves top PPC/CrPC/ATA chunks (hybrid keyword + vector). |
| **8** | API | Builds prompt: English statute text + **mandatory answer-language rule** from app picker. |
| **9** | API | **Gemma 4 31B** streams the answer token-by-token in the user's chosen language. |
| **10** | Flutter | Shows live text, source chips, disclaimer; voice mode speaks each sentence as it arrives. |

Court Companion uses **two separate language pipelines** that must not be confused:

| Pipeline | Purpose | When it runs |
|----------|---------|--------------|
| **A — Search translation** | Turn the user's question into **English** so FAISS can find the right statute chunks | Before retrieval |
| **B — Response language** | Tell the LLM which language to **write the answer in** | During generation |

The knowledge base (embeddings + FAISS index) is **English-only**.  
The user's answer can still be in **any of 7 languages**.

### Knowledge Sources

| Source | Coverage |
|--------|----------|
| **Pakistan Penal Code (PPC)** | Offences, punishments, sections |
| **Criminal Procedure Code (CrPC)** | FIR, arrest, bail, investigation |
| **Anti-Terrorism Act (ATA)** | Scheduled offences & procedures |

### Why RAG and not just a chatbot?

Legal statutes are long, dense, and multilingual — keyword search alone fails. Citizens ask in natural language. RAG retrieves the *right section first*, then the LLM explains it simply. The translate-before-retrieve step makes an English-indexed corpus work across Urdu, Pashto, Sindhi, and more.


### Technology Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter (Dart) — Android, Web |
| **Backend** | FastAPI (Python) |
| **Vector search** | FAISS (file-based, 983 vectors) |
| **LLM API** | Together.ai |
| **Hosting** | Render (HTTPS) |
| **Voice** | `speech_to_text`, browser TTS / `flutter_tts` |

---

## What's Working Right Now

I've built a working prototype — not a finished product, but something real and testable.

| Feature | Details |
|---------|---------|
| **Text chat** | Streaming answers, source chips, markdown formatting, history sidebar |
| **7 text languages** | English, Urdu (script), Roman Urdu, Pashto, Punjabi, Sindhi, Balochi |
| **1 Voice (English)** | Mic input + spoken output as answers stream |
| **Home screen** | Ask in chat · Ask by voice · Court Companion Pro (beta info) |
| **Document analysis** | PDF/TXT via chat attach or `/analyze-document` (not a home button) |
| **Session follow-up** | Multi-turn context in the same chat via `conversation_id` |
| **Legal corpus** | PPC, CrPC, ATA — 983 indexed chunks |
| **RAG pipeline** | Hybrid retrieval, section metadata, output guard |
| **Backend API** | `/health`, `/ask`, `/ask/stream` — deployed on Render |
| **Flutter client** | Web + Android APK (release build points to Render URL) |
| **API status badge** | Online/Offline indicator in chat and voice screens |

---
## Dependencies & Feasibility

I want to be upfront about what I'm relying on — and what breaks if anything changes.

| Dependency | What I rely on | Risk if it changes |
|------------|---------------|-------------------|
| **Together.ai** | LLM + API for generation and translation | Model deprecation → swap model name in `.env`; that's it |
| **Render** | Free-tier HTTPS hosting for FastAPI + FAISS | Cold starts; may need paid tier for uptime |
| **sentence-transformers** | Local embeddings (`all-MiniLM-L6-v2`) | Pinned version; index rebuilds if changed |
| **FAISS index** | File-based vector store (983 chunks) | Rebuilt from `build_index.py` if corpus changes |
| **Flutter** | Cross-platform client (APK + web) | Standard; no vendor lock-in |

**Is this easy to replicate?**
A basic ChatGPT wrapper — yes, in days. My stack — curated legal RAG, 7-language pipeline, voice, APK, deployed API — would take meaningful effort. The legal data curation and section-aware indexing are the hardest part to copy quickly.

**What am I currently validating?**
I'm not claiming a final model choice yet. I'm actively testing:
- Answer quality across languages (especially Urdu script)
- Latency on free-tier hosting
- Or Optioning for multiple model support

**Known constraints (being honest):**
- No dedicated funding yet — relying on free / minimal-cost resources
- First request after idle can take ~50 seconds while Render wakes up
- Model choice `But planning for `OpenSource`

---
## Language Support

| Mode | Supported Now | Planned |
|------|--------------|---------|
| **Text (chat)** | English, Urdu (script), Roman Urdu, Pashto, Punjabi, Sindhi, Balochi | — |
| **Voice** | English only (input + spoken output) | All 7 languages for STT + TTS |

---
## What's Coming — Future Implementation (Final Round)

These are all designed or scoped — just not built yet.

#### 1 - **Smarter conversations (citizen):**
- Chat history sidebar — reopen past threads; **new empty chat** when opening from home
- Follow-up questions in the **same session** (e.g. “What about bail?” after FIR)
- Agentic clarifying questions (AI asks you first) → **Court Companion Pro** (see below)

#### 1b - **Court Companion Pro (beta — lawyers):**
- Home card → info screen today; full workspace later ([`docs/COURT_COMPANION_PRO.md`](docs/COURT_COMPANION_PRO.md))
- Case upload, agentic follow-ups, Supreme/High/Sessions case-law RAG, gap analysis
- Free in beta; paid subscription planned

#### 2 - **Voice for all languages:**
- Full STT + TTS support for all 7 languages, not just English

#### 3 - **Feedback and analytics (Admin Dashboard):**
- 👍 / 👎 after each answer to measure real-world helpfulness
- Usage analytics: active users, sessions, questions per day, language breakdown
- Top topics chart: FIR, bail, theft, arrest rights, PPC sections
- Response latency monitoring: time to first token, full answer time
- The goal: answer *"Is this actually helping people?"* with data, not assumptions

#### 4 - **Infrastructure and sustainability:**
- Multi-instance deployment so there's no single point of failure
- Offline FAQ cache for common questions — useful for rural users and older devices
- Open source release with public repo, docs, and contribution guidelines
- User accounts + saved conversations (Firebase — designed, not built yet)
- Seek civic grants or partnerships for scale

---

## Quick Summary

| Question | Answer |
|----------|--------|
| Working prototype? | Yes — chat, voice (EN), 7 text languages, APK, deployed API |
| AI used meaningfully? | Yes — RAG over 983 legal chunks + multilingual LLM pipeline |
| Feasibility validated? | In progress — testing Together.ai models for quality and cost |
| Civic impact? | Legal rights in plain language, 7 languages, on mobile |
| What's left for final round? | Admin analytics, full voice languages, conversation memory, multi-deploy | Transition to Open-Source things : )

---
*Built by: Syed Shah Hussain Badshah — June 2026 | *AI for Civic Innovation Hackathon 2026 — Code for Pakistan × Grey Software × Scrimba × FAST NUCES* — Screening Phase*