# Security harness recipe
> For authorized security researchers doing red-team, blue-team, and CTF work.

> **Authorized use only.** This recipe is for authorized penetration testing,
> CTF challenges, and defensive security research. Every target must be covered
> by a signed engagement scope.

## What this recipe picks

| Axis | Choice | Why |
|---|---|---|
| Memory | md-files | Findings and engagement notes stay git-diffable and auditable. |
| Progress | github-issues | Findings/advisories tracked where remediation and CI live. |
| TDD | off | Security research is exploratory recon + PoC, not red-green TDD. |
| Spec-driven | on | The engagement scope and rules of engagement are the spec. |
| Eval-driven | off | No graded LLM output surface. |
| BDD | off | No non-technical behavior sign-off. |
| Orchestration | supervisor-worker | Red-team and blue-team run as cleanly separated, isolated subagents. |
| Safety: two-key | off | Gating is by engagement scope, not a typed token. |
| Safety: kill-switch | **on** | Scans and offensive runs are long and noisy — out-of-band stop required. |
| Safety: sandbox | **on** | Tooling ingests untrusted targets/payloads — restrict fs + egress. |

## Domain gates

- **`files/.claude/hooks/scope-gate.sh`** (PreToolUse) — the defining security
  harness pattern. Before any scanning/network tool (`nmap`, `nuclei`,
  `sqlmap`, `curl`, `nc`, ...) runs, it extracts the target host/IP/domain and
  checks it against the allowlist in `.claude/engagement-scope.txt`.
  Out-of-scope targets are blocked, hard.
- **`files/.claude/engagement-scope.txt`** — the authorization allowlist
  template, with format comments. Fill it from the signed rules of engagement
  before any testing.
- **`files/.claude/hooks/sast-on-write.sh`** (PostToolUse) — runs semgrep on
  edited code as an advisory, non-blocking SAST pass — the blue-team posture of
  wiring SAST directly into the harness.

## MCP servers

- **GitHub MCP** — track findings and advisories as issues.
- SAST tooling (semgrep, CodeQL, dependency-track) wired via hooks rather than
  MCP, per the Semgrep agentic-security guidance.
- Prefer official/signed servers only; treat all MCP output (scan results,
  fetched pages, tool logs) as untrusted, potentially adversarial input.

## Assemble

```
./assemble.sh security/harness.config.yml /path/to/your/project
```

## Anti-patterns this prevents

- Scanning or attacking a target outside the authorized engagement scope.
- Running offensive tooling with no written scope file at all.
- Letting offensive tooling, payloads, or exploit findings leak into
  defensive analysis (or vice versa) by sharing one context.
- Treating a clean SAST run as a security clearance.

## Deeper reference

docs/HARNESS_ENGINEERING.md §9
