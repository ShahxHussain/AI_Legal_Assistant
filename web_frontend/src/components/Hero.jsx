import { motion } from 'framer-motion';
import {
  RiArrowRightLine,
  RiMapPinLine,
  RiTranslate2,
  RiSmartphoneLine,
  RiBookOpenLine,
  RiExternalLinkLine,
  RiDownloadLine,
  RiVipCrownLine,
} from 'react-icons/ri';
import { SITE } from '../config/site';
import { fadeUp, GridBackdrop } from '../utils/motion';

const trust = [
  { icon: RiBookOpenLine, label: 'PPC · CrPC · ATA' },
  { icon: RiTranslate2, label: '7 languages' },
  { icon: RiSmartphoneLine, label: 'Web + Android' },
];

export default function Hero() {
  return (
    <section className="relative min-h-[100svh] overflow-hidden pt-14 pakistan-tint">
      <GridBackdrop />
      <div className="accent-bar absolute bottom-0 left-0 right-0" />
      <div className="relative mx-auto grid max-w-6xl items-center gap-16 px-5 pb-20 pt-16 md:grid-cols-2 md:px-8 md:pb-28 md:pt-24">
        <div>
          <motion.div
            custom={0}
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            className="inline-flex items-center gap-2 rounded-full border border-primary/15 bg-white/90 px-3 py-1.5 shadow-sm"
          >
            <RiMapPinLine className="text-sm text-primary" />
            <span className="text-[12px] font-medium text-neutral-600">
              Pakistan · Civic legal access
            </span>
          </motion.div>

          <motion.h1
            custom={1}
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            className="mt-8 font-display text-[2.75rem] font-semibold leading-[1.05] tracking-[-0.03em] text-dark md:text-[3.5rem] lg:text-[4rem]"
          >
            Legal rights,
            <br />
            <span className="text-shimmer-green">in your language.</span>
          </motion.h1>

          <motion.p
            custom={2}
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            className="mt-6 max-w-md text-[15px] leading-relaxed text-neutral-500 md:text-base"
          >
            Court Companion answers questions about Pakistani criminal law — FIR, bail,
            PPC and CrPC — grounded in real statute text via RAG, powered by{' '}
            <span className="font-medium text-dark">Meta Llama</span> on{' '}
            <span className="font-medium text-dark">Together.ai</span>. Use it in the
            browser or on Android — plus{' '}
            <span className="font-medium text-dark">Court Companion Pro</span> for lawyers.
          </motion.p>

          <motion.div
            custom={3}
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            className="mt-9 flex flex-wrap items-center gap-3"
          >
            <a
              href={SITE.webAppUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="btn-green px-6 py-3"
            >
              Open web app
              <RiArrowRightLine size={16} />
            </a>
            <a href="#pro" className="btn-pro-outline px-5 py-3">
              <RiVipCrownLine size={16} />
              Court Companion Pro
            </a>
            <a
              href={SITE.apkUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="btn-secondary px-5 py-3"
            >
              <RiDownloadLine size={16} />
              APK
            </a>
            <a
              href={SITE.githubUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="btn-secondary px-5 py-3"
            >
              GitHub
              <RiExternalLinkLine size={14} />
            </a>
          </motion.div>

          <motion.ul
            custom={4}
            variants={fadeUp}
            initial="hidden"
            animate="visible"
            className="mt-10 flex flex-wrap gap-6"
          >
            {trust.map(({ icon: Icon, label }) => (
              <li key={label} className="flex items-center gap-2 text-[13px] text-neutral-500">
                <span className="flex h-7 w-7 items-center justify-center rounded-md border border-primary/10 bg-primary-pale/50">
                  <Icon className="text-primary" size={14} />
                </span>
                {label}
              </li>
            ))}
          </motion.ul>
        </div>

        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.25, duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
          className="relative mx-auto w-full max-w-[320px]"
        >
          <div className="absolute -inset-8 rounded-3xl bg-gradient-to-b from-primary/10 to-transparent blur-2xl" />
          <a
            href={SITE.webAppUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="relative block rounded-2xl border border-neutral-200 bg-white p-1 shadow-[0_20px_50px_rgba(0,0,0,0.08)] ring-1 ring-primary/5 transition hover:ring-primary/20"
            aria-label="Open Court Companion web app"
          >
            <div className="rounded-xl border border-neutral-100 bg-neutral-50 p-4">
              <div className="mb-4 flex items-center justify-between border-b border-neutral-200/80 pb-3">
                <div className="flex items-center gap-2">
                  <span className="h-2 w-2 rounded-full bg-primary shadow-[0_0_8px_rgba(13,92,46,0.5)]" />
                  <span className="text-xs font-semibold tracking-tight text-dark">
                    Court Companion
                  </span>
                </div>
                <span className="rounded-md bg-primary-pale px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-primary">
                  Live
                </span>
              </div>
              <div className="space-y-3">
                <div className="ml-auto max-w-[88%] rounded-lg rounded-br-sm bg-dark px-3 py-2.5">
                  <p className="font-urdu text-[13px] leading-relaxed text-white">
                    ایف آئی آر کس طرح درج ہوتی ہے؟
                  </p>
                </div>
                <div className="max-w-[92%] rounded-lg rounded-bl-sm border border-neutral-200 bg-white px-3 py-2.5">
                  <p className="font-urdu text-[12px] leading-relaxed text-neutral-700">
                    CrPC کی دفعہ 154 کے تحت، FIR درج کرنا پولیس کی قانونی ذمہ داری ہے
                    <span className="cursor-blink ml-0.5 inline-block h-3.5 w-px align-middle bg-primary" />
                  </p>
                  <span className="mt-2 inline-flex items-center gap-1 rounded-md border border-primary/15 bg-primary-pale px-2 py-0.5 text-[10px] font-medium text-primary">
                    CrPC §154
                  </span>
                </div>
              </div>
              <p className="mt-4 text-center text-[11px] font-medium text-primary">
                Tap to open web app →
              </p>
            </div>
          </a>
        </motion.div>
      </div>
    </section>
  );
}
