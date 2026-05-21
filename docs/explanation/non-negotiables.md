# The non-negotiable `_base` hooks

Four hooks ship in `_base` and are not configurable: **secret-scan**, **command-guard**, **audit-log**, **verify-gate**. There is no config key that turns them off, no module that removes them, no harness shape where they are absent.

This page explains why. Read this *before* you find yourself tempted to disable one.

---

## The four hooks

| Hook | Event | What it does |
|---|---|---|
| `secret-scan.sh` | `PreToolUse` on `Write\|Edit\|MultiEdit` | Greps the proposed payload for AWS / GCP / Stripe / GitHub / private-key patterns. Exit 2 blocks the write. |
| `command-guard.sh` | `PreToolUse` on `Bash` | Blocks `rm -rf`, force-push, `git reset --hard`, raw `DROP/TRUNCATE`, and similar irreversibles. Exit 2 blocks the command. |
| `audit-log.sh` | `PostToolUse` on `*` | Appends a JSON-lines record of every tool call to `.claude/audit/audit.jsonl`. Never blocks. |
| `verify-gate.sh` | `Stop` | Runs `./.claude/verify.sh` before letting the session end. Exit non-zero refuses "done". |

Source: [`templates/_base/.claude/hooks/`](../../templates/_base/.claude/hooks/).

These run regardless of `--dangerously-skip-permissions`. That is the design: the flag bypasses Claude Code's *permission prompts*; it does not bypass `PreToolUse` exit code 2.

---

## Why these four are not opt-out

Every other constraint in this repo is opt-out: pick a memory backend, pick a methodology, pick safety gates. These four are different. Each addresses a failure mode where the cost of being wrong is so high that "we forgot to turn it on" is not an acceptable outcome.

### Secret scanning — the AWS-key leak

A model writing application code routinely brushes against credentials: it sees an env-var name, an example value in documentation, a misremembered key from training data. Without a hook, an agent has every motivation to "fix" a `process.env.STRIPE_KEY` reference by pasting in a literal key. The hook is a regex; it is not clever. But the failure mode it prevents — a real key committed to a public repo — has cost real money in real incidents, every year, for decades. The hook is on by default because it is *cheap on the average case and load-bearing on the worst case*.

A consenting user can edit the hook to relax patterns for a specific project. A model cannot.

### Command guard — the `rm -rf /` story

The cardinal example: an agent given a Bash tool with no guard runs an `rm -rf` against the wrong path. Variants: `git push --force` over a colleague's branch; `git reset --hard` over uncommitted work; a `DROP TABLE` against the wrong database. Every irreversible command is a single typo away from an incident.

The model's average behaviour is fine — it usually does not propose `rm -rf /`. The problem is the *long tail*: occasionally, in some context, it does. The harness should reject those proposals categorically, not on average.

The guard is pattern-based and necessarily imperfect. Legitimate uses sometimes match; reformulate them or relax the guard locally. The default tilts toward false positives because the *false negative* — letting a destructive command through — is unrecoverable.

### Audit log — the question you cannot answer otherwise

After any incident, the first question is: *"What did the agent actually do?"* Without an append-only log, you cannot answer. The model's narration is not evidence; the diff is not the whole record (tool calls without writes leave no diff); the transcript may not have been captured. The audit log is the record.

It does not block anything. It is append-only by design — a hook that *also* truncates is not an audit log. Rotate it on your own schedule; archive it for regulated work; ship it to immutable storage when retention matters. Never delete it during a session.

Disabling it to "reduce noise" is the wrong trade. Storage is cheap; an unanswerable post-mortem is not.

### Verify gate — evidence before assertions

The single most common silent regression: an agent reports "done" without running the verification commands that would have proven success. The model is *trained* to be helpful, which includes signalling completion. Without a gate, signalling completion is rewarded.

The verify gate forces a deterministic check at the end of the session. `./.claude/verify.sh` exists in every project; the agent cannot self-declare done until it returns zero. If your verify.sh is empty, the gate is a no-op; if it runs tests, lint, and typecheck, the gate is load-bearing.

This is the part of the harness people are most tempted to disable when working under time pressure. *Especially do not disable it then.* Time-pressure decisions are exactly when silent failures cost the most.

---

## What "not configurable" actually means

It means there is no key in `harness.config.yml` that disables them, no module that removes them, no recipe that omits them. It does not mean you cannot edit them in your own project after assembly. You can:

- Tighten `secret-scan.sh` for your project's specific token shapes.
- Relax `command-guard.sh` if your domain genuinely needs a pattern the default blocks.
- Customise `audit-log.sh` to ship to your immutable bucket.
- Make `verify-gate.sh` run additional checks beyond `.claude/verify.sh`.

What you cannot do is *delete them from the repo's defaults* such that future assemblies skip them. That defeats their purpose.

If your project genuinely needs no secret scanning (every key is already env-var-only by convention), the right move is a no-op `secret-scan.sh` in your project that you keep deliberately. The hook is still there; the agent still sees the wired hook; the contract is still in place. You are explicitly opting out, and the opt-out is visible in your project's diff.

---

## What goes wrong when one of these is off

Reading the incident reports, the patterns are consistent:

| Hook off | Failure mode |
|---|---|
| `secret-scan` | A real key in a `.env.example`, a `config.json`, or a hardcoded test fixture. Public repo; key rotated within hours; cost is whoever's name is on the cloud account. |
| `command-guard` | `rm -rf` on the wrong path; `git push --force` over a colleague's branch; `git reset --hard` losing uncommitted work. Recovery: from backup if you have one. |
| `audit-log` | Cannot answer "what did the agent do" after an incident. Post-mortem is reduced to vibes. |
| `verify-gate` | "Done" claimed; tests not run; PR opens with broken work; reviewer's time is wasted at best and a regression ships at worst. |

The unifying property: each is a *quiet* failure. The hook off, nobody notices until the day it matters.

---

## The Anthropic Rule of Two, briefly

[Oso's "Agents Rule of Two"](https://www.osohq.com/learn/agents-rule-of-two-a-practical-approach-to-ai-agent-security) says: any agent session may hold at most two of {untrusted inputs, sensitive systems, external state change}. The four `_base` hooks are the floor under that rule:

- `secret-scan` and `command-guard` limit *external state change* even when the other two are present.
- `audit-log` makes *any* combination auditable.
- `verify-gate` makes the assertion of completion verifiable.

A harness without these floors does not satisfy the Rule of Two in any meaningful sense, regardless of the prose in CLAUDE.md.

---

## See also

- [`why-harness.md`](why-harness.md) — why the harness is the contract, not the prompt.
- [`picking-vs-discarding.md`](picking-vs-discarding.md) — why everything *else* is opt-in.
- [`reference/assembled-output.md`](../reference/assembled-output.md#claudehooks--the-four-_base-hooks) — what each hook ships as.
- [`HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) — the deep reference with full incident citations.
