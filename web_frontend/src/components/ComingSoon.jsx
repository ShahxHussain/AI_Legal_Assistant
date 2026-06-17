import { motion } from 'framer-motion';
import {
  RiFolderOpenLine,
  RiQuestionAnswerLine,
  RiScales3Line,
  RiMicLine,
  RiUserSettingsLine,
  RiOpenSourceLine,
  RiWifiOffLine,
  RiSparklingLine,
  RiVipCrownLine,
} from 'react-icons/ri';
import { fadeUp, MotionSection, stagger, GridBackdrop } from '../utils/motion';

const COMING = [
  {
    id: 'pro-workspace',
    icon: RiFolderOpenLine,
    phase: 'Pro · Beta',
    title: 'Full case workspace',
    summary: 'Upload FIR, pleadings, orders — one case, full context.',
    detail:
      'Court Companion Pro keeps every document in a single matter. Ask across filings without re-uploading. Free in beta; paid tiers at launch.',
    footer: 'In beta — explore in app',
    demo: (
      <div className="space-y-1.5">
        {['FIR · scanned PDF', 'Bail application', 'Order sheet'].map((row) => (
          <div
            key={row}
            className="flex items-center justify-between rounded border border-amber-200/60 bg-amber-50/50 px-2 py-1 text-[10px] text-amber-900"
          >
            {row}
            <RiVipCrownLine className="text-amber-600" size={12} />
          </div>
        ))}
      </div>
    ),
  },
  {
    id: 'agentic-pro',
    icon: RiQuestionAnswerLine,
    phase: 'Pro only',
    title: 'Agentic clarifying questions',
    summary: 'AI asks before it cites — theft vs snatching, bail category, etc.',
    detail:
      'Unlike free citizen chat, Pro asks for missing facts first so answers match the actual offence and procedure. Planned for lawyer workspace only.',
    footer: 'Court Companion Pro',
    demo: (
      <div className="flex flex-wrap gap-1.5">
        {['Was property taken?', 'Arrested or at large?', 'Which court?'].map((q) => (
          <span
            key={q}
            className="rounded-full border border-dashed border-amber-400/50 bg-amber-50 px-2 py-1 text-[10px] font-medium text-amber-900"
          >
            {q}
          </span>
        ))}
      </div>
    ),
  },
  {
    id: 'caselaw',
    icon: RiScales3Line,
    phase: 'Pro',
    title: 'Case-law retrieval',
    summary: 'Public judgments alongside PPC, CrPC, ATA statutes.',
    detail:
      'RAG over Supreme Court, High Court, and Sessions judgments — cited next to statute chunks for advocate-grade research.',
    footer: 'Coming to Pro',
    demo: (
      <div className="space-y-1 text-[10px]">
        <p className="rounded border border-neutral-200 bg-white px-2 py-1 text-neutral-600">
          PLD 2019 SC 123 · bail principles
        </p>
        <p className="rounded border border-primary/20 bg-primary-pale px-2 py-1 text-primary">
          CrPC §497 · indexed chunk
        </p>
      </div>
    ),
  },
  {
    id: 'voice-all',
    icon: RiMicLine,
    phase: 'Q4 2026',
    title: 'Voice in all 7 languages',
    summary: 'English & Urdu live today — Pashto, Sindhi, Punjabi, and more next.',
    detail:
      'STT + TTS for every supported text language so rural citizens can speak in their mother tongue, not just type.',
    footer: 'EN + UR shipped',
    demo: (
      <div className="grid grid-cols-4 gap-1">
        {[
          { code: 'EN', live: true },
          { code: 'UR', live: true },
          { code: 'PS', live: false },
          { code: 'SD', live: false },
          { code: 'PA', live: false },
          { code: 'BN', live: false },
          { code: 'RO', live: false },
        ].map(({ code, live }) => (
          <span
            key={code}
            className={`rounded py-1 text-center text-[9px] font-bold ${
              live
                ? 'border border-primary/40 bg-primary-pale text-primary'
                : 'border border-neutral-200 bg-white text-neutral-400'
            }`}
          >
            {code}
          </span>
        ))}
        <span className="col-span-4 rounded border border-neutral-200 bg-neutral-50 py-1 text-center text-[9px] text-neutral-500">
          Mic · 2 of 7 live
        </span>
      </div>
    ),
  },
  {
    id: 'accounts',
    icon: RiUserSettingsLine,
    phase: '2027',
    title: 'Accounts & sync',
    summary: 'Optional sign-in to sync history across devices.',
    detail:
      'Today history is per-device. Future: account to store chats, documents, and favourite statute sections in the cloud.',
    footer: 'Coming soon',
    demo: (
      <div className="space-y-1.5">
        {['FIR procedure · Urdu', 'Bail under 497 · EN', 'Doc: charge sheet'].map((row) => (
          <div
            key={row}
            className="flex items-center justify-between rounded border border-neutral-100 bg-neutral-50 px-2 py-1 text-[10px] text-neutral-600"
          >
            {row}
            <span className="text-neutral-400">☁</span>
          </div>
        ))}
      </div>
    ),
  },
  {
    id: 'opensource',
    icon: RiOpenSourceLine,
    phase: 'Post-hackathon',
    title: 'Open source release',
    summary: 'Public repo, docs, and contribution guide.',
    detail:
      'Full stack open for civic technologists — deploy your own instance with custom corpora or languages.',
    footer: 'Coming soon',
    demo: (
      <div className="rounded-lg border border-neutral-200 bg-neutral-900 px-3 py-2 font-mono text-[10px] text-green-400">
        <span className="text-neutral-500">$</span> git clone court-companion
        <br />
        <span className="text-neutral-500">$</span> docker compose up
      </div>
    ),
  },
  {
    id: 'offline',
    icon: RiWifiOffLine,
    phase: '2027',
    title: 'Offline FAQ cache',
    summary: 'Core rights available without internet.',
    detail:
      'Pre-loaded answers for FIR, arrest rights, and emergency steps — for rural areas with weak connectivity.',
    footer: 'Coming soon',
    demo: (
      <div className="flex items-center gap-2 rounded-lg border border-amber-200/80 bg-amber-50/80 px-2 py-2">
        <RiWifiOffLine className="text-amber-600" size={16} />
        <div className="text-[10px] text-amber-900">
          <p className="font-semibold">Offline mode</p>
          <p className="text-amber-700/80">12 cached legal FAQs</p>
        </div>
      </div>
    ),
  },
];

