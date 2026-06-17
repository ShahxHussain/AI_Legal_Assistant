# Court Companion | AI Legal Multilingual Assistant for Pakistan

<span style="color: red;">If the AI sounded like it was arguing with itself in the demo, that was my headset echoing, not Court Companion having an existential crisis — my headset turned the legal assistant into a very confused echo chamber :)</span>

### `LIVE Here:` https://ai-legal-assistant-seven.vercel.app/

---

## Why I Built This

Here's the honest story behind this project.

At some point, I — along with some people I know — had an unsettling experience during travel. We were stopped and questioned in a way that felt intimidating. The officer brought up **legal sections, offence numbers, and procedural language** that I didn't fully understand. That moment was confusing and frightening. You just want to resolve the situation and move on — but you don't know what your rights are, what those law sections actually mean, or how to respond calmly.

I'm not making accusations against anyone — many officers serve with integrity. But that experience stayed with me. It showed how easily a **lack of legal literacy** can leave ordinary people feeling powerless, even when they've done nothing wrong.

When I saw the **AI for Civic Innovation Hackathon**, it clicked: *what if legal rights and procedures were accessible to anyone, in their own language, on their phone — before or during a stressful moment?*

That's why **Court Companion** exists.

> #### Disclaimer: Court Companion provides legal *information* only — not legal advice or representation.

---

## The Problem

Most citizens in Pakistan can't easily understand criminal law — **FIR procedures, bail rights, PPC/CrPC sections** — especially when they're under pressure, communicating in Urdu or a regional language.

And real situations are rarely simple **"What does Section X mean?"** questions.

They look more like:

- "The police are refusing to file my FIR — is that even allowed?"
- "My cousin was arrested without a warrant — what happens now?"
- "I acted in self-defence but I'm being accused of murder — can I even get bail?"

Court Companion is designed to answer these real-world, scenario-based legal questions by combining statutory retrieval (PPC, CrPC, ATA) with plain-language explanations grounded in the law.

These are messy, multi-part, real-life situations — mixed with conflicting advice from neighbours, police, and "a guy who knows a guy." Keyword search doesn't work here. Generic AI just makes things up. People are left more confused than when they started.

---

## What I Built

Court Companion is an AI legal assistant that thinks through real situations — not just definitions.

Ask it a textbook question like "What is PPC 379?" and it'll explain it clearly. But ask it a real, messy situation — with multiple facts, conflicting claims, and an actual decision to make — and it walks through it properly: identifies which laws apply, explains the relevant procedure, and lays out what the person's actual rights and next steps are.

- In **plain, simple language**
- **Grounded in real Pakistani statutes (PPC, CrPC, ATA)** — every answer is backed by the actual law text, not guesses
- Using **RAG (Retrieval-Augmented Generation)** — finds the relevant sections first, then reasons through the scenario using them
- In **7 languages** for text — Urdu script, Roman Urdu, Pashto, Punjabi, Sindhi, Balochi, and English
- **Voice in English and Urdu** — speak your question and hear answers aloud (more voice languages as resources allow)
- **Three ways in from home:** **Ask in chat** · **Ask by voice** · **Court Companion Pro** (beta info for lawyers)
- Runs on **Android (APK) and web (Chrome)**

Court Companion is an AI-powered multilingual legal assistant that helps Pakistani citizens understand their rights, FIR procedures, bail, and criminal laws (PPC, CrPC, ATA) in plain language. Built with Flutter for Android and Web, users can ask questions by text or voice in seven languages. Behind the app, a FastAPI backend on Render uses Retrieval-Augmented Generation (RAG): non-English questions are translated to English for search across **983 indexed statute chunks**, then the model explains the retrieved legal sources in the user's chosen language with live streaming and source citations.

It makes trustworthy legal information accessible when people need it most — not as a dictionary, but as someone walking through the situation with you.

---

## What It Can Handle — Real Scenarios, Not Just Definitions

This is the part that's hard to capture in a feature list, so here are real examples of the kind of situations Court Companion is built to handle. These aren't simplified "textbook" questions — they're the kind of messy, multi-part, real-life situations people actually bring.

