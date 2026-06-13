import { motion } from 'framer-motion';
import {
  RiCpuLine,
  RiCloudLine,
  RiDatabase2Line,
  RiExternalLinkLine,
} from 'react-icons/ri';
import { MODELS, SITE } from '../config/site';
import { fadeUp, MotionSection, SectionLabel, stagger } from '../utils/motion';

const stack = [
  { icon: RiCpuLine, label: 'Meta Llama', sub: '70B + 8B via Together.ai' },
  { icon: RiDatabase2Line, label: 'FAISS RAG', sub: '983 statute chunks' },
  { icon: RiCloudLine, label: 'Render', sub: 'Live HTTPS API' },
];

export default function Models() {
  return (
    <MotionSection id="models" className="border-t border-neutral-200/80 bg-white py-20 md:py-28">
      <div className="mx-auto max-w-6xl px-5 md:px-8">
        <motion.div variants={fadeUp} className="max-w-2xl">
          <SectionLabel>AI stack</SectionLabel>
          <h2 className="mt-4 font-display text-3xl font-semibold tracking-[-0.02em] text-dark md:text-4xl">
            Llama on Together.ai — not generic guesses
          </h2>
          <p className="mt-4 text-[15px] leading-relaxed text-neutral-500">
            Answers are generated only after FAISS retrieves real PPC, CrPC, and ATA text.
            Meta Llama models run through the{' '}
            <a
              href="https://www.together.ai/"
              target="_blank"
              rel="noopener noreferrer"
              className="font-medium text-primary underline-offset-2 hover:underline"
            >
              Together.ai API
            </a>
            — with a smaller Llama 8B for fast translation before search.
          </p>
        </motion.div>

        <motion.div variants={stagger} className="mt-12 grid gap-4 md:grid-cols-3">
          {stack.map((s, i) => (
            <motion.div
              key={s.label}
              custom={i}
              variants={fadeUp}
              className="card-premium border-primary/10 p-5"
            >
              <s.icon className="text-xl text-primary" />
              <p className="mt-4 text-[14px] font-semibold text-dark">{s.label}</p>
              <p className="mt-1 text-sm text-neutral-500">{s.sub}</p>
            </motion.div>
          ))}
        </motion.div>

        <motion.div variants={stagger} className="mt-6 space-y-3">
          {MODELS.map((m, i) => (
            <motion.div
              key={m.name}
              custom={i}
              variants={fadeUp}
              className="flex flex-col gap-1 rounded-xl border border-neutral-200 bg-neutral-50/50 px-5 py-4 sm:flex-row sm:items-center sm:justify-between"
            >
              <div>
                <p className="text-[14px] font-semibold text-dark">{m.name}</p>
                <p className="text-sm text-neutral-500">{m.role}</p>
              </div>
              <span className="text-[11px] font-semibold uppercase tracking-wider text-primary">
                {m.provider}
              </span>
            </motion.div>
          ))}
        </motion.div>

        <motion.a
          variants={fadeUp}
          href={SITE.healthUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="mt-8 inline-flex items-center gap-2 text-[13px] font-medium text-neutral-500 transition hover:text-primary"
        >
          Check live API status
          <RiExternalLinkLine size={14} />
        </motion.a>
      </div>
    </MotionSection>
  );
}