function ComingCard({ item, index }) {
  const Icon = item.icon;
  const isPro = item.phase.toLowerCase().includes('pro');

  return (
    <motion.article
      custom={index}
      variants={fadeUp}
      whileHover={{ y: -6, scale: 1.01 }}
      transition={{ type: 'spring', stiffness: 400, damping: 28 }}
      className={`coming-card group relative overflow-hidden rounded-2xl border bg-white p-5 ${
        isPro ? 'border-amber-200/80' : 'border-neutral-200'
      }`}
    >
      <div
        className={`pointer-events-none absolute inset-0 bg-gradient-to-br from-primary/0 via-primary/0 opacity-0 transition-opacity duration-300 group-hover:opacity-100 ${
          isPro ? 'to-amber-500/5' : 'to-primary/5'
        }`}
      />
      <div className="relative">
        <div className="flex items-start justify-between gap-3">
          <span
            className={`flex h-10 w-10 items-center justify-center rounded-lg border bg-neutral-50 transition-colors duration-300 ${
              isPro
                ? 'border-amber-200 group-hover:border-amber-300 group-hover:bg-amber-50'
                : 'border-neutral-200 group-hover:border-primary/25 group-hover:bg-primary-pale'
            }`}
          >
            <Icon
              className={`text-lg transition-colors ${
                isPro
                  ? 'text-amber-700 group-hover:text-amber-800'
                  : 'text-neutral-600 group-hover:text-primary'
              }`}
            />
          </span>
          <span
            className={`rounded-full border px-2.5 py-0.5 text-[10px] font-semibold uppercase tracking-wider ${
              isPro
                ? 'border-amber-200 bg-amber-50 text-amber-800'
                : 'border-neutral-200 bg-neutral-50 text-neutral-500 group-hover:border-primary/20 group-hover:text-primary'
            }`}
          >
            {item.phase}
          </span>
        </div>

        <h3 className="mt-4 text-[15px] font-semibold tracking-tight text-dark">{item.title}</h3>
        <p className="mt-1 text-[13px] text-neutral-500">{item.summary}</p>

        <div
          className={`mt-4 rounded-xl border p-3 transition-all duration-300 group-hover:shadow-[0_8px_24px_rgba(13,92,46,0.08)] ${
            isPro
              ? 'border-amber-100 bg-amber-50/50 group-hover:border-amber-200/60 group-hover:bg-white'
              : 'border-neutral-100 bg-neutral-50/80 group-hover:border-primary/15 group-hover:bg-white'
          }`}
        >
          <p
            className={`mb-2 text-[9px] font-semibold uppercase tracking-widest ${
              isPro ? 'text-amber-600/80' : 'text-neutral-400 group-hover:text-primary/70'
            }`}
          >
            Preview
          </p>
          {item.demo}
        </div>

        <motion.p
          initial={false}
          className="mt-3 max-h-0 overflow-hidden text-[12px] leading-relaxed text-neutral-500 opacity-0 transition-all duration-300 group-hover:max-h-24 group-hover:opacity-100"
        >
          {item.detail}
        </motion.p>

        <div
          className={`mt-3 flex items-center gap-1.5 text-[11px] font-medium opacity-0 transition-opacity duration-300 group-hover:opacity-100 ${
            isPro ? 'text-amber-800' : 'text-primary'
          }`}
        >
          <RiSparklingLine size={14} />
          {item.footer}
        </div>
      </div>
    </motion.article>
  );
}

export default function ComingSoon() {
  return (
    <MotionSection
      id="coming-soon"
      className="relative border-t border-neutral-200/80 py-24 md:py-32"
    >
      <GridBackdrop dense />
      <div className="relative mx-auto max-w-6xl px-5 md:px-8">
        <motion.div variants={fadeUp} className="max-w-2xl">
          <span className="inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary-pale/60 px-3 py-1">
            <RiSparklingLine className="text-primary" size={14} />
            <span className="text-[11px] font-semibold uppercase tracking-wider text-primary">
              Roadmap · Coming soon
            </span>
          </span>
          <h2 className="mt-5 font-display text-3xl font-semibold tracking-[-0.02em] text-dark md:text-4xl">
            What we&apos;re building next
          </h2>
          <p className="mt-4 text-[15px] leading-relaxed text-neutral-500">
            Conversation memory, feedback, and admin analytics are already live in the
            web app. Hover any card for a preview — Pro features are separate from free
            citizen chat.
          </p>
        </motion.div>

        <motion.div
          variants={stagger}
          className="mt-14 grid gap-5 sm:grid-cols-2 lg:grid-cols-4"
        >
          {COMING.map((item, i) => (
            <ComingCard key={item.id} item={item} index={i} />
          ))}
        </motion.div>
      </div>
      <div className="accent-bar mx-auto mt-16 max-w-6xl" />
    </MotionSection>
  );
}
