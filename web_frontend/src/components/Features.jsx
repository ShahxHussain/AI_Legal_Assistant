import { motion } from 'framer-motion';
import {
  RiChat3Line,
  RiMicLine,
  RiGlobalLine,
  RiFileSearchLine,
  RiUploadLine,
  RiPulseLine,
  RiHistoryLine,
  RiThumbUpLine,
  RiDashboardLine,
  RiVipCrownLine,
} from 'react-icons/ri';
import { fadeUp, MotionSection, SectionLabel, stagger } from '../utils/motion';
import { SITE } from '../config/site';

const items = [
  {
    icon: RiChat3Line,
    title: 'Streaming chat',
    text: 'Answers appear token by token. Follow-ups in the same session via conversation memory.',
  },
  {
    icon: RiHistoryLine,
    title: 'Chat history',
    text: 'Sidebar lists past conversations — reopen any thread without losing context.',
  },
  {
    icon: RiMicLine,
    title: 'Voice I/O',
    text: 'Speak your question and hear answers stream back — English and Urdu voice today.',
  },
  {
    icon: RiGlobalLine,
    title: '7 text languages',
    text: 'Urdu, Roman Urdu, Pashto, Punjabi, Sindhi, Balochi, English.',
  },
  {
    icon: RiFileSearchLine,
    title: 'Source citations',
    text: 'Transparent PPC, CrPC, and ATA references on every answer.',
  },
  {
    icon: RiUploadLine,
    title: 'Document attach',
    text: 'Clip icon in chat — upload PDF or TXT and ask about it in the same thread.',
  },
  {
    icon: RiThumbUpLine,
    title: 'Answer feedback',
    text: 'Thumbs up / down on responses to improve retrieval and prompts over time.',
  },
  {
    icon: RiPulseLine,
    title: 'API status',
    text: 'Live online/offline indicator for the Render backend.',
  },
  {
    icon: RiDashboardLine,
    title: 'Admin dashboard',
    text: 'Organizer analytics at /admin — usage, languages, and feedback KPIs.',
  },
  {
    icon: RiVipCrownLine,
    title: 'Court Companion Pro',
    text: 'Beta info screen for lawyers — agentic follow-ups & case workspace coming.',
    highlight: true,
  },
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
          <p className="mt-4 text-[15px] text-neutral-500">
            Everything below is live in the{' '}
            <a
              href={SITE.webAppUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="font-medium text-primary hover:underline"
            >
              web app
            </a>{' '}
            and Android APK.
          </p>
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
              className={`card-premium group p-6 ${
                f.highlight ? 'border-amber-200/80 bg-amber-50/30' : ''
              }`}
            >
              <f.icon
                className={`text-lg transition group-hover:text-dark ${
                  f.highlight ? 'text-amber-700' : 'text-neutral-400'
                }`}
              />
              <h3 className="mt-5 text-[14px] font-semibold text-dark">{f.title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-neutral-500">{f.text}</p>
            </motion.article>
          ))}
        </motion.div>
      </div>
    </MotionSection>
  );
}
