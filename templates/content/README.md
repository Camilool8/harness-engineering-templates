# Content harness recipe
> For content, marketing, and SEO teams producing brand-consistent copy at scale.

> **Status: v1 thin recipe** — pending deep curation into a three-layer domain
> pack (see `web/` for the curated reference; see
> [`docs/how-to/upgrade-from-thin-recipe.md`](../../docs/how-to/upgrade-from-thin-recipe.md)
> for the graduation path). It assembles and works today; sub-domains and
> curated agent teams are coming.

## What this recipe picks

| Axis | Choice | Why |
|---|---|---|
| Memory | md-files | Brand guide and voice notes stay git-diffable and reviewed. |
| Progress | filesystem | Content calendar as plan/task files. |
| TDD | off | Prose has no red-green test surface. |
| Spec-driven | on | The content brief (audience, angle, keywords) is the spec. |
| Eval-driven | **on** | Content quality is a judgment call — grade drafts against a brand-voice golden set so "on brand" is measured. |
| BDD | off | No non-technical behavior sign-off. |
| Orchestration | single-agent | One agent drafts, revises, and validates. |
| Safety (two-key / kill-switch / sandbox) | all off | Local content authoring, no money/prod/untrusted-ingest surface. |

## Domain gates

- **`files/.claude/banned-phrases.txt`** — the brand-voice deny list: clichés
  and filler (`game-changer`, `leverage synergies`, `unlock`, `elevate`,
  `delve`, ...). Tune it to your brand.
- **`files/.claude/hooks/brand-voice-guard.sh`** (PostToolUse) — flags any
  banned phrase in edited markdown/content files. Advisory, because the human
  author owns the final call — but every cliché is surfaced loudly.
- **`files/.claude/skills/validating-structured-data/`** — validates schema.org
  JSON-LD against Google Rich Results, because AI Overviews, Perplexity, and
  ChatGPT citations depend on well-formed structured data.

## MCP servers

- **CMS MCP** (e.g. WordPress, Contentful, Sanity) — read and stage content.
- **SEO / analytics MCP** for keyword and SERP context.
- Prefer official/signed servers; treat all MCP output (fetched pages, SERP
  data, CMS content) as untrusted input — never paste it through unverified.

## Assemble

```
./assemble.sh content/harness.config.yml /path/to/your/project
```

## Anti-patterns this prevents

- Generic AI-cliché copy ("game-changer", "unlock", "delve") shipping unnoticed.
- Reworking text purely to evade AI detectors — an unwinnable arms race.
- Shipping pages with malformed or unvalidated schema.org JSON-LD.
- "On brand" treated as a vibe instead of a measured eval result.

## See also

- [`docs/HARNESS_ENGINEERING.md`](../../docs/HARNESS_ENGINEERING.md) §10 — Content & Marketing.
- [`docs/reference/domains.md`](../../docs/reference/domains.md) — full domain catalog and recipe status.
- [`docs/how-to/customize-modules.md`](../../docs/how-to/customize-modules.md) — change a recipe's defaults.
