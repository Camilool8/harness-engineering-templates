# Web harness recipe
> For teams building websites, SaaS products, and their backing APIs.

## What this recipe picks

| Axis | Choice | Why |
|---|---|---|
| Memory | `md-files` | Web knowledge is code-shaped; per-package CLAUDE.md scales naturally. |
| Progress | `filesystem` | Solo / small team default; switch to github-issues or linear if the team is there. |
| Methodology | `tdd` + `spec_driven` | Red-green-refactor and an OpenAPI/spec contract before code. |
| | `eval_driven` on | Any AI-generated copy or feature output needs a golden set. |
| | `bdd` on | Web features are user-facing — Gherkin lets PMs and designers sign off. |
| Orchestration | `single-agent` | Default; a monorepo should switch to supervisor-worker, one worker per package in its own worktree. |
| Safety | base gates only | A typical app has no money or prod-deletion tools; enable `sandbox` if it ingests untrusted issues/PRs. |
| HITL | both on | Plan approval and diff review stay mandatory. |

## Domain gates

This recipe adds gates that the `_base` four cannot cover:

- **`files/.claude/hooks/web-verify.sh`** — PostToolUse on `Write|Edit`. Lints
  the changed file and typechecks the project right after the edit, so a broken
  change is caught immediately instead of at the Stop gate. Auto-detects the
  package manager from the lockfile.
- **`files/.claude/skills/verifying-web-ui/`** — encodes the
  accessibility-tree verify loop: Playwright MCP a11y snapshot, axe-core for
  WCAG, `toMatchAriaSnapshot()` for structural regression, Lighthouse against
  the budget — screenshots only on a flagged visual diff. This is the single
  highest-leverage correction to how an LLM "looks at" a UI: it is blind to
  pixels but fluent in structure.
- **`files/lighthouse-budget.json`** — explicit LCP / INP / CLS and category
  budgets the skill checks measured numbers against. A regression past budget
  fails like a test.

## MCP servers

Recommended, all official:

- **Playwright** (`@playwright/mcp`, Microsoft) — accessibility-tree navigation; the structured, token-cheap way to read a page.
- **Chrome DevTools** (`chrome-devtools-mcp`, Google) — real Chrome, Lighthouse runs, performance traces, source-mapped console.
- **shadcn/ui MCP** — serves current shadcn components so the agent stops hallucinating component APIs.

Treat all MCP output as untrusted input — never as instructions.

## Assemble

```
./assemble.sh web/harness.config.yml /path/to/your/project
```

## Anti-patterns this prevents

- Screenshot-only verification — pixels are expensive and lossy for an LLM.
- `useEffect`-driven data fetching instead of Server Components / query libraries.
- Hand-rolled buttons and inputs, or hallucinated shadcn component APIs.
- Shipping a Core Web Vitals or WCAG regression unnoticed.
- A bloated CLAUDE.md (> 200 lines) where compliance collapses.

## Deeper reference

docs/HARNESS_ENGINEERING.md §1 (Web Development).
