# Court Companion — Pitch Slide Script & Demo Guide

**Format:** 12 slides · ~12 minutes (≈1 min per slide)  
**Theme:** AI for Civic Innovation — Open Data & Access to Information  
**Live backend:** `https://ai-legal-assistant-fes8.onrender.com`

---

## Before you present

| Check | Action |
|-------|--------|
| Backend awake | Open `/health` in browser 1–2 min before demo |
| App ready | Chrome: `flutter run -d chrome --dart-define=API_BASE_URL=https://ai-legal-assistant-fes8.onrender.com` **or** APK on phone |
| Badge | Confirm **Online** in chat app bar |
| Mic (voice demo) | Allow browser/OS microphone; use headphones |
| Fallback | Screenshots or screen recording if Render is slow |

**Golden rule:** Start strong · End strong · Put your strongest speaker on open + close.

---

## Slide 1 — Title (~45 sec)

**On screen:** Cover image · Court Companion · Know Your Rights. In Your Language.

**Say:**

> "Assalam-o-Alaikum everyone. We are *[Team Name]*, and this is **Court Companion** — an AI legal multilingual assistant for Pakistan.
>
> Our tagline is simple: **Know Your Rights. In Your Language.**
>
> Court Companion helps ordinary citizens understand criminal law — FIRs, bail, arrest rights, PPC sections — through **text or voice**, in **seven languages**, grounded in real statute text — not AI guesses."

---

## Slide 2 — The Problem (~1 min)

**On screen:** Citizen confused · legal jargon · PPC/CrPC · stress at checkpoint

**Say:**

> "Most Pakistanis cannot read a PPC section or a CrPC procedure the way a lawyer can. Legal language is dense, consultation is expensive, and in a stressful moment — at a checkpoint, a police station, or after an incident — people don't know what their rights are.
>
> Misinformation spreads on WhatsApp. Formal legal aid is hard to reach. And if you speak Urdu, Pashto, or Sindhi, English-only resources don't help.
>
> The result: delayed action, fear, and barriers to justice — even when someone has done nothing wrong."

---

## Slide 3 — Our Story / Motivation (~1 min)

**On screen:** Road journey · phone · "rights" keyword — keep visual respectful

**Say:**

> "This is personal for us. During travel, some of our team had an experience where we were stopped and questioned in intimidating language — legal sections, offence numbers, things we didn't fully understand.
>
> We're not here to blame any institution; many officers serve the public with integrity. But we saw how quickly a **lack of legal literacy** leaves ordinary people feeling powerless.
>
> We thought: what if legal rights were on your phone — in **your language** — **before** or **during** that stressful moment? That's why we built Court Companion for this hackathon."

---

## Slide 4 — The Solution (~1 min)

**On screen:** App mockup · text + voice · 7 language chips

**Say:**

> "Court Companion is a **RAG-powered** legal information assistant.
>
> Users ask in plain language. The system **retrieves** relevant PPC, CrPC, and ATA text from **983 indexed chunks**, then **explains** it simply — with **source citations** and a legal disclaimer.
>
> Seven languages for text. Voice in English today — more languages on the roadmap. Android APK and Web — backend deployed on Render."

---

## Slide 5 — How It Works (~1 min)

**On screen:** System diagram from `LANGUAGE_AND_TRANSLATION.md`

**Say:**

> "Here's the flow in one picture.
>
> The Flutter app sends the question plus the user's **chosen response language**.
>
> On the server: if it's small talk, we reply briefly. If it's legal, we **translate non-English questions to English for search** — because our FAISS index is English — then **hybrid retrieval** finds the right statutes, and **Gemma 4** writes the answer in the language the user picked — Urdu, Pashto, Roman Urdu, and so on.
>
> Answers **stream live** — and in voice mode, the app **speaks as text arrives**."

---

## Slide 6 — AI & Data (~1 min)

**On screen:** Model table · 983 chunks · PPC + CrPC + ATA

**Say:**

> "We use **Together.ai**: Gemma 4 31B for answers, Llama 8B Lite for search translation, and **sentence-transformers** for embeddings.
>
> Our data is curated Pakistani criminal law — not random web scraping. **Section-aware chunking** keeps section numbers and topics intact.
>
> We're honestly still **validating** model choice for quality, latency, and cost on free-tier hosting — but the pipeline works end-to-end today."

---

## Slide 7 — LIVE DEMO 1: English chat (~1.5 min)

**On screen:** Share screen — Chat · language: **English** · badge **Online**

### Demo A — FIR (reliable, fast)

**Type:**
```
What is an FIR and how is it registered?
```

**Point out while it streams:**
- Answer appears word-by-word
- **Source chips** (CrPC §154 area)
- Disclaimer at bottom
- "Online" badge

**Say:**
> "First, English — a common citizen question. Watch the sources — those are real retrieved statutes, not the model inventing law."

---

## Slide 8 — LIVE DEMO 2: Urdu multilingual (~1.5 min)

