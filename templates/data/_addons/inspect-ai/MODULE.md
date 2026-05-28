# Addon — inspect-ai

UK AISI `inspect-ai` (Apache-2.0, May 2026). Sandbox-isolated eval
framework; 200+ pre-built evals in `UKGovernmentBEIS/inspect_evals`.

## Adopt if

- You need rigorous, reproducible LLM evals — especially for agentic
  systems.
- You want sandbox isolation for the agent under test.

## Skip if

- Your eval surface is purely assertion-style and you do not need
  sandbox isolation.

## What it contributes

- CLAUDE.md section: dataset → solver → scorer pattern; Docker-sandboxed
  evals; the 200+ pre-built evals catalogue; the rule that Inspect AI
  can wrap Claude Code, Codex, and Gemini CLI as the agent under test.
- Skill: `inspect-eval-author` — recipe for authoring a new task.

## Provision before install

- Docker available locally or in CI.
- `uv add inspect-ai`.
- Optional: clone `UKGovernmentBEIS/inspect_evals` for starter tasks.

## Pairs with

`llm-app` (primary), `ml-pipeline`.
