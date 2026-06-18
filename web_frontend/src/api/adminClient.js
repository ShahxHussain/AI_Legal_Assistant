import { SITE } from '../config/site';

const STORAGE_KEY = 'court_companion_admin_key';

/** Dev uses Vite proxy `/api` → localhost:8000 (avoids CORS). */
export function getApiBaseUrl() {
  const fromEnv = import.meta.env.VITE_API_BASE_URL;
  if (fromEnv && String(fromEnv).trim()) {
    return String(fromEnv).replace(/\/$/, '');
  }
  if (import.meta.env.DEV) {
    return '/api';
  }
  return SITE.apiUrl.replace(/\/$/, '');
}

export function getStoredAdminKey() {
  return sessionStorage.getItem(STORAGE_KEY) || '';
}

export function setStoredAdminKey(key) {
  if (key) sessionStorage.setItem(STORAGE_KEY, key);
  else sessionStorage.removeItem(STORAGE_KEY);
}

async function adminFetch(path, { adminKey } = {}) {
  const base = getApiBaseUrl();
  const url = `${base}${path}`;

  let response;
  try {
    response = await fetch(url, {
      headers: {
        Accept: 'application/json',
        'X-Admin-Key': adminKey || getStoredAdminKey(),
      },
    });
  } catch (_) {
    throw new Error(
      `Cannot reach the API (${url}). ` +
        (import.meta.env.DEV
          ? 'Start the backend: cd backend && uvicorn main:app --reload --host 0.0.0.0 --port 8000'
          : `Set VITE_API_BASE_URL to your deployed API (currently ${base}).`),
    );
  }

  if (response.status === 401) {
    const err = new Error('Invalid admin key');
    err.code = 'UNAUTHORIZED';
    throw err;
  }
  if (!response.ok) {
    let detail = `Request failed (${response.status})`;
    try {
      const body = await response.json();
      detail = body.detail || detail;
    } catch (_) {}
    throw new Error(detail);
  }
  return response.json();
}

export async function verifyAdminKey(adminKey) {
  await adminFetch('/admin/stats/overview?days=7', { adminKey });
  setStoredAdminKey(adminKey);
}

export function fetchOverview(days = 7) {
  return adminFetch(`/admin/stats/overview?days=${days}`);
}

export function fetchQuestionsPerDay(days = 30) {
  return adminFetch(`/admin/stats/questions-per-day?days=${days}`);
}

export function fetchLanguages(days = 30) {
  return adminFetch(`/admin/stats/languages?days=${days}`);
}

export function fetchTopics(days = 30) {
  return adminFetch(`/admin/stats/topics?days=${days}`);
}

export function fetchRecentFeedback(limit = 50) {
  return adminFetch(`/admin/feedback/recent?limit=${limit}`);
}
