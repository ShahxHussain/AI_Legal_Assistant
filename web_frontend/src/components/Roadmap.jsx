import { motion } from 'framer-motion';
import { RiCheckLine, RiArrowRightLine } from 'react-icons/ri';
import { SITE } from '../config/site';
import { fadeUp, MotionSection, SectionLabel, stagger } from '../utils/motion';

const built = [
  { title: 'Flutter web on Vercel', detail: 'Full app at ai-legal-assistant-two.vercel.app — no install.' },
  { title: 'Streaming text chat', detail: 'Token-by-token answers with live source chips.' },
  { title: 'Chat history sidebar', detail: 'Reopen past conversations; follow-ups keep session context.' },
  { title: 'Seven text languages', detail: 'Urdu, Roman Urdu, Pashto, Punjabi, Sindhi, Balochi, English.' },
  { title: 'Voice I/O (EN + UR)', detail: 'Speak and hear answers in English and Urdu; more langs planned.' },
  { title: 'Document attach in chat', detail: 'PDF & TXT via clip icon — optional statute cross-reference.' },
  { title: 'Answer feedback', detail: 'Thumbs up / down per response for quality improvement.' },
  { title: 'RAG pipeline', detail: '983 indexed PPC, CrPC, and ATA chunks via FAISS.' },
  { title: 'Android APK', detail: 'Release build on Google Drive; same Render API as web.' },
  { title: 'Source citations', detail: 'Every answer links to the statute section retrieved.' },
  { title: 'Admin dashboard', detail: 'React /admin — usage KPIs, charts, recent feedback.' },
  { title: 'Court Companion Pro (beta)', detail: 'Lawyer product vision in-app; full workspace shipping next.' },
];

export default function Roadmap() {
  return (
    <MotionSection id="roadmap" className="relative border-t border-neutral-200/80 bg-white py-24 md:py-32">
      <div className="mx-auto max-w-6xl px-5 md:px-8">
        <motion.div variants={fadeUp} className="max-w-2xl">
          <SectionLabel>Shipped today</SectionLabel>
          <h2 className="mt-4 font-display text-3xl font-semibold tracking-[-0.02em] text-dark md:text-4xl">
            Working prototype
          </h2>
          <p className="mt-4 text-[15px] leading-relaxed text-neutral-500">
            Everything below is live in the web app and APK — not mockups.
          </p>
        </motion.div>

        <motion.div
          variants={stagger}
          className="mt-12 grid gap-3 sm:grid-cols-2 lg:grid-cols-4"
        >
          {built.map((item, i) => (
            <motion.div
              key={item.title}
              custom={i}
              variants={fadeUp}
              className="rounded-xl border border-primary/10 bg-primary-pale/30 p-4"
            >
              <div className="flex items-start gap-2">
                <RiCheckLine className="mt-0.5 shrink-0 text-primary" size={16} />
                <div>
                  <p className="text-[13px] font-semibold text-dark">{item.title}</p>
                  <p className="mt-1 text-[12px] leading-relaxed text-neutral-500">
                    {item.detail}
                  </p>
                </div>
              </div>
            </motion.div>
          ))}
        </motion.div>

        <motion.div
          variants={fadeUp}
          className="mt-12 flex flex-col items-center rounded-xl border border-neutral-200 bg-neutral-50 px-6 py-10 text-center"
        >
          <p className="max-w-md text-[15px] text-neutral-600">
            Open the live web app now — then scroll for Court Companion Pro and what&apos;s
            coming next.
          </p>
          <div className="mt-6 flex flex-wrap justify-center gap-3">
            <a
              href={SITE.webAppUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="btn-green px-8 py-3"
            >
              Open web app
              <RiArrowRightLine size={16} />
            </a>
            <a href="#pro" className="btn-pro-outline px-6 py-3">
              Court Companion Pro
            </a>
          </div>
        </motion.div>
      </div>
    </MotionSection>
  );
}
