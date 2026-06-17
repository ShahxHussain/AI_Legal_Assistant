# Supabase Setup — Court Companion

Step-by-step guide to create your PostgreSQL database on Supabase for **Module 1** (chat history) and **Module 2** (feedback + analytics).

**Time:** ~15 minutes  
**Cost:** Free tier is enough for hackathon / pilot

---

## Step 1 — Create a Supabase account & project

1. Go to [https://supabase.com](https://supabase.com) and sign up (GitHub login is fine).
2. Click **New project**.
3. Fill in:
   - **Name:** `court-companion` (or any name)
   - **Database password:** choose a strong password — **save it** (you need it for direct Postgres access; the app uses API keys instead)
   - **Region:** choose closest to you (e.g. **Singapore** or **Frankfurt** for Pakistan users)
4. Click **Create new project** and wait ~2 minutes until the dashboard loads.

---

## Step 2 — Run the database migration (create tables)

1. In the left sidebar, open **SQL Editor**.
2. Click **New query**.
3. Open this file in your repo and copy **all** of it:

   `backend/supabase/migrations/001_initial_schema.sql`

4. Paste into the SQL Editor.
5. Click **Run** (or Ctrl+Enter).
6. You should see **Success. No rows returned**.

### Verify tables exist

1. Open **Table Editor** in the sidebar.
2. You should see:

   | Table | Purpose |
   |-------|---------|
   | `conversations` | One chat thread per device |
   | `messages` | User + assistant messages |
   | `answer_feedback` | 👍 / 👎 ratings |
   | `usage_events` | Analytics events |
   | `daily_stats` | Daily rollup for admin dashboard |

---

## Step 3 — Copy API credentials

1. Go to **Project Settings** (gear icon) → **API**.
2. Copy and save these **two values**:

   | Field | Example | Use |
   |-------|---------|-----|
   | **Project URL** | `https://abcdefgh.supabase.co` | `SUPABASE_URL` |
   | **service_role** key (under *Project API keys*) | `eyJhbG...` (secret) | `SUPABASE_SERVICE_ROLE_KEY` |

> **Important:** Use the **service_role** key on the **backend only** (FastAPI).  
> Never put it in the Flutter app or commit it to GitHub.

The **anon** key is not needed for Phase 1 — citizens talk to FastAPI, not Supabase directly.

---

## Step 4 — Configure backend `.env`

In `backend/` folder:

```powershell
cd backend
copy .env.example .env
```

Add to `backend/.env`:

```env
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJYOUR_SERVICE_ROLE_KEY

CONVERSATION_HISTORY_LIMIT=10
CLARIFYING_ENABLED=true
ADMIN_API_KEY=choose-a-long-random-string-for-dashboard
```

Replace `YOUR_PROJECT_REF` and the key with values from Step 3.

---

## Step 5 — Quick test in SQL Editor

Run this to confirm inserts work:

```sql
insert into public.conversations (device_id, language)
values ('test-phone-001', 'urdu_script')
returning id, device_id, created_at;
```

Copy the returned `id`, then:

```sql
insert into public.messages (conversation_id, role, content, phase)
values (
  'PASTE_CONVERSATION_UUID_HERE',
  'user',
  'Someone took my phone',
  null
);

select * from public.messages order by created_at desc limit 5;
```

Delete test data when done:

```sql
delete from public.conversations where device_id = 'test-phone-001';
```

---

## Step 6 — (Optional) Direct PostgreSQL connection

If you want DBeaver, pgAdmin, or `psql`:

1. **Project Settings** → **Database**
2. Copy **Connection string** → **URI** (mode: Session)
3. Replace `[YOUR-PASSWORD]` with the database password from Step 1

Example:

```
postgresql://postgres.xxxx:YOUR_PASSWORD@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres
```

---

## Security checklist

- [ ] `service_role` key only in `backend/.env` (gitignored)
- [ ] RLS enabled on all tables (migration does this)
- [ ] No Supabase keys in Flutter `dart-define` or APK
- [ ] Flutter sends `device_id` to FastAPI; FastAPI talks to Supabase

---

## What each table stores

### `conversations`

| Column | Meaning |
|--------|---------|
| `device_id` | Anonymous phone ID — **not** a login |
| `language` | Default reply language |
| `case_summary` | Compressed scenario for RAG |
| `case_facts` | JSON facts extracted from chat |
| `clarifying_complete` | Agent finished asking follow-ups |

### `messages`

Chat turns linked to `conversation_id`. `sources` JSON holds PPC/CrPC citation chips.

### `answer_feedback`

One row per answer per device (`unique (message_id, device_id)`).

### `usage_events`

Append-only: `session_start`, `question_asked`, `answer_completed`, etc.

### `daily_stats`

Filled by a nightly job later; empty until admin rollup runs.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `permission denied for table` | Backend must use **service_role** key, not anon |
| `relation already exists` | Migration already ran — safe to skip or use `if not exists` version in repo |
| Can't connect from Render | Use `SUPABASE_URL` + service key; no IP allowlist needed for REST API |
| Free tier paused | Open dashboard to wake project; first request may be slow |

---

## Next steps (after DB is ready)

1. Implement `backend/conversations/store.py` (Python ↔ Supabase)
2. Add `device_id` + `conversation_id` to `/ask/stream`
3. Flutter: local Hive + sync via API

See [`docs/PRODUCT_MODULES.md`](PRODUCT_MODULES.md) for full module design.

---

## File reference

| Path | Purpose |
|------|---------|
| `backend/supabase/migrations/001_initial_schema.sql` | Run this in SQL Editor |
| `backend/.env` | `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` |
| `docs/PRODUCT_MODULES.md` | Module 1 + 2 design |
