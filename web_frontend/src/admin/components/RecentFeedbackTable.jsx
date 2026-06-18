import { RiThumbDownLine, RiThumbUpLine } from 'react-icons/ri';

function formatTime(value) {
  if (!value) return '—';
  try {
    return new Date(value).toLocaleString(undefined, {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  } catch (_) {
    return value;
  }
}

function RatingBadge({ rating }) {
  const helpful = rating === 'up';
  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-[11px] font-semibold ${
        helpful
          ? 'bg-primary-pale text-primary'
          : 'bg-red-50 text-red-600'
      }`}
    >
      {helpful ? <RiThumbUpLine size={12} /> : <RiThumbDownLine size={12} />}
      {helpful ? 'Helpful' : 'Not helpful'}
    </span>
  );
}

function FeedbackCard({ row }) {
  return (
    <article className="rounded-xl border border-neutral-200/80 bg-neutral-50/50 p-4 transition hover:border-primary/15 hover:bg-white">
      <div className="flex items-start justify-between gap-2">
        <time className="text-xs text-neutral-500">{formatTime(row.created_at)}</time>
        <RatingBadge rating={row.rating} />
      </div>
      <div className="mt-3 flex flex-wrap gap-2">
        <span className="rounded-lg border border-neutral-200 bg-white px-2.5 py-1 text-[11px] font-medium text-neutral-600">
          {row.language || '—'}
        </span>
        <span className="rounded-lg border border-neutral-200 bg-white px-2.5 py-1 text-[11px] font-medium text-neutral-600">
          {row.channel || 'chat'}
        </span>
      </div>
      {row.comment ? (
        <p className="mt-3 text-sm leading-relaxed text-neutral-600">{row.comment}</p>
      ) : null}
    </article>
  );
}

export default function RecentFeedbackTable({ rows, limit = 12 }) {
  const visible = rows.slice(0, limit);

  return (
    <div className="admin-card p-5 sm:p-6">
      <div className="flex flex-col gap-1 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="label-caps">Citizen voice</p>
          <h3 className="mt-2 font-display text-lg font-semibold text-dark">
            Recent feedback
          </h3>
        </div>
        {rows.length > 0 ? (
          <p className="text-[12px] text-neutral-500">
            Showing {visible.length} of {rows.length}
          </p>
        ) : null}
      </div>

      {rows.length === 0 ? (
        <p className="mt-6 rounded-xl border border-dashed border-neutral-200 bg-neutral-50/80 px-4 py-10 text-center text-sm text-neutral-500">
          No feedback submitted yet.
        </p>
      ) : (
        <>
          <div className="mt-5 space-y-3 lg:hidden">
            {visible.map((row) => (
              <FeedbackCard key={row.id} row={row} />
            ))}
          </div>

          <div className="mt-5 hidden overflow-x-auto lg:block">
            <table className="min-w-full text-left text-sm">
              <thead>
                <tr className="border-b border-neutral-200 text-[11px] uppercase tracking-wider text-neutral-500">
                  <th className="px-3 py-2.5 font-semibold">Time</th>
                  <th className="px-3 py-2.5 font-semibold">Rating</th>
                  <th className="px-3 py-2.5 font-semibold">Language</th>
                  <th className="px-3 py-2.5 font-semibold">Channel</th>
                  <th className="px-3 py-2.5 font-semibold">Comment</th>
                </tr>
              </thead>
              <tbody>
                {visible.map((row) => (
                  <tr
                    key={row.id}
                    className="border-b border-neutral-100 transition hover:bg-primary-pale/20"
                  >
                    <td className="whitespace-nowrap px-3 py-3 text-neutral-500">
                      {formatTime(row.created_at)}
                    </td>
                    <td className="px-3 py-3">
                      <RatingBadge rating={row.rating} />
                    </td>
                    <td className="px-3 py-3 text-dark">{row.language || '—'}</td>
                    <td className="px-3 py-3 text-dark">{row.channel || 'chat'}</td>
                    <td className="max-w-md truncate px-3 py-3 text-neutral-500">
                      {row.comment || '—'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}
