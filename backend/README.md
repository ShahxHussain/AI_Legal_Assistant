# Court Companion — Backend

FastAPI + FAISS + Together.ai RAG backend.

## Setup

### 1. Create virtual environment

```bash
cd backend
python -m venv .venv

# Windows
.venv\Scripts\activate

# macOS / Linux
source .venv/bin/activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure environment

```bash
copy .env.example .env   # Windows
# cp .env.example .env   # macOS / Linux
```

Edit `.env` and set your Together.ai key:

```env
TOGETHER_API_KEY=your_key_here
```

### 4. Build the FAISS index

```bash
python scripts/build_index.py
```

This reads PDFs from `../data/` and writes `rag/index/index.faiss` + `chunks.json`.

### 5. Run the API

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

- Health: http://localhost:8000/health
- Docs: http://localhost:8000/docs

### 6. Test a question

```bash
curl -X POST http://localhost:8000/ask ^
  -H "Content-Type: application/json" ^
  -d "{\"question\": \"What is an FIR?\"}"
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Service and index status |
| POST | `/ask` | Legal Q&A with source citations |
