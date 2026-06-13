import { motion } from 'framer-motion';
import {
  RiBrainLine,
  RiQuestionAnswerLine,
  RiMicLine,
  RiBarChartGroupedLine,
  RiThumbUpLine,
  RiUserSettingsLine,
  RiOpenSourceLine,
  RiWifiOffLine,
  RiSparklingLine,
} from 'react-icons/ri';
import { fadeUp, MotionSection, SectionLabel, stagger, GridBackdrop } from '../utils/motion';

const COMING = [
  {
    id: 'memory',
    icon: RiBrainLine,
    phase: 'Q3 2026',
    title: 'Conversation memory',
    summary: 'Multi-turn context so follow-ups make sense.',
    detail:
      'Remember prior questions in a session — e.g. after asking about FIR, ask "what about bail?" without repeating context.',
    demo: (
      <div className="space-y-2 text-[11px]">
        <div className="ml-auto w-[75%] rounded-md bg-neutral-800 px-2 py-1.5 text-white">
          What is FIR?
        </div>
        <div className="w-[80%] rounded-md border border-neutral-200 bg-white px-2 py-1.5 text-neutral-600">
          Under CrPC §154…
        </div>
        <div className="ml-auto w-[70%] rounded-md bg-primary/90 px-2 py-1.5 text-white">
          And bail for that?
        </div>
        <div className="flex items-center gap-1 text-primary">
          <RiSparklingLine size={12} />
          <span className="font-medium">Recalls FIR thread</span>
        </div>
      </div>
    ),
  },
  {
    id: 'agentic',
    icon: RiQuestionAnswerLine,
    phase: 'Q3 2026',
    title: 'Agentic follow-ups',
    summary: 'AI suggests the next question you should ask.',
    detail:
      'After answering, Court Companion proposes clarifying questions — offence type, city, arrest status — to narrow legal guidance.',
    demo: (
      <div className="flex flex-wrap gap-1.5">
        {['Was anyone arrested?', 'Which PPC section?', 'Need bail steps?'].map((q) => (
          <span
            key={q}
            className="rounded-full border border-dashed border-primary/40 bg-primary-pale px-2 py-1 text-[10px] font-medium text-primary"
          >
            {q}
          </span>
        ))}
      </div>
    ),
  },
  {
    id: 'voice-all',
    icon: RiMicLine,
    phase: 'Q4 2026',
    title: 'Voice in all 7 languages',
    summary: 'STT + TTS for Urdu, Pashto, Sindhi, and more.',
    detail:
      'Today voice is English-only. Next: speak and hear answers in every supported text language.',
    demo: (
      <div className="grid grid-cols-4 gap-1">
        {['EN', 'UR', 'PS', 'SD', 'PA', 'BN', 'RO'].map((code) => (
          <span
            key={code}
            className="rounded border border-neutral-200 bg-white py-1 text-center text-[9px] font-bold text-neutral-500"
          >
            {code}
          </span>
        ))}
        <span className="col-span-3 rounded border border-primary/30 bg-primary-pale py-1 text-center text-[9px] font-semibold text-primary">
          Mic · all langs
        </span>
      </div>
    ),
  },
  {
    id: 'admin',
    icon: RiBarChartGroupedLine,
    phase: 'Q4 2026',
    title: 'Admin analytics',
    summary: 'Dashboard for usage, languages, and impact.',
    detail:
      'Track questions per language, top PPC/CrPC topics, response latency, and citizen reach for NGOs and hackathon demos.',
    demo: (
      <div className="flex items-end gap-1 h-12">
        {[40, 65, 45, 80, 55, 90].map((h, i) => (
          <motion.div
            key={i}
            className="flex-1 rounded-t bg-primary/30"
            initial={{ height: '20%' }}
            whileHover={{ height: `${h}%`, backgroundColor: 'rgba(13, 92, 46, 0.55)' }}
            transition={{ duration: 0.3 }}
          />
        ))}
      </div>
    ),
  },
  {
    id: 'feedback',
    icon: RiThumbUpLine,
    phase: 'Q3 2026',
    title: 'Answer feedback',
    summary: 'Thumbs up / down on every response.',
    detail:
      'Citizens rate helpfulness per answer. Data improves prompts, retrieval, and model routing over time.',
    demo: (
      <div className="flex items-center justify-between rounded-lg border border-neutral-200 bg-white px-3 py-2">
        <span className="text-[10px] text-neutral-500">Was this helpful?</span>
        <div className="flex gap-2">
          <span className="rounded-md border border-primary/20 bg-primary-pale px-2 py-0.5 text-primary">
            <RiThumbUpLine size={14} />
          </span>
          <span className="rounded-md border border-neutral-200 px-2 py-0.5 text-neutral-400">
            ↓
          </span>
        </div>
      </div>
    ),
  },
  {
    id: 'accounts',
    icon: RiUserSettingsLine,
    phase: '2027',
    title: 'Accounts & history',
    summary: 'Save sessions and revisit past answers.',
    detail:
      'Optional sign-in to store chat history, uploaded documents, and favourite statute sections.',
    demo: (
      <div className="space-y-1.5">
        {['FIR procedure · Urdu', 'Bail under 497 · EN', 'Doc: charge sheet'].map((row) => (
          <div
            key={row}
            className="flex items-center justify-between rounded border border-neutral-100 bg-neutral-50 px-2 py-1 text-[10px] text-neutral-600"
          >
            {row}
            <span className="text-neutral-400">→</span>
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

  return (
    <motion.article
      custom={index}
      variants={fadeUp}
      whileHover={{ y: -6, scale: 1.01 }}
      transition={{ type: 'spring', stiffness: 400, damping: 28 }}
      className="coming-card group relative overflow-hidden rounded-2xl border border-neutral-200 bg-white p-5"
    >
      <div className="pointer-events-none absolute inset-0 bg-gradient-to-br from-primary/0 via-primary/0 to-primary/5 opacity-0 transition-opacity duration-300 group-hover:opacity-100" />
      <div className="relative">
        <div className="flex items-start justify-between gap-3">
          <span className="flex h-10 w-10 items-center justify-center rounded-lg border border-neutral-200 bg-neutral-50 transition-colors duration-300 group-hover:border-primary/25 group-hover:bg-primary-pale">
            <Icon className="text-lg text-neutral-600 transition-colors group-hover:text-primary" />
          </span>
          <span className="rounded-full border border-neutral-200 bg-neutral-50 px-2.5 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-neutral-500 transition-colors group-hover:border-primary/20 group-hover:text-primary">
            {item.phase}
          </span>
        </div>

        <h3 className="mt-4 text-[15px] font-semibold tracking-tight text-dark">{item.title}</h3>
        <p className="mt-1 text-[13px] text-neutral-500">{item.summary}</p>

        {/* Demo preview — always visible, animates on hover */}
        <div className="mt-4 rounded-xl border border-neutral-100 bg-neutral-50/80 p-3 transition-all duration-300 group-hover:border-primary/15 group-hover:bg-white group-hover:shadow-[0_8px_24px_rgba(13,92,46,0.08)]">
          <p className="mb-2 text-[9px] font-semibold uppercase tracking-widest text-neutral-400 group-hover:text-primary/70">
            Preview
          </p>
          {item.demo}
        </div>

        {/* Extra detail slides in on hover */}
        <motion.p
          initial={false}
          className="mt-3 max-h-0 overflow-hidden text-[12px] leading-relaxed text-neutral-500 opacity-0 transition-all duration-300 group-hover:max-h-24 group-hover:opacity-100"
        >
          {item.detail}
        </motion.p>

        <div className="mt-3 flex items-center gap-1.5 text-[11px] font-medium text-primary opacity-0 transition-opacity duration-300 group-hover:opacity-100">
          <RiSparklingLine size={14} />
          Coming soon
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
            Hover any card for a live-style preview and full description. Each feature
            is designed for civic impact at scale — not just demo day.
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
