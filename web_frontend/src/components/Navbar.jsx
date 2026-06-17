import { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  RiArrowRightLine,
  RiMenu3Line,
  RiCloseLine,
  RiScales3Line,
  RiDownloadLine,
} from 'react-icons/ri';
import { SITE } from '../config/site';

const LINKS = [
  { href: '#problem', label: 'Problem' },
  { href: '#solution', label: 'Solution' },
  { href: '#features', label: 'Features' },
  { href: '#pro', label: 'Pro' },
  { href: '#about', label: 'About' },
  { href: '#impact', label: 'Impact' },
  { href: '#get-app', label: 'Get app' },
];

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 8);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <motion.header
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
      className={`fixed inset-x-0 top-0 z-50 border-b transition-colors duration-300 ${
        scrolled
          ? 'glass-nav border-neutral-200/80'
          : 'border-transparent bg-transparent'
      }`}
    >
      <nav className="mx-auto flex h-14 max-w-6xl items-center justify-between px-5 md:px-8">
        <a href="#" className="group flex items-center gap-2.5">
          <span className="flex h-8 w-8 items-center justify-center rounded-md border border-primary/20 bg-primary-pale/60 transition group-hover:border-primary/40">
            <RiScales3Line className="text-base text-primary" />
          </span>
          <span className="font-display text-[15px] font-semibold tracking-tight text-dark">
            Court Companion
          </span>
        </a>

        <div className="hidden items-center gap-5 xl:flex">
          {LINKS.map((l) => (
            <a
              key={l.href}
              href={l.href}
              className="text-[13px] font-medium text-neutral-500 transition hover:text-primary"
            >
              {l.label}
            </a>
          ))}
          <a
            href={SITE.webAppUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="btn-green !py-2 !text-[13px]"
          >
            Open web app
            <RiArrowRightLine size={15} />
          </a>
          <a
            href={SITE.apkUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 rounded-lg border border-primary/45 bg-white px-4 py-2 text-[13px] font-medium text-primary transition hover:bg-primary-pale/50"
          >
            <RiDownloadLine size={15} />
            Download app
          </a>
        </div>

        <div className="flex items-center gap-2 xl:hidden">
          <a
            href={SITE.webAppUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="btn-green !py-2 !text-[12px]"
          >
            Open web app
          </a>
          <button
            type="button"
            className="flex h-9 w-9 items-center justify-center rounded-md border border-neutral-200 bg-white"
            onClick={() => setOpen((v) => !v)}
            aria-label="Menu"
          >
            {open ? <RiCloseLine size={18} /> : <RiMenu3Line size={18} />}
          </button>
        </div>
      </nav>

      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="overflow-hidden border-t border-neutral-200 bg-white xl:hidden"
          >
            <div className="flex flex-col gap-0.5 px-4 py-3">
              {LINKS.map((l) => (
                <a
                  key={l.href}
                  href={l.href}
                  onClick={() => setOpen(false)}
                  className="rounded-md px-3 py-2.5 text-sm text-neutral-600 hover:bg-primary-pale/50"
                >
                  {l.label}
                </a>
              ))}
              <a
                href={SITE.apkUrl}
                target="_blank"
                rel="noopener noreferrer"
                onClick={() => setOpen(false)}
                className="mt-2 inline-flex w-full items-center justify-center gap-2 rounded-lg border border-primary/45 bg-white px-4 py-2.5 text-[13px] font-medium text-primary transition hover:bg-primary-pale/50"
              >
                <RiDownloadLine size={15} />
                Download app
              </a>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.header>
  );
}
