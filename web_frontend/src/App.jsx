import { BrowserRouter, Route, Routes } from 'react-router-dom';
import AdminApp from './admin/AdminApp';
import LandingApp from './LandingApp';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/admin/*" element={<AdminApp />} />
        <Route path="/*" element={<LandingApp />} />
      </Routes>
    </BrowserRouter>
  );
}
