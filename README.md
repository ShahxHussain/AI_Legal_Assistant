# Court Companion – AI Legal Assistant

An AI-powered legal information platform that improves access to legal knowledge for citizens in Pakistan. Users can ask legal questions in natural language (text or voice) and receive simplified, contextually relevant answers grounded in Pakistan's legal framework.

> **Disclaimer:** Court Companion is an informational legal guide. It does not provide legal representation and does not replace professional legal counsel.

---

## Table of Contents

- [Overview](#overview)
- [Problem Statement](#problem-statement)
- [Proposed Solution](#proposed-solution)
- [Target Users](#target-users)
- [Features](#features)
  - [Implemented / Active](#implemented--active)
  - [Planned (On Hold)](#planned-on-hold)
- [RAG Architecture](#rag-architecture)
- [AI Models](#ai-models)
- [Technology Stack](#technology-stack)
- [Security](#security)
- [Future Enhancements](#future-enhancements)
- [Expected Impact](#expected-impact)

---

## Overview

Court Companion reduces barriers to legal information by making laws, legal rights, and legal procedures easier to understand for people without legal expertise.

**Initial focus:** Criminal law awareness  
**Core approach:** Retrieval-Augmented Generation (RAG) — responses are grounded in verified legal sources rather than relying solely on large language model knowledge.

---

## Problem Statement

Millions of citizens struggle to understand legal rights, criminal procedures, FIR processes, arrests, bail procedures, and Pakistan Penal Code (PPC) sections due to:

- Complex legal language
- Lack of affordable legal consultation
- Limited legal literacy
- Poor accessibility to legal information
- Absence of AI-powered legal assistance tailored to Pakistan

**Consequences:** Misinformation, delayed legal action, reduced legal awareness, and barriers to justice.

---

## Proposed Solution

Court Companion provides a bilingual AI legal assistant that:

| Capability | Description |
|------------|-------------|
| Multilingual Q&A | Accepts legal questions in English and Urdu |
| Grounded answers | Retrieves relevant information from a curated legal knowledge base |
| Simplified explanations | Generates understandable responses using AI |
| PPC & CrPC guidance | Covers Pakistan Penal Code and Criminal Procedure Code |
| Voice interaction | Supports speech-to-text and text-to-speech |
| Conversation history | Maintains chat sessions for authenticated users |

---

## Target Users

### Primary Users

- General citizens
- Students
- Rural communities
- Low-literacy users
- Individuals seeking legal awareness

### Secondary Users

- Legal aid organizations
- NGOs
- Community support groups
- Legal researchers

---

## Features

### Implemented / Active

#### AI Legal Question Answering

Users can ask questions such as:

- What is an FIR?
- What are my rights after arrest?
- What is Section 302 PPC?
- How can I apply for bail?
- What punishment exists for theft?

The system retrieves relevant legal documents and generates understandable responses.

#### Retrieval-Augmented Generation (RAG)

RAG reduces hallucinations and improves factual accuracy. Only retrieved legal information is used to formulate responses.

```text
User Question
    → Embedding Generation
    → Vector Search (FAISS)
    → Retrieve Relevant Legal Chunks
    → Build Context
    → LLM Response Generation
    → Final Answer
```

#### Multilingual Support

| Status | Languages |
|--------|-----------|
| **Current** | English, Urdu |
| **Future** | Regional languages |

#### Voice Support

- **Speech-to-Text** — capture questions by voice
- **Text-to-Speech** — hear responses aloud

Improves accessibility for elderly users, visually impaired users, and low-literacy populations.

---

### Planned (On Hold)

The following modules are documented for future implementation but are **not required for the initial release**.

| Module | Description |
|--------|-------------|
| **Legal Resource Center** | Downloadable FIR templates, complaint applications, affidavits, legal forms, and citizen rights guides |
| **Lawyer Recommendation** | Category-based lawyer suggestions (e.g., Criminal Law → Criminal Lawyer; Cybercrime → Specialist) with optional location-based matching |
| **Chat History** | View, search, and download previous conversations (authenticated users) |
| **Feedback System** | Rate responses, report inaccuracies, and submit improvement suggestions |

---

## RAG Architecture

### Knowledge Sources

Curated legal content from:

| Source | Examples |
|--------|----------|
| **Pakistan Penal Code (PPC)** | Section 302, Section 379, Section 420 |
| **Criminal Procedure Code (CrPC)** | FIR process, arrest procedures, bail procedures |
| **Legal FAQs** | What is FIR? How do I report a crime? What happens after arrest? |
| **Legal Templates** | Complaint applications, FIR formats |

### Data Processing Pipeline

| Step | Action |
|------|--------|
| 1 | Collect legal documents |
| 2 | Clean and normalize text |
| 3 | Split documents into chunks (500–1000 tokens, 50–100 token overlap) |
| 4 | Generate embeddings using Sentence Transformers |

**Embedding models:**

- Primary: `all-MiniLM-L6-v2`
- Alternative: `BAAI/bge-small-en-v1.5`

### Vector Database

| Version | Technology |
|---------|------------|
| **Initial** | FAISS |
| **Future** | Pinecone, Weaviate, Qdrant |

### Retrieval Process

```text
User Query
    → Query Embedding
    → FAISS Similarity Search
    → Top-K Documents Retrieved
    → Context Assembly
    → Prompt Construction
    → LLM Response Generation
```

---

## AI Models

### Embedding Model

| Property | Value |
|----------|-------|
| **Library** | Sentence Transformers |
| **Recommended model** | `all-MiniLM-L6-v2` |
| **Purpose** | Semantic search over legal documents |

### Large Language Model (LLM)

| Property | Value |
|----------|-------|
| **Provider** | Together.ai (`together` Python SDK) |
| **Model** | `meta-llama/Meta-Llama-3-8B-Instruct-Lite` |
| **Purpose** | Generate natural-language legal explanations from retrieved context |

---

## Technology Stack

| Layer | Technology | Details |
|-------|------------|---------|
| **Frontend** | Flutter (Dart) | Android, iOS, Web |
| **Backend** | FastAPI (Python) | Retrieval, RAG pipeline, authentication, APIs |
| **Database** | Firebase Firestore | Users, chat history, feedback, lawyer data |
| **Authentication** | Firebase Auth | Email login, Google login |
| **Vector Search** | FAISS | Legal embeddings, semantic indexes |

---

## Security

- Firebase Authentication
- Secure API access
- Encrypted user data
- Role-based access control (RBAC)
- Admin authorization

---

## Future Enhancements

- Constitutional law support
- Civil law support
- Family law support
- Court case tracking
- Location-based lawyer discovery
- Legal document generation
- Regional language support
- Fine-tuned legal LLM
- Government and NGO integrations

---

## Expected Impact

Court Companion aims to:

- Improve legal literacy
- Increase access to trustworthy legal information
- Reduce dependence on informal misinformation
- Improve accessibility of legal resources
- Empower citizens to better understand their rights

**Long-term vision:** Become Pakistan's most accessible AI-powered legal information platform.
