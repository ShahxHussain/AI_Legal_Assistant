import { useState } from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { RiScales3Line, RiShieldKeyholeLine } from 'react-icons/ri';
import { getApiBaseUrl, setStoredAdminKey, verifyAdminKey } from '../api/adminClient';

export default function AdminLogin({ onSuccess }) {
  const [key, setKey] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  async function handleSubmit(event) {
    event.preventDefault();
    setLoading(true);
    setError('');
    try {
      await verifyAdminKey(key.trim());
      onSuccess?.();
    } catch (err) {
      setStoredAdminKey('');
      setError(err.code === 'UNAUTHORIZED' ? 'Invalid admin key.' : err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="relative min-h-screen grid-lines pakistan-tint">
      <div className="accent-bar absolute bottom-0 left-0 right-0" />

      <div className="relative mx-auto flex min-h-screen max-w-md flex-col justify-center px-5 py-12">
        <Link
          to="/"
          className="mb-8 inline-flex items-center text-sm font-medium text-primary hover:underline"
        >
          ← Back to landing page
        </Link>

        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="admin-card overflow-hidden p-8 shadow-[0_20px_50px_rgba(0,0,0,0.06)]"
        >
          <div className="mb-8 flex items-center gap-4">
            <span className="flex h-12 w-12 items-center justify-center rounded-xl border border-primary/20 bg-primary-pale">
              <RiScales3Line className="text-xl text-primary" />
            </span>
            <div>
              <h1 className="font-display text-xl font-bold tracking-tight text-dark">
                Court Companion
              </h1>
              <p className="text-sm text-neutral-500">Organizer impact dashboard</p>
            </div>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label htmlFor="admin-key" className="label-caps mb-2 block">
                Admin API key
              </label>
              <div className="relative">
                <RiShieldKeyholeLine className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-neutral-400" />
                <input
                  id="admin-key"
                  type="password"
                  value={key}
                  onChange={(e) => setKey(e.target.value)}
                  placeholder="Paste ADMIN_API_KEY"
                  className="w-full rounded-xl border border-neutral-200 bg-neutral-50/80 py-3.5 pl-11 pr-4 text-sm outline-none ring-primary/30 transition focus:border-primary/30 focus:bg-white focus:ring-2"
                  autoComplete="off"
                  required
                />
              </div>
            </div>

            {error ? (
              <p className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
                {error}
              </p>
            ) : null}

            <button
              type="submit"
              disabled={loading || !key.trim()}
              className="btn-green w-full py-3.5 text-[15px] disabled:cursor-not-allowed disabled:opacity-60"
            >
              {loading ? 'Verifying…' : 'Enter dashboard'}
            </button>
          </form>

          <p className="mt-6 text-[12px] leading-relaxed text-neutral-500">
            For hackathon organizers and NGOs only. Citizens use the app without login —
            anonymous device IDs power these metrics.
          </p>
          <p className="mt-2 text-[11px] text-neutral-400">
            API: {getApiBaseUrl()}
          </p>
        </motion.div>
      </div>
    </div>
  );
}