### Scenario — "My cousin was arrested without a warrant"

*My cousin was arrested yesterday evening from his home without showing any warrant. The police said it is related to a fight that happened three days ago where someone was injured but not killed. He has not been produced before any magistrate yet and it has been more than 24 hours. If the injury was serious but not fatal, can police still hold him without bail, and under which sections of CrPC and PPC should his family understand his rights regarding bail and production before a magistrate?*

#### Why this matters

A simple FAQ bot can answer "what is PPC 302?" Court Companion is built to handle the version of the question that actually shows up in someone's life — with conflicting information, emotional stakes, multiple legal issues tangled together, and a real decision on the other end. That's the gap between "looks like AI" and "is actually useful."

---

## Target Audience

| Primary Users | Secondary Users |
|---------------|-----------------|
| General citizens — people seeking quick and simple legal guidance | Legal aid organizations — groups providing free or low-cost legal help |
| Students — learners exploring basic legal awareness and rights | NGOs — organizations working on legal awareness and social justice |
| Rural communities — users with limited access to legal resources | Community support groups — local bodies assisting people with legal issues |
| Low-literacy users — individuals needing easy, simplified legal explanations | Legal researchers — professionals studying laws, cases, and legal systems |
| Individuals under stress or intimidation — people needing urgent legal clarity in difficult situations | **Lawyers & advocates** — future **Court Companion Pro** workspace (beta info in app today) |
| Women and first-time complainants — especially in harassment, domestic disputes, or property cases where not knowing the process means giving up before even starting | — |

---

## How It Works — The Tech Stack

##### `Before I commit to a final stack, I'm testing all these things to answer two honest questions — is this actually feasible, or not? Am I on the right track, or not? Everything here is still being evaluated. Later on, the plan is to replace proprietary APIs with open-source alternatives where possible.`

### Step-by-step (what happens when you ask a question)

| Step | Layer | What happens |
|------|-------|--------------|
| **1** | User | Opens **Ask in chat** or **Ask by voice** from home; picks **response language**. |
| **2** | Flutter | Sends `POST /ask/stream` with `{ question, language, device_id, conversation_id }` to Render. |
| **3** | API | Validates request; checks FAISS index and Together.ai API key. |
| **4** | API | Resolves or creates a **conversation** (Supabase) for multi-turn context when configured. |
| **5** | API | **IF** greeting/small talk → skip search, LLM replies briefly. **ELSE** → legal RAG path. |
| **6** | API | **IF** question is not English → **Llama 8B** translates it to an English search query. |
| **7** | API | Embeds the English query → **FAISS** retrieves top PPC/CrPC/ATA chunks (hybrid keyword + vector). |
| **8** | API | Builds prompt: prior turns + English statute text + **mandatory answer-language rule** from app picker. |
| **9** | API | **Llama 3.3 70B** streams the answer token-by-token in the user's chosen language. |
| **10** | Flutter | Shows live text, source chips, disclaimer; optional 👍/👎; voice mode speaks each sentence as it arrives. |

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

Legal statutes are long, dense, and multilingual — keyword search alone fails. Citizens describe real situations, not search terms. RAG retrieves the relevant sections first, then the LLM reasons through the scenario using them. The translate-before-retrieve step makes an English-indexed corpus work across Urdu, Pashto, Sindhi, and more — so the reasoning step still happens in the user's own language.

### Technology Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter (Dart) — Android, Web |
| **Backend** | FastAPI (Python) |
| **Database** | Supabase PostgreSQL — conversations, messages, feedback, usage events |
| **Vector search** | FAISS (file-based, 983 vectors) |
| **LLM API** | Together.ai |
| **Hosting** | Render (API) · Vercel (landing + admin UI) |
| **Voice** | `speech_to_text`, browser TTS / `flutter_tts` |
| **Admin** | React + Vite at `/admin` on landing site |

---

## Features

Everything below is **implemented and working** in the current prototype — not a mockup.

### App & access

