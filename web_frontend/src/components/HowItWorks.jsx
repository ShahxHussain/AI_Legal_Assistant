import { motion } from 'framer-motion';
import { RiMicLine, RiSearchLine, RiChatCheckLine, RiArrowRightSLine } from 'react-icons/ri';
import { fadeUp, MotionSection, SectionLabel, stagger, GridBackdrop } from '../utils/motion';

const steps = [
  {
    n: '01',
    icon: RiMicLine,
    title: 'You ask',
    text: 'Type or speak in any of seven languages — Urdu, Pashto, Sindhi, or English.',
  },
  {
    n: '02',
    icon: RiSearchLine,
    title: 'System searches',
    text: 'Question translates to English for search only. FAISS retrieves relevant PPC, CrPC, or ATA sections.',
  },
  {
    n: '03',
    icon: RiChatCheckLine,
    title: 'You get an answer',
    text: 'AI explains the statute in your language — with citations, streamed in real time.',
  },
];

const tech = ['RAG', 'FAISS', 'Llama 70B', 'Llama 8B', 'Together.ai', 'Flutter', 'FastAPI'];

export default function HowItWorks() {
  return (
    <MotionSection id="how-it-works" className="relative border-t border-neutral-200/80 py-24 md:py-32">
      <GridBackdrop />
      <div className="relative mx-auto max-w-6xl px-5 md:px-8">
        <motion.div variants={fadeUp} className="max-w-xl">
          <SectionLabel>Under the hood</SectionLabel>
          <h2 className="mt-4 font-display text-3xl font-semibold tracking-[-0.02em] text-dark md:text-4xl">
            Two pipelines. One goal.
          </h2>
          <p className="mt-4 text-[15px] text-neutral-500">
            The legal database is in English. Your answer doesn&apos;t have to be.
          </p>
        </motion.div>

        <motion.div variants={stagger} className="mt-14 grid gap-4 md:grid-cols-3">
          {steps.map((s, i) => (
            <motion.div key={s.title} custom={i} variants={fadeUp} className="relative">
              <div className="card-premium h-full p-6">
                <div className="flex items-center justify-between">
                  <span className="text-[11px] font-semibold tabular-nums text-neutral-400">
                    {s.n}
                  </span>
                  <s.icon className="text-lg text-neutral-500" />
                </div>
                <h3 className="mt-6 text-[15px] font-semibold text-dark">{s.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-neutral-500">{s.text}</p>
              </div>
              {i < steps.length - 1 && (
                <RiArrowRightSLine
                  className="absolute -right-3 top-1/2 z-10 hidden -translate-y-1/2 text-neutral-300 md:block"
                  size={20}
                />
              )}
            </motion.div>
          ))}
        </motion.div>

        <motion.div
          variants={fadeUp}
          className="mt-10 rounded-xl border border-neutral-200 bg-white px-6 py-5"
        >
          <p className="text-[14px] font-semibold text-dark">
            Search speaks English. Answer speaks your language.
          </p>
          <p className="mt-1 text-sm text-neutral-500">
            Two separate processes — no machine-translated output.
          </p>
        </motion.div>

        <motion.div variants={fadeUp} className="mt-6 flex flex-wrap gap-2">
          {tech.map((t) => (
            <span
              key={t}
              className="rounded-md border border-neutral-200 bg-white px-3 py-1 text-[11px] font-medium uppercase tracking-wider text-neutral-500"
            >
              {t}
            </span>
          ))}
        </motion.div>
      </div>
    </MotionSection>
  );
}
