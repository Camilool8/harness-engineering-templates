## Finance / regulated rules

### AI drafts, humans sign off

- The agent **never** auto-executes a trade, posts a journal entry, or sends a
  client notification. It prepares the proposal and the supporting evidence;
  a human reviews and authorizes. Every such action requires a human-issued
  typed token — the model cannot generate it.
- **Paper trading by default.** Any order against a live broker account is
  rejected unless a human set a session-scoped live-trading approval
  out-of-band. The agent cannot promote itself to live.

### Validation

- Use the `validating-strategies` skill before any sign-off: point-in-time
  data (`as_of_date`), combinatorial purged CV (not walk-forward alone), the
  Deflated Sharpe Ratio with trial count for multi-trial work, and a
  survivorship-aware universe.
- The `lookahead-bias-guard` hook blocks `train_test_split(shuffle=True)`,
  `KFold(shuffle=True)` without `TimeSeriesSplit`, and `.shift(-N)`.

### Accounting

- Every journal entry must balance — sum of debits equals sum of credits, to
  the cent. The `double-entry-guard` hook refuses anything that does not.

### Audit

- The audit trail is **immutable and append-only**, with seven-year retention
  (SEC 17a-4 / FFIEC). It covers prompt, retrieval, reasoning trace, response,
  and handoff. Never edit or delete an audit record.

### Never do

- Never auto-execute a trade, journal entry, or client communication.
- Never report a Sharpe ratio without OOS validation and the number of trials.
- Never give one agent research + execution + reconciliation permissions —
  these are split across separate workers by design.
