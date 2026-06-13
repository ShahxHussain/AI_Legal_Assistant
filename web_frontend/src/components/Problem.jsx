import { motion } from 'framer-motion';
import { RiFileTextLine, RiTranslate2, RiWallet3Line, RiDoubleQuotesL } from 'react-icons/ri';
import { fadeUp, MotionSection, SectionLabel, stagger, GridBackdrop } from '../utils/motion';
import { FOUNDER } from '../config/site';

const cards = [
  {
    icon: RiFileTextLine,
    title: 'Dense legal language',
    text: 'PPC, CrPC, ATA — hundreds of sections written for lawyers, not citizens.',
  },
  {
    icon: RiTranslate2,
    title: 'Language barrier',
    text: 'Most citizens speak Urdu, Pashto, or Sindhi. The law is indexed in English.',
  },
  {
    icon: RiWallet3Line,
    title: 'No affordable help',
    text: 'Legal advice is expensive. The need for it can arrive without warning.',
  },
];

export default function Problem() {
  return (
    <MotionSection id="problem" className="relative border-t border-neutral-200/80 py-24 md:py-32">
      <GridBackdrop dense />
      <div className="relative mx-auto max-w-6xl px-5 md:px-8">
        <motion.div variants={fadeUp} className="max-w-2xl">
          <SectionLabel>Why this exists</SectionLabel>
          <h2 className="mt-4 font-display text-3xl font-semibold tracking-[-0.02em] text-dark md:text-4xl">
            The law is written.
            <br />
            But not for everyone.
          </h2>
          <p className="mt-5 text-[15px] leading-relaxed text-neutral-500">
            For most citizens in Pakistan, the legal system is inaccessible — not because
            laws don&apos;t exist, but because understanding them requires money,
            connections, or a law degree.
          </p>
        </motion.div>

        <motion.div variants={stagger} className="mt-14 grid gap-4 md:grid-cols-3">
          {cards.map((c, i) => (
            <motion.article
              key={c.title}
              custom={i}
              variants={fadeUp}
              className="card-premium p-6"
            >
              <c.icon className="text-xl text-neutral-700" />
              <h3 className="mt-5 text-[15px] font-semibold tracking-tight text-dark">
                {c.title}
              </h3>
              <p className="mt-2 text-sm leading-relaxed text-neutral-500">{c.text}</p>
            </motion.article>
          ))}
        </motion.div>

        <motion.blockquote
          variants={fadeUp}
          className="card-premium mt-10 flex gap-4 p-6 md:p-8"
        >
          <RiDoubleQuotesL className="shrink-0 text-2xl text-neutral-300" />
          <div>
            <p className="text-[15px] leading-relaxed text-neutral-700">
              I was stopped and cited legal sections I didn&apos;t understand. I had no idea
              what my rights were in that moment.
            </p>
            <footer className="mt-3 text-[13px] font-medium text-neutral-400">
              — {FOUNDER.name}, Court Companion
            </footer>
          </div>
        </motion.blockquote>
      </div>
    </MotionSection>
  );
}
