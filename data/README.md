# Legal Knowledge Base — Data Overview

Curated source documents for Court Companion's RAG pipeline. All files are **primary Pakistani criminal law statutes** in English PDF format.

> **Disclaimer:** These are reference sources for informational Q&A. Always verify against official gazetted versions for legal proceedings.

---

## Inventory

| File | Statute | Pages | ~Words | ~Tokens | Size | RAG priority |
|------|---------|-------|--------|---------|------|--------------|
| `Pakistan Penal Code.pdf` | Pakistan Penal Code (Act XLV of 1860) | 164 | 69,800 | 91,000 | 447 KB | **High** — substantive offences |
| `Code_of_criminal_procedure_1898.pdf` | Code of Criminal Procedure (Act V of 1898) | 290 | 103,200 | 134,000 | 809 KB | **High** — FIR, arrest, bail, procedure |
| `Anti-Terrorism-Act-1997.pdf` | Anti-Terrorism Act, 1997 (Act XXVII of 1997) | 46 | 20,800 | 27,000 | 234 KB | **High** — terrorism offences and special procedure |

**Corpus total:** ~500 pages · ~194,000 words · ~252,000 tokens (estimated)

---

## Knowledge sources covered

| Source | File |
|--------|------|
| Pakistan Penal Code (PPC) | `Pakistan Penal Code.pdf` |
| Criminal Procedure Code (CrPC) | `Code_of_criminal_procedure_1898.pdf` |
| Anti-Terrorism Act, 1997 | `Anti-Terrorism-Act-1997.pdf` |

---

## Topic coverage

### Code of Criminal Procedure

| Topic | Signal in corpus | Example reference |
|-------|------------------|-------------------|
| FIR | 281× "FIR", Section 154 | *Information in cognisable cases* |
| Arrest | 306× "arrest" | Arrest and custody provisions |
| Bail | 184× "bail" | Sections 496–498 area |
| Cognizable offences | 41× "cognizable" | Police powers / reporting |

### Pakistan Penal Code

| Topic | Signal in corpus | Example reference |
|-------|------------------|-------------------|
| Section 302 (murder) | Present | *Punishment of qatl-i-amd* |
| Section 379 (theft) | Present | Theft-related provisions |
| Section 420 (cheating) | Present | Fraud / cheating provisions |
| Islamic law amendments | Present | Qatl, qisas, diyat sections (post-2006 reforms) |

### Anti-Terrorism Act

| Topic | Signal in corpus |
|-------|------------------|
| Speedy trial / special courts | Present |
| Terrorism definitions | Present |

---

## RAG ingestion estimates

Using README chunking targets (500–1000 tokens, 50–100 overlap):

| Scope | Est. chunks |
|-------|-------------|
| Full corpus (3 PDFs) | ~350–400 |

**Indexing order:**

1. CrPC — FIR (154), arrest, bail (496–498), investigation
2. PPC — Sections 302, 379, 420 and related chapters
3. ATA — terrorism offences and special courts

---

## Recommended folder structure

```text
data/
├── README.md
├── raw/
│   ├── Pakistan Penal Code.pdf
│   ├── Code_of_criminal_procedure_1898.pdf
│   └── Anti-Terrorism-Act-1997.pdf
├── processed/                         # extracted plain text
└── chunks/                            # JSONL chunk files for embedding
```

---

## Source metadata

| File | Creator / origin hint |
|------|------------------------|
| `Pakistan Penal Code.pdf` | Microsoft Word export (PScript5.dll) |
| `Code_of_criminal_procedure_1898.pdf` | Microsoft Word export (PScript5.dll) |
| `Anti-Terrorism-Act-1997.pdf` | Nitro Pro 9 export |

Verify against official sources (e.g. Pakistan Code / gazette) before production use.
