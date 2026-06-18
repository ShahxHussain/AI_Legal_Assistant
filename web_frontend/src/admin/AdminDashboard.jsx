import { useCallback, useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { RiRefreshLine } from 'react-icons/ri';
import {
  fetchLanguages,
  fetchOverview,
  fetchQuestionsPerDay,
  fetchRecentFeedback,
  fetchTopics,
  getStoredAdminKey,
  setStoredAdminKey,
} from '../api/adminClient';
import { formatDateRangeLabel, formatLanguageLabel, formatTopicLabel } from './utils';
import DateRangeSelector from './components/DateRangeSelector';
import HelpfulnessPanel from './components/HelpfulnessPanel';
import KpiCard from './components/KpiCard';
import QuestionsChart from './components/QuestionsChart';
import RecentFeedbackTable from './components/RecentFeedbackTable';
import SimpleBarList from './components/SimpleBarList';

function DashboardSkeleton() {
  return (
    <div className="animate-pulse space-y-6">
      <div className="grid grid-cols-2 gap-4 xl:grid-cols-4">
        {[1, 2, 3, 4].map((i) => (
          <div key={i} className="admin-card h-36" />
        ))}
      </div>
      <div className="admin-card h-64" />
      <div className="grid gap-4 lg:grid-cols-3">
        <div className="admin-card h-72 lg:col-span-2" />
        <div className="admin-card h-72" />
      </div>
    </div>
  );
}

export default function AdminDashboard() {
  const [days, setDays] = useState(30);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [lastUpdated, setLastUpdated] = useState(null);
  const [overview, setOverview] = useState(null);
  const [questions, setQuestions] = useState([]);
  const [languages, setLanguages] = useState([]);
  const [topics, setTopics] = useState([]);
  const [feedback, setFeedback] = useState([]);

  const load = useCallback(async () => {
    if (!getStoredAdminKey()) return;
    setLoading(true);
    setError('');
    try {
      const [ov, qpd, langs, tops, recent] = await Promise.all([
        fetchOverview(days),
        fetchQuestionsPerDay(days),
        fetchLanguages(days),
        fetchTopics(days),
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
      setLastUpdated(new Date());
    } catch (err) {
      if (err.code === 'UNAUTHORIZED') {
        setStoredAdminKey('');
        window.location.reload();
        return;
      }
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [days]);

  useEffect(() => {
    load();
  }, [load]);

  const periodLabel = formatDateRangeLabel(days);

  return (
    <main className="relative mx-auto max-w-7xl px-4 py-6 sm:px-6 sm:py-8">
      <motion.div
        initial={{ opacity: 0, y: 12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.45 }}
        className="mb-8"
      >
        <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <span className="inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary-pale/60 px-3 py-1">
              <span className="h-1.5 w-1.5 rounded-full bg-primary shadow-[0_0_8px_rgba(13,92,46,0.6)]" />
              <span className="text-[11px] font-semibold uppercase tracking-wider text-primary">
                Civic analytics · live
              </span>
            </span>
            <h2 className="mt-4 font-display text-2xl font-semibold tracking-tight text-dark sm:text-3xl">
              Live impact dashboard
            </h2>
            <p className="mt-2 max-w-2xl text-[15px] text-neutral-500">
              {periodLabel} — users, sessions, languages, topics, and citizen feedback
              across web and Android.
              {lastUpdated ? (
                <span className="mt-1 block text-[12px] text-neutral-400">
                  Updated {lastUpdated.toLocaleTimeString()}
                </span>
              ) : null}
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <DateRangeSelector value={days} onChange={setDays} disabled={loading} />
            <button
              type="button"
              onClick={load}
              disabled={loading}
              className="btn-secondary !py-2"
            >
              <RiRefreshLine size={16} className={loading ? 'animate-spin' : ''} />
              Refresh
            </button>
          </div>
        </div>
      </motion.div>

      {loading ? (
        <DashboardSkeleton />
      ) : error ? (
        <div className="admin-card border-red-200 bg-red-50 px-5 py-4 text-sm text-red-700">
          {error}
        </div>
      ) : (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.35, delay: 0.05 }}
          className="space-y-6"
        >
          <section className="grid grid-cols-2 gap-4 xl:grid-cols-4">
            <KpiCard
              icon="users"
              label={`Active users (${days}d)`}
              value={overview?.active_users_7d ?? 0}
              hint="Distinct devices — web + APK"
            />
            <KpiCard
              icon="sessions"
              label={`Sessions (${days}d)`}
              value={overview?.sessions_7d ?? 0}
              hint="New conversations started"
            />
            <KpiCard
              icon="questions"
              label="Questions today"
              value={overview?.questions_today ?? 0}
              hint={`${overview?.questions_7d ?? 0} in selected period`}
            />
            <KpiCard
              icon="helpful"
              label={`Helpful answers (${days}d)`}
              value={
                overview?.helpfulness_pct_7d != null
                  ? `${overview.helpfulness_pct_7d}%`
                  : '—'
              }
              hint={`${overview?.feedback_up_7d ?? 0} up · ${overview?.feedback_down_7d ?? 0} down`}
            />
          </section>

          <section>
            <QuestionsChart series={questions} days={days} />
          </section>

          <section className="grid grid-cols-1 gap-6 lg:grid-cols-3">
            <div className="lg:col-span-1">
              <SimpleBarList
                title="Languages"
                subtitle={periodLabel}
                items={languages}
                formatLabel={formatLanguageLabel}
              />
            </div>
            <div className="lg:col-span-1">
              <SimpleBarList
                title="Top topics"
                subtitle="Keyword buckets from citizen questions"
                items={topics}
                formatLabel={formatTopicLabel}
              />
            </div>
            <div className="lg:col-span-1">
              <HelpfulnessPanel
                days={days}
                pct={overview?.helpfulness_pct_7d}
                up={overview?.feedback_up_7d ?? 0}
                down={overview?.feedback_down_7d ?? 0}
              />
            </div>
          </section>

          <section>
            <RecentFeedbackTable rows={feedback} />
          </section>
        </motion.div>
      )}
    </main>
  );
}