| Feature | What you get |
|---------|----------------|
| **Home screen** | **Ask in chat** · **Ask by voice** · **Court Companion Pro** (beta) |
| **Platforms** | Flutter **web** (Chrome) + **Android APK** (release build → Render API) |
| **API status** | Online / offline badge on chat and voice screens |
| **No login required** | Anonymous `device_id` — citizens use the app without accounts |

### Text chat

| Feature | What you get |
|---------|----------------|
| **Streaming answers** | Live token stream, markdown, source chips, disclaimer |
| **7 text languages** | English, Urdu (script), Roman Urdu, Pashto, Punjabi, Sindhi, Balochi |
| **Chat history sidebar** | Reopen past conversations; tap **New chat** for a fresh thread |
| **Session follow-up** | Same chat thread keeps context — e.g. FIR first, then *"What about bail?"* |
| **Fresh chat from home** | Opening **Ask in chat** from home starts empty; history stays in sidebar |
| **Document attach** | PDF/TXT via clip icon in chat or `/analyze-document` API |
| **Answer feedback** | 👍 / 👎 on each reply → admin **Helpfulness** metrics |

### Voice assistant

| Feature | What you get |
|---------|----------------|
| **English voice** | Mic input (STT) + spoken streaming answers (TTS) |
| **Urdu voice** | Speak in Urdu (اردو) and hear replies in Urdu script — same RAG backend as chat |
| **In-app help** | Optional Urdu voice setup guide if device packs need configuration |
| **More languages** | Roman Urdu, Pashto, Punjabi, Sindhi, Balochi voice — planned as STT/TTS resources are finalized |

### Legal intelligence (RAG)

| Feature | What you get |
|---------|----------------|
| **Statute corpus** | PPC, CrPC, ATA — **983 indexed chunks** with section metadata |
| **Hybrid retrieval** | FAISS vector search + keyword signals; translate-before-retrieve for non-English |
| **Scenario reasoning** | Multi-fact questions → applicable law, procedure, rights, next steps |
| **Source citations** | Every legal answer tied to retrieved statute excerpts |
| **Output guard** | Sanitized LLM output; preserves Urdu punctuation and formatting |

### Backend & data

| Feature | What you get |
|---------|----------------|
| **API** | `/health`, `/ask`, `/ask/stream`, conversations CRUD, `/feedback`, `/admin/stats/*` |
| **Supabase** | Conversations, messages, feedback, usage events (when configured) |
| **Hosting** | FastAPI + FAISS on **Render**; landing + admin on **Vercel** |

### Admin & impact (organizers / NGOs)

| Feature | What you get |
|---------|----------------|
| **Admin dashboard** | React app at `/admin` — sessions, questions/day, language mix, top topics |
| **Recent feedback** | 👍/👎 stream with mobile-friendly layout |
| **Usage events** | `question_asked`, `answer_completed` logged for civic impact reporting |

### Court Companion Pro (beta — lawyers)

| Feature | What you get |
|---------|----------------|
| **Pro info screen** | Full product explanation in app — who it's for, how it will work |
| **Coming in Pro** | Case upload, **agentic clarifying questions**, case-law RAG, gap analysis |
| **Pricing** | Free during beta; paid professional tier planned (citizen chat stays free) |

Full design: [`docs/COURT_COMPANION_PRO.md`](docs/COURT_COMPANION_PRO.md)

---

## Court Companion Pro — What's Next for Lawyers

**Court Companion Pro** is the professional tier I'm building for **lawyers and advocates** — separate from free citizen chat.

| | **Ask in chat** (free) | **Court Companion Pro** (paid after beta) |
|---|------------------------|-------------------------------------------|
| **Audience** | Citizens | Lawyers, legal researchers |
| **Input** | Questions + optional single doc attach | Full case file, pleadings, FIR, orders |
| **Follow-up** | User asks next question in same session | **AI asks clarifying questions** when facts are missing |
| **Knowledge** | PPC, CrPC, ATA statutes | Statutes **+ public case law** (Supreme, High, Sessions courts) |
| **Status today** | Live | **Beta info screen in app** — workspace coming next |

Free during beta; professional subscription planned at launch. Full design: [`docs/COURT_COMPANION_PRO.md`](docs/COURT_COMPANION_PRO.md)

