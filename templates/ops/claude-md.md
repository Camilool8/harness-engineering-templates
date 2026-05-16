## Customer support & ops rules

**The agent drafts, never sends.** Every customer-facing message goes to a
draft surface (Linear comment, helpdesk draft, Slack review channel). A human —
or a separate privileged publisher — does the actual sending. Never call a
"send" / "reply to customer" action directly. See the `drafting-not-sending`
skill.

**Human-in-the-loop for money and irreversible mutations.** Refunds and credits
at or above the threshold, and any irreversible CRM mutation (account merges,
subscription changes, deletions), require a human. The `refund-threshold-guard`
hook auto-allows small refunds and hard-blocks anything at or above the
threshold — when blocked, draft the action and escalate, do not retry.

**Triage classification is graded.** Ticket routing and category labels are
judgment calls; they are checked against the labelled golden eval set so
misroutes are caught before they reach a customer.

**The runbook is the spec.** Follow the documented support procedure for the
ticket type. Where the runbook does not cover a case, escalate rather than
improvise on a customer-facing or money-moving action.
