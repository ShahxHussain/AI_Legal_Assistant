import { motion } from 'framer-motion';
import { RiCheckLine, RiDownloadLine } from 'react-icons/ri';
import { SITE } from '../config/site';
import { fadeUp, MotionSection, SectionLabel, stagger } from '../utils/motion';

const built = [
  { title: 'Streaming text chat', detail: 'Token-by-token answers with live source chips.' },
  { title: 'Seven text languages', detail: 'Urdu, Roman Urdu, Pashto, Punjabi, Sindhi, Balochi, English.' },
  { title: 'Voice I/O', detail: 'Speak questions; hear answers stream back (English voice today).' },
  { title: 'Document upload', detail: 'PDF & TXT analysis with optional statute cross-reference.' },
  { title: 'RAG pipeline', detail: '983 indexed PPC, CrPC, and ATA chunks via FAISS.' },
  { title: 'Android APK + Web', detail: 'Release APK on Render; Chrome web client.' },
  { title: 'Source citations', detail: 'Every answer links to the statute section retrieved.' },
  { title: 'API status badge', detail: 'Live online/offline indicator in the app.' },
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
            Everything below is live in the APK and web app — not mockups.
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
            Try the build now — then scroll to see what&apos;s coming next.
          </p>
          <a
            href={SITE.apkUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="btn-green mt-6 px-8 py-3"
          >
            <RiDownloadLine size={16} />
            Download APK
          </a>
        </motion.div>
      </div>
    </MotionSection>
  );
}
