# Court Companion — Technical Architecture (Presentation)

**Use this for pitch slides, Devpost, and judge Q&A.**  
**Layout:** landscape 16:9 — copy the Mermaid block into [mermaid.live](https://mermaid.live) and export PNG/SVG for PowerPoint / Canva / Google Slides.

**Version:** 1.0 · 2026-06-17

---

## One-slide diagram (recommended for judges)

Plain English on top, technical labels underneath. Left → right = citizen journey.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'fontSize': '15px', 'primaryColor': '#ecfdf3', 'primaryBorderColor': '#0d5c2e', 'lineColor': '#525252', 'secondaryColor': '#f5f5f5', 'tertiaryColor': '#fff'}}}%%
flowchart LR
    subgraph CITIZEN["① Citizen"]
        U(["Person with a legal question\nFIR · bail · rights · Urdu/English"])
    end

    subgraph APPS["② Court Companion apps"]
        WEB["Flutter Web\nVercel"]
        APK["Android APK"]
    end

    subgraph API["③ Smart backend — Render"]
        direction TB
        APIBOX["FastAPI server"]
        RAG["RAG engine\nRetrieve law first,\nthen explain"]
        APIBOX --> RAG
    end

    subgraph KNOWLEDGE["④ Ground truth"]
        FAISS[("983 statute chunks\nPPC · CrPC · ATA")]
        LLM["Together.ai\nLlama 3.3 70B answers\n8B Lite translates queries"]
    end

    subgraph DATA["⑤ Memory & impact"]
        DB[("Supabase\nchats · feedback")]
        ADMIN["Admin dashboard\nVercel /admin"]
    end

    U --> WEB
    U --> APK
    WEB -->|"HTTPS stream"| APIBOX
    APK -->|"HTTPS stream"| APIBOX
    RAG --> FAISS
    RAG --> LLM
    RAG -->|"answer + sources"| WEB
    RAG -->|"answer + sources"| APK
    APIBOX --> DB
    DB --> ADMIN

    style CITIZEN fill:#f5f5f5,stroke:#0a0a0a
    style APPS fill:#ecfdf3,stroke:#0d5c2e
    style API fill:#ecfdf3,stroke:#0d5c2e
    style KNOWLEDGE fill:#f0fdf4,stroke:#15803d
    style DATA fill:#f8fafc,stroke:#334155
```

### 30-second narration (memorize this)

> A citizen asks a real question on **web or Android**. Our **FastAPI backend** does not guess — it **searches 983 real Pakistani law chunks** (PPC, CrPC, ATA) using **MiniLM embeddings**, then **Llama 3.3 70B** explains the answer in plain language in **7 languages**, with **source citations**. Chats and feedback go to **Supabase**; organizers see **live impact** on the admin dashboard. **No API keys on the phone** — all AI runs server-side.

---

## Slide 2 — How one question flows (optional deep-dive)

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'fontSize': '14px'}}}%%
sequenceDiagram
    autonumber
    participant C as Citizen
    participant A as Flutter app
    participant S as FastAPI + RAG
    participant V as FAISS index
    participant L as Together.ai
    participant D as Supabase

    C->>A: Ask in Urdu / voice / chat
    A->>S: POST /ask/stream + device_id
    Note over S: Non-English → translate query to English for search
    S->>V: Find top statute sections
    V-->>S: PPC / CrPC / ATA chunks
    S->>L: Answer using ONLY retrieved text
    L-->>S: Stream tokens
    S-->>A: Live answer + source chips + disclaimer
    S->>D: Save conversation + usage event
    A-->>C: 👍/👎 feedback optional
```

---

## Slide 3 — What we deploy (infrastructure)

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'fontSize': '14px'}}}%%
flowchart TB
    subgraph VERCEL["Vercel — free tier"]
        LAND["Landing page\nai-legal-assistant-seven.vercel.app"]
        FWEB["Flutter web app\nai-legal-assistant-two.vercel.app"]
        ADM["Admin + survey traction\n/admin · /admin/traction"]
    end

    subgraph RENDER["Render — free tier"]
        API["FastAPI + FAISS in memory\nai-legal-assistant-fes8.onrender.com"]
    end

    subgraph CLOUD["Managed services"]
        TAI["Together.ai — LLM API"]
        SUPA["Supabase — Postgres"]
    end

  LAND -.->|links| FWEB
    FWEB --> API
    APK["Android APK"] --> API
    API --> TAI
    API --> SUPA
    ADM --> API

    style VERCEL fill:#ecfdf3,stroke:#0d5c2e
    style RENDER fill:#f0fdf4,stroke:#15803d
    style CLOUD fill:#f8fafc,stroke:#64748b
```

---

## Design notes for slides

| Tip | Detail |
|-----|--------|
| **Orientation** | Landscape 16:9 — use diagram 1 full-width |
| **Colors** | Match landing: green `#0d5c2e`, neutral `#fafafa`, dark text `#0a0a0a` |
| **Export** | mermaid.live → PNG 1920×1080 or SVG |
| **Audience** | Say layer numbers aloud: "Step 1 citizen… Step 4 ground truth…" |
| **Trust hook** | Point to FAISS + source chips: "AI quotes real law, not imagination" |

---

## Live URLs (for slide footer)

| Resource | URL |
|----------|-----|
| Web app | https://ai-legal-assistant-two.vercel.app/ |
| Landing | https://ai-legal-assistant-seven.vercel.app/ |
| API health | https://ai-legal-assistant-fes8.onrender.com/health |
| Admin | https://ai-legal-assistant-seven.vercel.app/admin |
