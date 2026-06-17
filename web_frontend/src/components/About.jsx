import { motion } from 'framer-motion';
import {
  RiUserStarLine,
  RiGithubLine,
  RiExternalLinkLine,
  RiCheckLine,
} from 'react-icons/ri';
import { FOUNDER, SITE } from '../config/site';
import { fadeUp, MotionSection, SectionLabel, stagger, GridBackdrop } from '../utils/motion';

export default function About() {
  return (
    <MotionSection id="about" className="relative border-t border-neutral-200/80 py-24 md:py-32">
      <GridBackdrop dense />
      <div className="relative mx-auto max-w-6xl px-5 md:px-8">
        <div className="grid gap-12 lg:grid-cols-[1fr_1.1fr] lg:items-center">
          <motion.div variants={fadeUp}>
            <SectionLabel>About the builder</SectionLabel>
            <h2 className="mt-4 font-display text-3xl font-semibold tracking-[-0.02em] text-dark md:text-4xl">
              {FOUNDER.name}
            </h2>
            <p className="mt-2 text-[13px] font-medium text-primary">{FOUNDER.role}</p>
            <p className="mt-6 text-[15px] leading-relaxed text-neutral-600">
              {FOUNDER.bio}
            </p>
            <ul className="mt-8 space-y-3">
              {FOUNDER.highlights.map((h) => (
                <li key={h} className="flex gap-3 text-sm text-neutral-500">
                  <RiCheckLine className="mt-0.5 shrink-0 text-primary" size={16} />
                  {h}
                </li>
              ))}
            </ul>
            <div className="mt-8 flex flex-wrap gap-3">
              <a
                href={SITE.webAppUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="btn-green"
              >
                Open web app
              </a>
              <a
                href={SITE.githubUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="btn-secondary"
              >
                <RiGithubLine size={16} />
                GitHub repository
                <RiExternalLinkLine size={14} />
              </a>
            </div>
          </motion.div>

          <motion.div variants={stagger} className="space-y-4">
            <motion.div variants={fadeUp} className="card-premium border-primary/15 p-8">
              <div className="flex h-14 w-14 items-center justify-center rounded-xl border border-primary/20 bg-primary-pale">
                <RiUserStarLine className="text-2xl text-primary" />
              </div>
              <p className="mt-6 text-lg font-semibold leading-snug text-dark">
                &ldquo;Legal information should not require a law degree or an expensive
                lawyer just to understand your own rights.&rdquo;
              </p>
              <p className="mt-4 text-sm text-neutral-500">— {FOUNDER.name}</p>
            </motion.div>

            <motion.div variants={fadeUp} className="grid grid-cols-2 gap-4">
              {[
                { n: '983', l: 'Legal chunks indexed' },
                { n: '7', l: 'Response languages' },
                { n: '3', l: 'Statute codes' },
                { n: '1', l: 'Solo civic build' },
              ].map((stat) => (
                <div
                  key={stat.l}
                  className="rounded-xl border border-neutral-200 bg-white p-5"
                >
                  <p className="font-display text-2xl font-semibold text-primary">
                    {stat.n}
                  </p>
                  <p className="mt-1 text-[12px] text-neutral-500">{stat.l}</p>
                </div>
              ))}
            </motion.div>
          </motion.div>
        </div>
      </div>
    </MotionSection>
  );
}
