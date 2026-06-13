import { motion } from 'framer-motion';

const ease = [0.22, 1, 0.36, 1];

export const fadeUp = {
  hidden: { opacity: 0, y: 16 },
  visible: (i = 0) => ({
    opacity: 1,
    y: 0,
    transition: { delay: i * 0.06, duration: 0.55, ease },
  }),
};

export const fadeIn = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { duration: 0.6, ease } },
};

export const stagger = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.06, delayChildren: 0.05 } },
};

export function SectionLabel({ children, className = '' }) {
  return <p className={`label-caps ${className}`}>{children}</p>;
}

export function MotionSection({ id, children, className = '' }) {
  return (
    <motion.section
      id={id}
      className={className}
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: '-80px' }}
      variants={stagger}
    >
      {children}
    </motion.section>
  );
}

export function GridBackdrop({ dense = false, className = '' }) {
  return (
    <div
      aria-hidden
      className={`pointer-events-none absolute inset-0 grid-fade ${dense ? 'grid-lines-dense' : 'grid-lines'} ${className}`}
    />
  );
}

export function SectionDivider() {
  return <div className="section-divider mx-auto max-w-6xl" />;
}

export function IconBadge({ icon: Icon, className = '' }) {
  return (
    <div
      className={`flex h-10 w-10 items-center justify-center rounded-lg border border-neutral-200 bg-white text-dark ${className}`}
    >
      <Icon size={18} />
    </div>
  );
}
