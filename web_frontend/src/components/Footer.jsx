import {
  RiScales3Line,
  RiGithubLine,
  RiArrowRightUpLine,
  RiDownloadLine,
} from 'react-icons/ri';
import { SITE, FOUNDER } from '../config/site';

const links = [
  { href: '#problem', label: 'Problem' },
  { href: '#solution', label: 'Solution' },
  { href: '#how-it-works', label: 'How it works' },
  { href: '#features', label: 'Features' },
  { href: '#about', label: 'About' },
  { href: '#impact', label: 'Impact' },
  { href: '#roadmap', label: 'Shipped' },
  { href: '#coming-soon', label: 'Coming soon' },
  { href: '#download', label: 'Download' },
];

export default function Footer() {
  return (
    <footer className="border-t border-neutral-800 bg-dark text-white">
      <div className="mx-auto grid max-w-6xl gap-12 px-5 py-16 md:grid-cols-4 md:px-8">
        <div className="md:col-span-2">
          <div className="flex items-center gap-2.5">
            <span className="flex h-8 w-8 items-center justify-center rounded-md border border-primary/30 bg-primary/10">
              <RiScales3Line className="text-sm text-primary-light" />
            </span>
            <span className="font-display text-[15px] font-semibold">Court Companion</span>
          </div>
          <p className="mt-4 max-w-sm text-sm leading-relaxed text-neutral-500">
            AI legal multilingual assistant for Pakistan. Meta Llama via Together.ai.
            Built by {FOUNDER.name}.
          </p>
          <p className="mt-6 text-[12px] text-neutral-600">
            AI for Civic Innovation Hackathon 2026
          </p>
        </div>

        <div>
          <p className="label-caps !text-neutral-600">Links</p>
          <ul className="mt-4 space-y-2">
            {links.map((l) => (
              <li key={l.href}>
                <a
                  href={l.href}
                  className="text-sm text-neutral-500 transition hover:text-white"
                >
                  {l.label}
                </a>
              </li>
            ))}
          </ul>
        </div>

        <div>
          <p className="label-caps !text-neutral-600">Connect</p>
          <ul className="mt-4 space-y-3">
            <li>
              <a
                href={SITE.githubUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1.5 text-sm text-neutral-400 transition hover:text-white"
              >
                <RiGithubLine size={16} />
                GitHub
                <RiArrowRightUpLine size={14} />
              </a>
            </li>
            <li>
              <a
                href={SITE.apkUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1.5 text-sm text-neutral-400 transition hover:text-white"
              >
                <RiDownloadLine size={16} />
                Download APK
              </a>
            </li>
            <li>
              <a
                href={SITE.apiUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1.5 text-sm text-neutral-400 transition hover:text-white"
              >
                Live API
                <RiArrowRightUpLine size={14} />
              </a>
            </li>
          </ul>
        </div>
      </div>

      <div className="border-t border-neutral-800">
        <div className="mx-auto flex max-w-6xl flex-col gap-2 px-5 py-5 text-[12px] text-neutral-600 md:flex-row md:items-center md:justify-between md:px-8">
          <span>© 2026 Court Companion · {FOUNDER.name}</span>
          <span>Legal information only. Not legal advice.</span>
        </div>
      </div>
    </footer>
  );
}
