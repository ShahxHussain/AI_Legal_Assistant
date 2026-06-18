import { motion } from 'framer-motion';
import SurveyTractionPanel from './components/SurveyTractionPanel';
import { SURVEY_FORM } from './data/surveyTraction';

export default function AdminTraction() {
  return (
    <main className="relative mx-auto max-w-7xl px-4 py-6 sm:px-6 sm:py-8">
      <motion.div
        initial={{ opacity: 0, y: 12 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.45 }}
        className="mb-8"
      >
        <span className="inline-flex items-center gap-2 rounded-full border border-amber-300/50 bg-amber-50 px-3 py-1">
          <span className="h-1.5 w-1.5 rounded-full bg-amber-600 shadow-[0_0_8px_rgba(217,119,6,0.5)]" />
          <span className="text-[11px] font-semibold uppercase tracking-wider text-amber-800">
            Pre-launch validation
          </span>
        </span>
        <h2 className="mt-4 font-display text-2xl font-semibold tracking-tight text-dark sm:text-3xl">
          Market traction survey
        </h2>
        <p className="mt-2 max-w-2xl text-[15px] text-neutral-500">
          {SURVEY_FORM.responseCount} anonymous responses from the Google Form — problem
          validation, language demand, mobile access, and trust signals before live app
          scale.
        </p>
      </motion.div>

      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.35, delay: 0.05 }}
      >
        <SurveyTractionPanel embedded />
      </motion.div>
    </main>
  );
}
