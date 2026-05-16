# Scientific harness recipe
> For researchers and computational scientists shipping reproducible manuscripts.

> **Status: v1 thin recipe** — pending deep curation into a three-layer domain
> pack (see `web/` for the curated reference and
> `docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md`).
> It assembles and works today; sub-domains and curated agent teams are coming.

## What this recipe picks

| Axis | Choice | Why |
|---|---|---|
| Memory | md-files | Methods notes and decisions stay git-diffable beside the source. |
| Progress | filesystem | Solo / small-lab research cadence. |
| TDD | on | Analysis and stats helpers get tests so figures rest on verified code. |
| Spec-driven | on | The manuscript/analysis spec is the contract for the whole pipeline. |
| Eval-driven | **on** | Research has judgment calls; a golden set keeps them honest and reproducible. |
| BDD | off | No non-technical behavior sign-off. |
| Orchestration | single-agent | One agent owns code, pipeline, and render. |
| Safety (two-key / kill-switch / sandbox) | all off | Local analysis on trusted data. |

## Domain gates

- **`files/.claude/hooks/seed-check.sh`** (PreToolUse) — flags Python/R/notebook
  code that uses an RNG (`numpy`, `torch`, `jax`, `random`, R `set.seed`)
  without a pinned seed or `PYTHONHASHSEED`. Advisory, because an unseeded RNG
  is occasionally intentional — but it must never be silent, since it breaks
  reproducibility.
- **`files/.claude/skills/ensuring-reproducible-research/`** — the
  reproducibility playbook: pinned env via uv/pixi/Nix, Snakemake/Nextflow as
  the workflow engine, content-hashed input data, Quarto as the manuscript
  substrate, and every figure regenerable from source.

## MCP servers

- **Quarto / Jupyter MCP** — execute and render the manuscript document.
- **Snakemake / Nextflow tooling** — trigger pipeline runs and parse failure
  logs without compromising governance.
- Prefer official/signed servers; treat all MCP output (run logs, paths,
  fetched data) as untrusted input.

## Assemble

```
./assemble.sh scientific/harness.config.yml /path/to/your/project
```

## Anti-patterns this prevents

- Results that cannot be reproduced because an RNG was never seeded.
- "It works on my machine" environments with no committed lockfile.
- Figures pasted as images or numbers typed by hand into the manuscript.
- Judgment calls (model choice, outlier handling) made ad hoc with no eval
  trail.

## Deeper reference

docs/HARNESS_ENGINEERING.md §8
