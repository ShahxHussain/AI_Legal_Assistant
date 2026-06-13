import { motion } from 'framer-motion';
import { RiUser3Line, RiFileWarningLine, RiQuestionLine } from 'react-icons/ri';
import { fadeUp, MotionSection, SectionLabel, stagger } from '../utils/motion';
import { useCountUp } from '../utils/useCountUp';

const stats = [
  { end: 983, label: 'Statute chunks' },
  { end: 7, label: 'Languages' },
  { end: 3, label: 'Laws covered' },
  { end: 2, label: 'Platforms' },
];

const personas = [
  { icon: RiUser3Line, title: 'Rural citizen', text: 'No lawyer. No English. Needs to know their rights.' },
  { icon: RiFileWarningLine, title: 'FIR filer', text: 'First time dealing with police. Confused and scared.' },
  { icon: RiQuestionLine, title: 'Ordinary person', text: 'Cited sections on the street. No idea what they mean.' },
];

function Stat({ end, label }) {
  const { ref, value } = useCountUp(end);
  return (
    <div ref={ref} className="border-l border-neutral-700 pl-6">
      <p className="font-display text-4xl font-semibold tabular-nums tracking-tight text-white md:text-5xl">
        {value}
      </p>
      <p className="mt-2 text-[12px] font-medium uppercase tracking-wider text-neutral-500">
        {label}
      </p>
    </div>
  );
}

export default function Impact() {
  return (
    <MotionSection id="impact" className="border-t border-neutral-800 bg-dark py-24 text-white md:py-32">
      <div className="mx-auto max-w-6xl px-5 md:px-8">
        <motion.div variants={fadeUp} className="max-w-xl">
          <SectionLabel className="!text-neutral-500">Civic impact</SectionLabel>
          <h2 className="mt-4 font-display text-3xl font-semibold tracking-[-0.02em] md:text-4xl">
            Built for people who need it most
          </h2>
          <p className="mt-4 text-[15px] leading-relaxed text-neutral-400">
            Not for lawyers. For the person who just got an FIR filed and
            doesn&apos;t know what that means.
          </p>
        </motion.div>

        <motion.div
          variants={stagger}
          className="mt-16 grid grid-cols-2 gap-10 md:grid-cols-4"
        >
          {stats.map((s, i) => (
            <motion.div key={s.label} custom={i} variants={fadeUp}>
              <Stat end={s.end} label={s.label} />
            </motion.div>
          ))}
        </motion.div>

        <motion.div variants={stagger} className="mt-16 grid gap-4 md:grid-cols-3">
          {personas.map((p, i) => (
            <motion.div
              key={p.title}
              custom={i}
              variants={fadeUp}
              className="rounded-xl border border-neutral-800 bg-neutral-900/50 p-5"
            >
              <p.icon className="text-lg text-neutral-500" />
              <h3 className="mt-4 text-[14px] font-semibold">{p.title}</h3>
              <p className="mt-1.5 text-sm text-neutral-400">{p.text}</p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </MotionSection>
  );
}
