import { motion } from 'framer-motion';
import {
  RiDownloadLine,
  RiGlobalLine,
  RiSmartphoneLine,
  RiInformationLine,
  RiExternalLinkLine,
  RiArrowRightLine,
} from 'react-icons/ri';
import { SITE } from '../config/site';
import { fadeUp, MotionSection, SectionLabel, GridBackdrop } from '../utils/motion';

export default function Download() {
  return (
    <MotionSection id="get-app" className="relative border-t border-neutral-200/80 py-24 md:py-32">
      <GridBackdrop dense />
      <div className="relative mx-auto max-w-4xl px-5 md:px-8">
        <motion.div variants={fadeUp} className="text-center">
          <SectionLabel>Get Court Companion</SectionLabel>
          <h2 className="mt-4 font-display text-3xl font-semibold tracking-[-0.02em] text-dark md:text-4xl">
            Web or Android — your choice
          </h2>
          <p className="mx-auto mt-4 max-w-lg text-[15px] text-neutral-500">
            Free. No login required for citizen chat. Same RAG backend on Render — Meta Llama
            via Together.ai.
          </p>
        </motion.div>

        <motion.div
          variants={fadeUp}
          className="mt-12 grid gap-5 md:grid-cols-2"
        >
          <article className="relative overflow-hidden rounded-2xl border-2 border-primary/30 bg-white p-8 shadow-sm">
            <span className="absolute right-4 top-4 rounded-full bg-primary px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wider text-white">
              Recommended
            </span>
            <span className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary-pale">
              <RiGlobalLine className="text-xl text-primary" />
            </span>
            <h3 className="mt-6 text-xl font-semibold text-dark">Open in browser</h3>
            <p className="mt-3 text-[14px] leading-relaxed text-neutral-500">
              Full Flutter web app — chat, voice (English & Urdu), chat history sidebar,
              Court Companion Pro beta. Works on desktop and mobile Chrome.
            </p>
            <ul className="mt-5 space-y-2 text-[13px] text-neutral-600">
              <li>✓ No install · instant access</li>
              <li>✓ Always latest deploy from Vercel</li>
              <li>✓ Same features as Android</li>
            </ul>
            <a
              href={SITE.webAppUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="btn-green mt-8 w-full py-3.5 text-[15px]"
            >
              Open web app
              <RiArrowRightLine size={18} />
            </a>
          </article>

          <article className="rounded-2xl border border-neutral-200 bg-neutral-50/80 p-8">
            <span className="flex h-12 w-12 items-center justify-center rounded-xl border border-neutral-200 bg-white">
              <RiSmartphoneLine className="text-xl text-neutral-600" />
            </span>
            <h3 className="mt-6 text-xl font-semibold text-dark">Android APK</h3>
            <p className="mt-3 text-[14px] leading-relaxed text-neutral-500">
              Sideload the release build for offline-first home-screen access. Android 7+.
            </p>
            <ul className="mt-5 space-y-2 text-[13px] text-neutral-600">
              <li>✓ Native mic permissions for voice</li>
              <li>✓ Points to live Render API</li>
            </ul>
            <div className="mt-8 flex flex-col gap-3">
              <a
                href={SITE.apkUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="btn-secondary w-full py-3.5 text-[15px]"
              >
                <RiDownloadLine size={18} />
                Download APK
              </a>
              <a
                href={SITE.apkViewUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center justify-center gap-2 text-[13px] font-medium text-neutral-500 hover:text-primary"
              >
                View on Google Drive
                <RiExternalLinkLine size={14} />
              </a>
            </div>
          </article>
        </motion.div>

        <motion.div
          variants={fadeUp}
          className="mt-10 flex gap-3 rounded-xl border border-primary/15 bg-primary-pale/40 p-5"
        >
          <RiInformationLine className="mt-0.5 shrink-0 text-primary" size={18} />
          <p className="text-[13px] leading-relaxed text-neutral-600">
            Court Companion provides legal information only. It does not replace a
            qualified lawyer. Consult a licensed professional for your specific situation.
          </p>
        </motion.div>
      </div>
      <div className="accent-bar mx-auto mt-16 max-w-6xl" />
    </MotionSection>
  );
}
