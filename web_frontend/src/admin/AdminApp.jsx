import { useState } from 'react';
import { Routes, Route } from 'react-router-dom';
import { getStoredAdminKey } from '../api/adminClient';
import AdminDashboard from './AdminDashboard';
import AdminLayout from './AdminLayout';
import AdminLogin from './AdminLogin';
import AdminTraction from './AdminTraction';

export default function AdminApp() {
  const [authed, setAuthed] = useState(() => Boolean(getStoredAdminKey()));

  if (!authed) {
    return <AdminLogin onSuccess={() => setAuthed(true)} />;
  }

  return (
    <Routes>
      <Route
        element={<AdminLayout onUnauthorized={() => setAuthed(false)} />}
      >
        <Route index element={<AdminDashboard />} />
        <Route path="traction" element={<AdminTraction />} />
      </Route>
    </Routes>
  );
}