**On screen:** Chat · switch language picker to **اردو (Urdu)**

### Demo B — Urdu theft + punishment

**Type:**
```
چوری کی سزا کیا ہے اور FIR کہاں درج ہوتی ہے؟
```

**Point out:**
- Question in Urdu script
- Answer streams in **Urdu**
- Sources may cite PPC 379 + CrPC procedure
- Backend translated query to English **only for search** — answer stayed Urdu

**Say:**
> "Same pipeline — user picks Urdu, asks in Urdu. Search translation finds the right English-indexed chunks; the answer is generated in Urdu for the citizen."

### Backup (if slow)

Pre-warm with Demo A first, or use Roman Urdu:
```
chori ki saza kya hai?
```
(language: **Roman Urdu**)

---

## Slide 9 — LIVE DEMO 3: Voice (~1 min)

**On screen:** Home → **Ask by voice** · language **English**

### Demo C — Voice arrest rights

**Speak clearly:**
```
What are my rights after arrest?
```

**Flow:**
1. Tap mic → speak → tap stop
2. Status: Searching → Generating → Speaking
3. Text appears + TTS reads phrases

**Say:**
> "Voice uses the **same RAG backend** as chat. English voice is live; we're extending STT and TTS to all seven languages next."

**If mic fails on stage:** Skip to Demo A replay and say voice is in APK — show recording instead.

---

## Slide 10 — Optional DEMO 4: Document upload (~45 sec)

**On screen:** Chat · attach small **TXT** or **PDF** (FIR draft, complaint sample)

### Demo D — Document + question

**Attach file** + type:
```
Summarize this document and what should I do next?
```

**Say:**
> "Users can upload PDF or TXT — useful for FIR copies or complaint drafts. Optional RAG pulls related statutes if the question is legal."

*Skip this slide if short on time.*

---

## Slide 11 — Impact & Roadmap (~1 min)

**On screen:** Planned admin panel · thumbs up/down · 7-language voice · open source

**Say:**

> "Implemented today: chat, voice in English, seven text languages, APK, deployed API, 983-chunk RAG.
>
> Next: **admin analytics** — how many people use it, which languages, thumbs up/down per answer so we measure real helpfulness.
>
> Then: voice in all languages, **conversational memory**, follow-up questions, open source, and multi-instance hosting so downtime doesn't block access.
>
> We're building on free-tier resources now — designed to scale with civic partners."

---

## Slide 12 — Close (~45 sec)

**On screen:** Cover · GitHub · QR to APK or web · Thank you

**Say:**

> "Court Companion is **legal information for everyone** — in the language they speak, on the phone they already have.
>
> We're not replacing lawyers. We're making **verified law** understandable when it matters most.
>
> Thank you. We're happy to take questions — or try Court Companion on your phone right now."

---

## Quick demo cheat sheet

| # | Mode | Language | Question | Shows |
|---|------|----------|----------|-------|
| A | Text | English | `What is an FIR and how is it registered?` | RAG + sources + stream |
| B | Text | Urdu | `چوری کی سزا کیا ہے اور FIR کہاں درج ہوتی ہے؟` | Translation + Urdu answer |
| C | Voice | English | *Speak:* `What are my rights after arrest?` | STT + stream + TTS |
| D | Text + file | Urdu/English | Attach PDF + `Summarize this document` | Document analysis |
| E | Text | English | `Salam, how can you help me?` | Conversational — no sources |
| F | Text | English | `What is Section 302 PPC?` | Direct section retrieval |

**Avoid on live demo:** Very long multi-part questions (slow on cold Render). Pre-warm with one short question backstage.

---

## Demo troubleshooting

| Issue | Fix |
|-------|-----|
| **Offline badge** | Open `https://ai-legal-assistant-fes8.onrender.com/health` — wait 30s — retry |
| **Slow first answer** | Say: "Render free tier waking up — typical 20–40 seconds" |
| **Urdu garbled** | Confirm language picker = Urdu, not English |
| **Voice no mic** | Switch to Demo B text; mention APK on Android |
| **Empty sources** | Use Demo A or F — conversational queries show no sources by design |

---

## 3-minute video script (Devpost)

If recording a short demo video instead of live pitch:

| Time | Shot |
|------|------|
| 0:00–0:20 | Cover + problem voiceover |
| 0:20–0:40 | Home screen · language chips |
| 0:40–1:30 | Demo A — English FIR (show sources) |
| 1:30–2:20 | Demo B — Urdu question (show Urdu answer) |
| 2:20–2:50 | Demo C — voice snippet |
| 2:50–3:00 | Logo + "Know Your Rights. In Your Language." + disclaimer |

---

## Related files

- [LANGUAGE_AND_TRANSLATION.md](LANGUAGE_AND_TRANSLATION.md) — system diagram + copy paragraph  
- [../SUBMISSION_SCREENING.md](../SUBMISSION_SCREENING.md) — implemented vs planned  
- [../assets/images/Cover.png](../assets/images/Cover.png) — title slide image
