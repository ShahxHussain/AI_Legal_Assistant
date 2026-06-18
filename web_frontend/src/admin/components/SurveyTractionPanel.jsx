import { RiSurveyLine, RiExternalLinkLine, RiLightbulbLine } from 'react-icons/ri';
import {
  SURVEY_FORM,
  SURVEY_HIGHLIGHTS,
  SURVEY_SECTIONS,
} from '../data/surveyTraction';

function SurveyBars({ section }) {
  const max = Math.max(...section.options.map((o) => o.count), 1);

  return (
    <article className="admin-card p-5 sm:p-6">
      <p className="text-[13px] font-medium leading-snug text-dark">{section.question}</p>
      {section.note ? (
        <p className="mt-1 text-[11px] text-neutral-400">{section.note}</p>
      ) : null}
      <div className="mt-4 space-y-3">
        {section.options.map((opt) => (
          <div key={opt.label}>
            <div className="mb-1 flex justify-between gap-2 text-[12px]">
              <span className="min-w-0 truncate text-neutral-700">{opt.label}</span>
              <span className="shrink-0 tabular-nums text-neutral-500">
                {opt.count}
                <span className="ml-1 text-neutral-400">({opt.pct}%)</span>
              </span>
            </div>
            <div className="h-2 overflow-hidden rounded-full bg-amber-50">
              <div
                className="h-full rounded-full bg-gradient-to-r from-amber-500 to-amber-600 transition-all duration-500"
                style={{ width: `${(opt.count / max) * 100}%` }}
              />
            </div>
          </div>
        ))}
      </div>
    </article>
  );
}

export default function SurveyTractionPanel({ embedded = false }) {
  return (
    <section className="space-y-6">
      {!embedded ? (
        <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <span className="inline-flex items-center gap-2 rounded-full border border-amber-300/50 bg-amber-50 px-3 py-1">
              <RiSurveyLine className="text-amber-700" size={14} />
              <span className="text-[11px] font-bold uppercase tracking-wider text-amber-800">
                Market traction
              </span>
            </span>
            <h3 className="mt-4 font-display text-xl font-semibold tracking-tight text-dark sm:text-2xl">
              Pre-launch survey validation
            </h3>
            <p className="mt-2 max-w-2xl text-[14px] text-neutral-500">
              Anonymous Google Form — validates problem, language need, mobile access, and
              trust requirements before / alongside live app usage.
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <div className="rounded-xl border border-amber-200/80 bg-amber-50/60 px-4 py-3 text-center">
              <p className="font-display text-3xl font-bold text-amber-800">
                {SURVEY_FORM.responseCount}
              </p>
              <p className="text-[11px] font-semibold uppercase tracking-wider text-amber-700/80">
                Responses
              </p>
            </div>
            <a
              href={SURVEY_FORM.viewUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="btn-secondary border-amber-200/80 !py-2.5 hover:bg-amber-50"
            >
              Open survey
              <RiExternalLinkLine size={14} />
            </a>
          </div>
        </div>
      ) : (
        <div className="flex flex-wrap items-center justify-end gap-3">
          <div className="rounded-xl border border-amber-200/80 bg-amber-50/60 px-4 py-2.5 text-center">
            <p className="font-display text-2xl font-bold text-amber-800">
              {SURVEY_FORM.responseCount}
            </p>
            <p className="text-[10px] font-semibold uppercase tracking-wider text-amber-700/80">
              Responses
            </p>
          </div>
          <a
            href={SURVEY_FORM.viewUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="btn-secondary border-amber-200/80 !py-2.5 hover:bg-amber-50"
          >
            Open survey
            <RiExternalLinkLine size={14} />
          </a>
        </div>
      )}

      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        {SURVEY_HIGHLIGHTS.map((h) => (
          <div
            key={h.label}
            className="admin-card border-amber-200/40 bg-gradient-to-br from-amber-50/40 to-white p-4 sm:p-5"
          >
            <p className="label-caps !text-amber-800/70">{h.label}</p>
            <p className="mt-2 font-display text-2xl font-bold text-amber-900">{h.value}</p>
            <p className="mt-2 text-[11px] leading-relaxed text-neutral-500">{h.hint}</p>
          </div>
        ))}
      </div>

      <div className="admin-card flex gap-3 border-primary/15 bg-primary-pale/30 p-4 sm:p-5">
        <RiLightbulbLine className="mt-0.5 shrink-0 text-lg text-primary" />
        <p className="text-[13px] leading-relaxed text-neutral-600">
          <strong className="text-dark">Why this matters for judges:</strong> Survey demand
          (86% confusion, 100% mobile, 86% need citations) aligns with what Court Companion
          ships — RAG source chips, 7 languages, web + APK. The Live impact tab shows
          real app usage; this page shows validated demand before scale.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        {SURVEY_SECTIONS.map((section) => (
          <SurveyBars key={section.id} section={section} />
        ))}
      </div>

      <p className="text-center text-[11px] text-neutral-400">
        Source: Google Form · {SURVEY_FORM.responseCount} responses · Updated{' '}
        {SURVEY_FORM.updatedAt} · Edit counts in{' '}
        <code className="rounded bg-neutral-100 px-1.5 py-0.5 text-[10px]">
          web_frontend/src/admin/data/surveyTraction.js
        </code>
      </p>
    </section>
  );
}