---

## Dependencies & Feasibility

I want to be upfront about what I'm relying on — and what breaks if anything changes.

| Dependency | What I rely on | Risk if it changes |
|------------|---------------|-------------------|
| **Together.ai** | LLM + API for generation and translation | Model deprecation → swap model name in `.env`; that's it |
| **Render** | Free-tier HTTPS hosting for FastAPI + FAISS | Cold starts; may need paid tier for uptime |
| **Supabase** | Conversation history, feedback, analytics | Service outage → local chat still works; server context may lag |
| **sentence-transformers** | Local embeddings (`all-MiniLM-L6-v2`) | Pinned version; index rebuilds if changed |
| **FAISS index** | File-based vector store (983 chunks) | Rebuilt from `build_index.py` if corpus changes |
| **Flutter** | Cross-platform client (APK + web) | Standard; no vendor lock-in |

**Is this easy to replicate?**  
A basic ChatGPT wrapper — yes, in days. My stack — curated legal RAG, 7-language pipeline, voice, conversation persistence, admin analytics, APK, deployed API — would take meaningful effort. The legal data curation and section-aware indexing are the hardest part to copy quickly.

**What am I currently validating?**  
I'm not claiming a final model choice yet. I'm actively testing:

- Answer quality across languages (especially Urdu script)
- Reasoning quality on multi-part, scenario-based questions
- Multi-turn follow-up quality with conversation context
- Optioning for multiple model support and open-source migration

**Known constraints (being honest):**

- No dedicated funding yet — relying on free / minimal-cost resources
- First request after idle can take ~50 seconds while Render wakes up
- Voice: **English + Urdu** live today; five more languages once STT/TTS resources are finalized
- Agentic clarifying questions (AI asks you first) ship with **Court Companion Pro**, not free chat yet

---

## Language Support

| Mode | Supported now | Coming next |
|------|---------------|-------------|
| **Text (chat)** | English, Urdu (script), Roman Urdu, Pashto, Punjabi, Sindhi, Balochi | — |
| **Voice (STT + TTS)** | **English** and **Urdu (script)** | Roman Urdu, Pashto, Punjabi, Sindhi, Balochi — as device/API resources are finalized |

---

## What's Coming — Roadmap

### Court Companion Pro (lawyers)

- Full case workspace — upload pleadings, FIR, orders; one case = full context throughout
- **Agentic follow-ups** — e.g. *"Someone took my phone"* → AI asks *Was it taken by force? Do you know the person?* → then cites PPC + precedents
- Case-law RAG from public Supreme Court, High Court, and Sessions judgments
- Gap / procedural flags for counsel (limitation, bail category, evidence gaps)
- Paid subscription after beta (citizen chat stays free)

Design doc: [`docs/COURT_COMPANION_PRO.md`](docs/COURT_COMPANION_PRO.md)

### Platform & scale

- **Voice for remaining languages** — Roman Urdu, Pashto, Punjabi, Sindhi, Balochi (STT + TTS)
- **Multi-instance deployment** — no single point of failure
- **Offline FAQ cache** — core rights without internet (rural users)
- **Open source release** — public repo, docs, contribution guide
- **Corpus expansion** — constitutional, civil, family law

---

## Quick Summary

| Question | Answer |
|----------|--------|
| Working prototype? | Yes — full **Features** section above; chat, voice (EN + Urdu), 7 text languages, admin, APK, deployed API |
| AI used meaningfully? | Yes — RAG over 983 legal chunks + multilingual LLM pipeline + multi-turn context |
| Feasibility validated? | In progress — testing models for quality, latency, and cost |
| Civic impact? | Legal rights in plain language, 7 text languages + Urdu voice, on mobile; data-driven admin KPIs |
| What's next? | **Court Companion Pro** workspace; more voice languages; case-law corpus; open-source path |

---

*Built by: Syed Shah Hussain Badshah — June 2026 | AI for Civic Innovation Hackathon 2026 — Code for Pakistan × Grey Software × Scrimba × FAST NUCES — Final Round*
