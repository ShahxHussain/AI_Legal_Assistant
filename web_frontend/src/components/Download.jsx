import { motion } from 'framer-motion';
import { RiDownloadLine, RiChromeLine, RiInformationLine, RiExternalLinkLine } from 'react-icons/ri';
import { SITE } from '../config/site';
import { fadeUp, MotionSection, GridBackdrop } from '../utils/motion';

export default function Download() {
  return (
    <MotionSection id="download" className="relative border-t border-neutral-200/80 py-24 md:py-32">
      <GridBackdrop dense />
      <div className="relative mx-auto max-w-2xl px-5 text-center md:px-8">
        <motion.h2
          variants={fadeUp}
          className="font-display text-3xl font-semibold tracking-[-0.02em] text-dark md:text-4xl"
        >
          Download Court Companion
        </motion.h2>
        <motion.p variants={fadeUp} className="mt-4 text-[15px] text-neutral-500">
          Free. No login. Android 7+. Powered by Meta Llama on Together.ai.
        </motion.p>
        <motion.div variants={fadeUp} className="mt-8 flex flex-col items-center gap-3 sm:flex-row sm:justify-center">
          <a
            href={SITE.apkUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="btn-green px-10 py-3.5 text-[15px]"
          >
            <RiDownloadLine size={18} />
            Download APK
          </a>
          <a
            href={SITE.apkViewUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="btn-secondary px-6 py-3.5 text-[14px]"
          >
            View on Drive
            <RiExternalLinkLine size={14} />
          </a>
        </motion.div>
        <motion.p
          variants={fadeUp}
          className="mt-4 flex items-center justify-center gap-2 text-[13px] text-neutral-400"
        >
          <RiChromeLine size={14} />
          Web app also runs in Chrome — no install needed
        </motion.p>
        <motion.div
          variants={fadeUp}
          className="mt-10 flex gap-3 rounded-xl border border-primary/15 bg-primary-pale/40 p-5 text-left"
        >
          <RiInformationLine className="mt-0.5 shrink-0 text-primary" size={18} />
          <p className="text-[13px] leading-relaxed text-neutral-600">
            Court Companion provides legal information only. It does not replace a
            qualified lawyer. Consult a licensed professional for your specific situation.
          </p>
        </motion.div>
      </div>
      <div className="accent-bar mx-auto mt-16 max-w-6xl" />
    </MotionSection>
  );
}
