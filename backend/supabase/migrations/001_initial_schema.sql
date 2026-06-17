-- Court Companion — initial Supabase / PostgreSQL schema
-- Module 1: conversations + messages (device-based, no citizen login)
-- Module 2: feedback + analytics
-- Run once in Supabase Dashboard → SQL Editor

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- ---------------------------------------------------------------------------
-- Module 1 — Smarter conversations
-- ---------------------------------------------------------------------------

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  device_id text not null,
  language text not null default 'urdu_script',
  status text not null default 'active' check (status in ('active', 'archived')),
  case_summary text,
  case_facts jsonb not null default '{}'::jsonb,
  clarifying_complete boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists conversations_device_id_idx
  on public.conversations (device_id, updated_at desc);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  role text not null check (role in ('user', 'assistant', 'system')),
  content text not null,
  phase text check (phase in ('clarifying', 'reasoning', 'answering', 'conversational')),
  sources jsonb not null default '[]'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists messages_conversation_id_idx
  on public.messages (conversation_id, created_at);

drop trigger if exists conversations_updated_at on public.conversations;
create trigger conversations_updated_at
  before update on public.conversations
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Module 2 — Feedback & analytics
-- ---------------------------------------------------------------------------

create table if not exists public.answer_feedback (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null,
  conversation_id uuid references public.conversations(id) on delete set null,
  device_id text not null,
  rating text not null check (rating in ('up', 'down')),
  comment text,
  language text,
  topics text[] not null default '{}',
  channel text not null default 'chat' check (channel in ('chat', 'voice')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (message_id, device_id)
);

create index if not exists answer_feedback_created_at_idx
  on public.answer_feedback (created_at desc);

drop trigger if exists answer_feedback_updated_at on public.answer_feedback;
create trigger answer_feedback_updated_at
  before update on public.answer_feedback
  for each row execute function public.set_updated_at();

create table if not exists public.usage_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,
  device_id text not null,
  conversation_id uuid references public.conversations(id) on delete set null,
  language text,
  topics text[] not null default '{}',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists usage_events_created_at_idx
  on public.usage_events (created_at desc);

create index if not exists usage_events_type_created_idx
  on public.usage_events (event_type, created_at desc);

create table if not exists public.daily_stats (
  stat_date date primary key,
  active_users int not null default 0,
  sessions int not null default 0,
  questions int not null default 0,
  answers int not null default 0,
  feedback_up int not null default 0,
  feedback_down int not null default 0,
  language_breakdown jsonb not null default '{}'::jsonb,
  topic_breakdown jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Row Level Security — backend service role only (no public anon access)
-- ---------------------------------------------------------------------------

alter table public.conversations enable row level security;
alter table public.messages enable row level security;
alter table public.answer_feedback enable row level security;
alter table public.usage_events enable row level security;
alter table public.daily_stats enable row level security;

-- No policies for anon/authenticated — FastAPI uses service_role key only.

-- ---------------------------------------------------------------------------
-- Smoke-test seed (optional — delete after verifying)
-- ---------------------------------------------------------------------------

-- insert into public.conversations (device_id, language)
-- values ('test-device-001', 'urdu_script');
