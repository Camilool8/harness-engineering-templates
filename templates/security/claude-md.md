## Security research rules

**Authorized testing only.** This harness is for authorized penetration
testing, CTF challenges, and defensive security research. Every target you
touch must be covered by a signed engagement scope. If you are not certain a
target is in scope, you are not authorized to touch it. Stop and ask.

**Every action is scope-checked.** Scanning and network tools are gated against
the allowlist in `.claude/engagement-scope.txt` by the `scope-gate` hook. Out
of scope is blocked, hard. Do not look for ways around the gate — keep the
scope file accurate instead.

**Red and blue are separated.** Offensive (red-team) work and defensive
(blue-team) work run in different isolated subagents — never the same context.
Offensive tooling, payloads, and exploit findings must not leak into defensive
analysis, and defensive context must not contaminate offensive work. The
supervisor fans out; it does not blend the two roles.

**SAST is wired in.** The `sast-on-write` hook runs semgrep on edited code as
an advisory pass (non-blocking). Treat its findings as review input — a clean
run is not a clearance.

**Findings are tracked, not just found.** Log every finding as an issue with
enough detail to reproduce and remediate.
