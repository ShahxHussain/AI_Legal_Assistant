import { Link, NavLink, Outlet, useNavigate } from 'react-router-dom';
import {
  RiLogoutBoxRLine,
  RiScales3Line,
  RiExternalLinkLine,
  RiBarChartGroupedLine,
  RiSurveyLine,
} from 'react-icons/ri';
import { setStoredAdminKey } from '../api/adminClient';

const NAV = [
  {
    to: '/admin',
    end: true,
    label: 'Live impact',
    icon: RiBarChartGroupedLine,
    activeClass: 'admin-nav-active',
  },
  {
    to: '/admin/traction',
    end: false,
    label: 'Market traction',
    icon: RiSurveyLine,
    activeClass: 'admin-nav-traction-active',
  },
];

export default function AdminLayout({ onUnauthorized }) {
  const navigate = useNavigate();

  function handleLogout() {
    setStoredAdminKey('');
    onUnauthorized?.();
    navigate('/admin');
  }

  return (
    <div className="relative min-h-screen grid-lines">
      <div className="accent-bar fixed left-0 right-0 top-0 z-50" />

      <header className="glass-nav sticky top-[3px] z-40 border-b border-neutral-200/80">
        <div className="mx-auto max-w-7xl px-4 py-4 sm:px-6">
          <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <div className="flex min-w-0 items-center gap-3">
              <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-primary/20 bg-primary-pale/80">
                <RiScales3Line className="text-lg text-primary" />
              </span>
              <div className="min-w-0">
                <h1 className="truncate font-display text-lg font-bold tracking-tight text-dark">
                  Court Companion
                </h1>
                <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-neutral-500">
                  Organizer console
                </p>
              </div>
            </div>

            <nav className="flex flex-wrap items-center gap-2">
              {NAV.map(({ to, end, label, icon: Icon, activeClass }) => (
                <NavLink
                  key={to}
                  to={to}
                  end={end}
                  className={({ isActive }) =>
                    `inline-flex items-center gap-2 rounded-xl border px-4 py-2 text-[13px] font-semibold transition-all duration-200 ${
                      isActive
                        ? activeClass
                        : 'admin-nav-idle border-transparent'
                    }`
                  }
                >
                  <Icon size={16} />
                  {label}
                </NavLink>
              ))}
            </nav>

            <div className="flex flex-wrap items-center gap-2">
              <Link to="/" className="btn-secondary !py-2">
                <RiExternalLinkLine size={15} />
                Site
              </Link>
              <button type="button" onClick={handleLogout} className="btn-green !py-2">
                <RiLogoutBoxRLine size={16} />
                Log out
              </button>
            </div>
          </div>
        </div>
      </header>

      <Outlet />

      <footer className="border-t border-neutral-200/80 bg-white/60 py-6 text-center text-[12px] text-neutral-400">
        Court Companion · Organizer dashboard · Not visible to citizens
      </footer>
    </div>
  );
}
