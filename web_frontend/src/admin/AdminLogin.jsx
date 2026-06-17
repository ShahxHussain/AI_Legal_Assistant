import { useState } from 'react';
import { Link } from 'react-router-dom';
import { setStoredAdminKey, verifyAdminKey } from '../api/adminClient';

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
    <div className="min-h-screen bg-[#F5F7FA]">
      <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center px-4 py-8 sm:px-6 sm:py-12">
        <Link
          to="/"
          className="mb-6 inline-flex min-h-[44px] items-center text-sm font-medium text-[#1F6F5F] hover:underline sm:mb-8"
        >
          ← Back to landing page
        </Link>

        <div className="rounded-2xl border border-[#E5E7EB] bg-white p-6 shadow-sm sm:p-8">
          <div className="mb-6 flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-[#1F6F5F] text-white">
              ⚖
            </div>
            <div>
              <h1 className="font-display text-xl font-bold text-[#0B2545]">
                Court Companion Admin
              </h1>
              <p className="text-sm text-[#6B7280]">Impact analytics dashboard</p>
            </div>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label
                htmlFor="admin-key"
                className="mb-2 block text-xs font-semibold uppercase tracking-wide text-[#6B7280]"
              >
                Admin API key
              </label>
              <input
                id="admin-key"
                type="password"
                value={key}
                onChange={(e) => setKey(e.target.value)}
                placeholder="Paste ADMIN_API_KEY from backend .env"
                className="w-full rounded-xl border border-[#E5E7EB] bg-[#F5F7FA] px-4 py-3.5 text-base outline-none ring-[#1F6F5F] focus:ring-2 sm:text-sm"
                autoComplete="off"
                required
              />
            </div>

            {error ? (
              <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-600">{error}</p>
            ) : null}

            <button
              type="submit"
              disabled={loading || !key.trim()}
              className="w-full min-h-[48px] rounded-xl bg-[#1F6F5F] px-4 py-3.5 text-sm font-semibold text-white transition hover:bg-[#185a4d] active:bg-[#134a40] disabled:cursor-not-allowed disabled:opacity-60"
            >
              {loading ? 'Verifying…' : 'Enter dashboard'}
            </button>
          </form>

          <p className="mt-5 text-xs leading-relaxed text-[#6B7280]">
            This page is for organizers only. Citizens never need a login — the mobile app
            uses anonymous device IDs.
          </p>
          <p className="mt-2 text-[11px] text-[#9CA3AF]">
            API: {import.meta.env.DEV ? '/api (local proxy → port 8000)' : 'production'}
          </p>
        </div>
      </div>
    </div>
  );
}
