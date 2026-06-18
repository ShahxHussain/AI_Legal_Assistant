import {
  RiUserLine,
  RiChat3Line,
  RiQuestionAnswerLine,
  RiThumbUpLine,
} from 'react-icons/ri';

const ICONS = {
  users: RiUserLine,
  sessions: RiChat3Line,
  questions: RiQuestionAnswerLine,
  helpful: RiThumbUpLine,
};

export default function KpiCard({ label, value, hint, icon = 'users', accent }) {
  const Icon = ICONS[icon] || RiUserLine;

  return (
    <article className="admin-card group relative overflow-hidden p-5 transition duration-300 hover:border-primary/20 hover:shadow-[0_12px_40px_rgba(13,92,46,0.08)]">
      <div
        className="pointer-events-none absolute -right-6 -top-6 h-24 w-24 rounded-full opacity-[0.07] transition group-hover:opacity-[0.12]"
        style={{ background: accent || 'var(--color-primary)' }}
      />
      <div className="relative flex items-start justify-between gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl border border-primary/15 bg-primary-pale/70">
          <Icon className="text-lg text-primary" />
        </div>
      </div>
      <p className="label-caps relative mt-4">{label}</p>
      <p className="relative mt-2 font-display text-3xl font-bold tracking-tight text-dark">
        {value}
      </p>
      {hint ? (
        <p className="relative mt-2 text-[12px] leading-relaxed text-neutral-500">{hint}</p>
      ) : null}
    </article>
  );
}
