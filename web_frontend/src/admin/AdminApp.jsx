import { useState } from 'react';
import { getStoredAdminKey } from '../api/adminClient';
import AdminDashboard from './AdminDashboard';
import AdminLogin from './AdminLogin';

export default function AdminApp() {
  const [authed, setAuthed] = useState(() => Boolean(getStoredAdminKey()));

  if (!authed) {
    return <AdminLogin onSuccess={() => setAuthed(true)} />;
  }

  return <AdminDashboard onUnauthorized={() => setAuthed(false)} />;
}
