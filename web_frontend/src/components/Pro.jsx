import { motion } from 'framer-motion';
import {
  RiVipCrownLine,
  RiQuestionAnswerLine,
  RiFolderOpenLine,
  RiScales3Line,
  RiArrowRightLine,
  RiExternalLinkLine,
  RiCheckLine,
  RiCloseLine,
} from 'react-icons/ri';
import { SITE, PRO_FEATURES } from '../config/site';
import { fadeUp, MotionSection, SectionLabel, stagger, GridBackdrop } from '../utils/motion';

const COMPARE = [
  { label: 'Audience', free: 'Citizens', pro: 'Lawyers & advocates' },
  { label: 'Input', free: 'Questions + optional doc attach', pro: 'Full case files & pleadings' },
  { label: 'Follow-up', free: 'You ask the next question', pro: 'AI asks clarifying questions first' },
  { label: 'Knowledge', free: 'PPC, CrPC, ATA statutes', pro: 'Statutes + public case law' },
  { label: 'Price', free: 'Free always', pro: 'Free in beta · paid at launch' },
];

export default function Pro() {
  return (
    <MotionSection
      id="pro"
      className="relative overflow-hidden border-t border-neutral-200/80 py-24 md:py-32"
    >
      <div className="pro-surface absolute inset-0 opacity-[0.03]" aria-hidden />
      <GridBackdrop dense />

      <div className="relative mx-auto max-w-6xl px-5 md:px-8">
        <motion.div variants={fadeUp} className="mx-auto max-w-3xl text-center">
          <span className="inline-flex items-center gap-2 rounded-full border border-amber-300/50 bg-amber-50 px-3 py-1">
            <RiVipCrownLine className="text-amber-700" size={14} />
            <span className="text-[11px] font-bold uppercase tracking-wider text-amber-800">
              Beta · Free for now
            </span>
          </span>
          <SectionLabel className="!mt-6 !text-primary">Court Companion Pro</SectionLabel>
          <h2 className="mt-4 font-display text-3xl font-semibold tracking-[-0.02em] text-dark md:text-4xl lg:text-[2.75rem]">
            Professional case workspace for lawyers
          </h2>
          <p className="mt-5 text-[15px] leading-relaxed text-neutral-600">
            Separate from free citizen chat. Pro is built for advocates who need deep case
            analysis — agentic clarifying questions, document upload, case-law search, and
            procedural gap flags. Explore the product vision in the app today; full workspace
            ships next.
          </p>
        </motion.div>

        <motion.div
          variants={stagger}
          className="mt-14 grid gap-4 sm:grid-cols-2 lg:grid-cols-4"
        >
          {PRO_FEATURES.map((f, i) => (
            <motion.div
              key={f.title}
              custom={i}
              variants={fadeUp}
              className="rounded-xl border border-neutral-200 bg-white p-5 shadow-sm transition hover:border-primary/20 hover:shadow-md"
            >
              <span className="flex h-9 w-9 items-center justify-center rounded-lg bg-dark/5">
                {i === 0 && <RiQuestionAnswerLine className="text-dark" size={18} />}
                {i === 1 && <RiFolderOpenLine className="text-dark" size={18} />}
                {i === 2 && <RiScales3Line className="text-dark" size={18} />}
                {i === 3 && <RiVipCrownLine className="text-dark" size={18} />}
              </span>
              <h3 className="mt-4 text-[14px] font-semibold text-dark">{f.title}</h3>
              <p className="mt-2 text-[12px] leading-relaxed text-neutral-500">{f.text}</p>
            </motion.div>
          ))}
        </motion.div>

        <motion.div
          variants={fadeUp}
          className="mt-14 overflow-hidden rounded-2xl border border-neutral-200 bg-white shadow-sm"
        >
          <div className="border-b border-neutral-100 bg-neutral-50 px-5 py-4 md:px-8">
            <p className="text-[13px] font-semibold text-dark">Citizen chat vs Court Companion Pro</p>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full min-w-[520px] text-left text-[13px]">
              <thead>
                <tr className="border-b border-neutral-100">
                  <th className="px-5 py-3 font-medium text-neutral-500 md:px-8"> </th>
                  <th className="px-4 py-3 font-semibold text-primary">Ask in chat (free)</th>
                  <th className="px-4 py-3 font-semibold text-dark">Court Companion Pro</th>
                </tr>
              </thead>
              <tbody>
                {COMPARE.map((row) => (
                  <tr key={row.label} className="border-b border-neutral-50 last:border-0">
                    <td className="px-5 py-3.5 font-medium text-neutral-600 md:px-8">{row.label}</td>
                    <td className="px-4 py-3.5 text-neutral-600">
                      <span className="inline-flex items-start gap-2">
                        <RiCheckLine className="mt-0.5 shrink-0 text-primary" size={14} />
                        {row.free}
                      </span>
                    </td>
                    <td className="px-4 py-3.5 text-neutral-700">
                      <span className="inline-flex items-start gap-2">
                        <RiVipCrownLine className="mt-0.5 shrink-0 text-amber-600" size={14} />
                        {row.pro}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </motion.div>

        <motion.div
          variants={fadeUp}
          className="pro-cta-card mx-auto mt-12 max-w-2xl rounded-2xl p-8 text-center text-white md:p-10"
        >
          <p className="text-[11px] font-bold uppercase tracking-widest text-white/70">
            In the Flutter app
          </p>
          <h3 className="mt-3 font-display text-2xl font-semibold tracking-tight">
            Open Court Companion Pro
          </h3>
          <p className="mt-3 text-[14px] leading-relaxed text-white/85">
            Home screen → <strong>Court Companion Pro</strong> (BETA). Full product details,
            how it works, and what&apos;s coming — no install required in the browser.
          </p>
          <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <a
              href={SITE.webAppUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-lg bg-white px-7 py-3 text-[14px] font-semibold text-dark transition hover:bg-neutral-100"
            >
              Open web app
              <RiArrowRightLine size={16} />
            </a>
            <a
              href={SITE.proDocUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-lg border border-white/30 px-6 py-3 text-[14px] font-medium text-white transition hover:bg-white/10"
            >
              Read design doc
              <RiExternalLinkLine size={14} />
            </a>
          </div>
          <p className="mt-6 flex items-center justify-center gap-2 text-[12px] text-white/60">
            <RiCloseLine size={14} />
            Workspace & case upload — coming soon · citizen chat stays free
          </p>
        </motion.div>
      </div>
      <div className="accent-bar mx-auto mt-16 max-w-6xl" />
    </MotionSection>
  );
}
