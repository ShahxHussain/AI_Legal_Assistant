import { motion } from 'framer-motion';
import {
  RiCheckLine,
  RiDatabase2Line,
  RiGlobalLine,
  RiMicLine,
  RiDeviceLine,
  RiFileSearchLine,
} from 'react-icons/ri';
import { fadeUp, MotionSection, SectionLabel, stagger } from '../utils/motion';

const features = [
  { icon: RiDatabase2Line, title: 'Grounded in real law', text: '983 indexed PPC, CrPC, and ATA chunks. Not hallucinated.' },
  { icon: RiGlobalLine, title: 'Seven languages', text: 'English, Urdu, Roman Urdu, Pashto, Punjabi, Sindhi, Balochi.' },
  { icon: RiMicLine, title: 'Text + voice', text: 'Type or speak. Hear answers read back as they stream.' },
  { icon: RiDeviceLine, title: 'Android + web', text: 'Works on any Android phone and in Chrome. No login.' },
  { icon: RiFileSearchLine, title: 'Source citations', text: 'Every answer shows which statute section it came from.' },
];

const pills = [
  { tag: 'Urdu', text: 'ضمانت کیسے ملتی ہے؟', rtl: true },
  { tag: 'Roman Urdu', text: 'Chori ki saza kya hai?', rtl: false },
  { tag: 'Pashto', text: 'د FIR ثبتول څنګه کیږي؟', rtl: true },
  { tag: 'English', text: 'What is PPC Section 302?', rtl: false },
];

export default function Solution() {
  return (
    <MotionSection id="solution" className="border-t border-neutral-200/80 bg-white py-24 md:py-32">
      <div className="mx-auto max-w-6xl px-5 md:px-8">
        <motion.div variants={fadeUp} className="max-w-xl">
          <SectionLabel>The solution</SectionLabel>
          <h2 className="mt-4 font-display text-3xl font-semibold tracking-[-0.02em] text-dark md:text-4xl">
            Meet Court Companion
          </h2>
          <p className="mt-4 text-[15px] text-neutral-500">
            Ask a legal question. Get a real answer. In your language.
          </p>
        </motion.div>

        <div className="mt-14 grid gap-12 lg:grid-cols-2 lg:items-start">
          <motion.ul variants={stagger} className="space-y-5">
            {features.map((f, i) => (
              <motion.li
                key={f.title}
                custom={i}
                variants={fadeUp}
                className="flex gap-4 border-b border-neutral-100 pb-5 last:border-0"
              >
                <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg border border-neutral-200 bg-neutral-50">
                  <f.icon size={16} className="text-neutral-600" />
                </span>
                <div>
                  <p className="text-[14px] font-semibold text-dark">{f.title}</p>
                  <p className="mt-1 text-sm text-neutral-500">{f.text}</p>
                </div>
              </motion.li>
            ))}
          </motion.ul>

          <motion.div variants={fadeUp} className="card-premium p-6 md:p-8">
            <p className="label-caps">Multilingual</p>
            <h3 className="mt-2 font-display text-xl font-semibold tracking-tight">
              Ask in any language
            </h3>
            <div className="mt-6 space-y-2">
              {pills.map((p) => (
                <div
                  key={p.tag}
                  className="flex items-start gap-3 rounded-lg border border-neutral-100 bg-neutral-50/80 px-4 py-3"
                >
                  <span className="mt-0.5 shrink-0 rounded-md bg-white px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-neutral-500 ring-1 ring-neutral-200">
                    {p.tag}
                  </span>
                  <p className={`text-sm text-neutral-700 ${p.rtl ? 'font-urdu flex-1' : ''}`}>
                    {p.text}
                  </p>
                </div>
              ))}
            </div>
            <p className="mt-5 flex items-center gap-2 text-[13px] font-medium text-neutral-500">
              <RiCheckLine className="text-primary" />
              Answered in the user&apos;s chosen language
            </p>
          </motion.div>
        </div>
      </div>
    </MotionSection>
  );
}
