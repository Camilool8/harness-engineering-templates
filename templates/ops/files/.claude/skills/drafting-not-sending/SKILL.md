---
name: drafting-not-sending
description: Produce customer-facing messages as drafts for human review — use whenever composing any reply, email, or CRM note that a customer would see.
---

# Drafting, not sending

The agent is a **drafter**, never a **publisher**. Customer-facing
communication is irreversible once sent — a wrong reply cannot be unsent. So
every customer-facing message goes to a draft surface, and a human (or a
separate privileged publisher) does the actual sending.

## The pattern

- **Drafter (this agent).** Triage the ticket, gather context, and write the
  reply — but write it to a *draft* surface only: a Linear comment, a helpdesk
  draft, a Slack message in a review channel. Never call a "send" / "reply to
  customer" action directly.
- **Publisher (human or separate privileged agent).** Reviews the draft, edits
  if needed, and sends. The publisher holds the send credential; the drafter
  does not.

## Rules

- When you finish a reply, say explicitly: "Draft ready for review" and point
  to where the draft lives. Do not imply it was sent.
- If a tool would send a message directly to a customer, stop — route it to a
  draft surface instead, or escalate.
- The same drafter/publisher split applies to irreversible CRM mutations
  (refunds over threshold, account merges, subscription changes): the agent
  prepares and proposes; a human approves and executes.
- This split is what makes autonomy safe here — keep it intact, do not
  collapse drafting and sending into one step.
