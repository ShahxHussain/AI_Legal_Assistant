import { motion } from 'framer-motion';
import {
  RiChat3Line,
  RiMicLine,
  RiGlobalLine,
  RiFileSearchLine,
  RiUploadLine,
  RiPulseLine,
} from 'react-icons/ri';
import { fadeUp, MotionSection, SectionLabel, stagger } from '../utils/motion';

const items = [
  { icon: RiChat3Line, title: 'Streaming chat', text: 'Answers appear token by token. No waiting for the full response.' },
  { icon: RiMicLine, title: 'Voice I/O', text: 'Speak your question. Hear the answer phrase by phrase as it streams.' },
  { icon: RiGlobalLine, title: '7 languages', text: 'Urdu, Roman Urdu, Pashto, Punjabi, Sindhi, Balochi, English.' },
  { icon: RiFileSearchLine, title: 'Source citations', text: 'Transparent statute references on every answer.' },
  { icon: RiUploadLine, title: 'Document upload', text: 'Upload PDF or TXT and ask questions about it directly.' },
  { icon: RiPulseLine, title: 'API status', text: 'Live online/offline indicator for the backend.' },
];

export default function Features() {
  return (
    <MotionSection id="features" className="border-t border-neutral-200/80 bg-white py-24 md:py-32">
      <div className="mx-auto max-w-6xl px-5 md:px-8">
        <motion.div variants={fadeUp} className="max-w-lg">
          <SectionLabel>Features</SectionLabel>
          <h2 className="mt-4 font-display text-3xl font-semibold tracking-[-0.02em] text-dark md:text-4xl">
            Know your rights
          </h2>
        </motion.div>

        <motion.div
          variants={stagger}
          className="mt-14 grid gap-4 sm:grid-cols-2 lg:grid-cols-3"
        >
          {items.map((f, i) => (
            <motion.article
              key={f.title}
              custom={i}
              variants={fadeUp}
              whileHover={{ y: -2 }}
              transition={{ duration: 0.2 }}
              className="card-premium group p-6"
            >
              <f.icon className="text-lg text-neutral-400 transition group-hover:text-dark" />
              <h3 className="mt-5 text-[14px] font-semibold text-dark">{f.title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-neutral-500">{f.text}</p>
            </motion.article>
          ))}
        </motion.div>
      </div>
    </MotionSection>
  );
}
