import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  fetchLanguages,
  fetchOverview,
  fetchQuestionsPerDay,
  fetchRecentFeedback,
  fetchTopics,
  getStoredAdminKey,
  setStoredAdminKey,
} from '../api/adminClient';
import KpiCard from './components/KpiCard';
import QuestionsChart from './components/QuestionsChart';
import RecentFeedbackTable from './components/RecentFeedbackTable';
import SimpleBarList from './components/SimpleBarList';

export default function AdminDashboard({ onUnauthorized }) {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [overview, setOverview] = useState(null);
  const [questions, setQuestions] = useState([]);
  const [languages, setLanguages] = useState([]);
  const [topics, setTopics] = useState([]);
  const [feedback, setFeedback] = useState([]);

  const load = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const [ov, qpd, langs, tops, recent] = await Promise.all([
        fetchOverview(),
        fetchQuestionsPerDay(30),
        fetchLanguages(30),
        fetchTopics(30),
        fetchRecentFeedback(50),
      ]);
      setOverview(ov);
      setQuestions(qpd);
      setLanguages(
        langs.map((row) => ({
          label: row.language,
          count: row.count,
          pct: row.pct,
        })),
      );
      setTopics(
        tops.map((row) => ({
          label: row.topic,
          count: row.count,
          pct: row.pct,
        })),
      );
      setFeedback(recent);
    } catch (err) {
      if (err.code === 'UNAUTHORIZED') {
        setStoredAdminKey('');
        onUnauthorized?.();
        return;
      }
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [onUnauthorized]);

  useEffect(() => {
    if (!getStoredAdminKey()) {
      onUnauthorized?.();
      return;
    }
    load();
  }, [load, onUnauthorized]);

  function handleLogout() {
    setStoredAdminKey('');
    onUnauthorized?.();
  }

  return (
    <div className="min-h-screen bg-[#F5F7FA]">
      <header className="sticky top-0 z-10 border-b border-[#E5E7EB] bg-white/95 backdrop-blur-sm">
        <div className="mx-auto flex max-w-7xl flex-col gap-3 px-4 py-3 sm:flex-row sm:items-center sm:justify-between sm:gap-4 sm:px-6 sm:py-4">
          <div className="flex min-w-0 items-center gap-3">
            <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-[#1F6F5F] text-sm text-white sm:h-10 sm:w-10">
              ⚖
            </div>
            <div className="min-w-0">
              <h1 className="truncate font-display text-base font-bold text-[#0B2545] sm:text-lg">
                Court Companion
              </h1>
              <p className="truncate text-[10px] font-medium uppercase tracking-[0.12em] text-[#6B7280] sm:text-xs">
                Admin · Impact analytics
              </p>
            </div>
          </div>
          <div className="flex flex-wrap items-center gap-2 sm:justify-end">
            <button
              type="button"
              onClick={load}
              className="min-h-[40px] flex-1 rounded-lg border border-[#E5E7EB] px-3 py-2 text-sm font-medium text-[#1F2937] hover:bg-[#F5F7FA] active:bg-[#E8F2EE] sm:flex-none"
            >
              Refresh
            </button>
            <button
              type="button"
              onClick={handleLogout}
              className="min-h-[40px] flex-1 rounded-lg bg-[#0B2545] px-3 py-2 text-sm font-medium text-white hover:opacity-90 active:opacity-80 sm:flex-none"
            >
              Log out
            </button>
            <Link
              to="/"
              className="min-h-[40px] w-full rounded-lg border border-transparent px-3 py-2 text-center text-sm font-medium text-[#1F6F5F] hover:underline sm:w-auto"
            >
              Landing page
            </Link>
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-7xl px-4 py-5 sm:px-6 sm:py-8">
        {loading ? (
          <div className="py-16 text-center text-sm text-[#6B7280] sm:py-20">
            Loading dashboard…
          </div>
        ) : error ? (
          <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            {error}
          </div>
        ) : (
          <div className="space-y-4 sm:space-y-6">
            <section className="grid grid-cols-2 gap-3 sm:gap-4 xl:grid-cols-4">
              <KpiCard
                label="Active users (7d)"
                value={overview?.active_users_7d ?? 0}
                hint="Distinct devices with conversations"
              />
              <KpiCard
                label="Sessions (7d)"
                value={overview?.sessions_7d ?? 0}
                hint="New conversations started"
              />
              <KpiCard
                label="Questions today"
                value={overview?.questions_today ?? 0}
                hint={`${overview?.questions_7d ?? 0} in last 7 days`}
              />
              <KpiCard
                label="Helpfulness (7d)"
                value={
                  overview?.helpfulness_pct_7d != null
                    ? `${overview.helpfulness_pct_7d}%`
                    : '—'
                }
                hint={`Helpful ${overview?.feedback_up_7d ?? 0} · Not helpful ${overview?.feedback_down_7d ?? 0}`}
              />
            </section>

            <section className="grid grid-cols-1 gap-4 sm:gap-6 lg:grid-cols-2">
              <QuestionsChart series={questions} />
              <SimpleBarList
                title="Language breakdown (30d)"
                items={languages}
                labelKey="label"
              />
            </section>

            <section className="grid grid-cols-1 gap-4 sm:gap-6 lg:grid-cols-2">
              <SimpleBarList title="Top topics (30d)" items={topics} labelKey="label" />
              <RecentFeedbackTable rows={feedback} />
            </section>
          </div>
        )}
      </main>
    </div>
  );
}
