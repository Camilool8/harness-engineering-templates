# Addon — uv

Astral `uv` Python toolchain — fast, deterministic pure-Python
environments with a lockfile guard hook.

## Adopt if

- You want a deterministic Python environment with `pyproject.toml` +
  `uv.lock`.
- You write pure-Python (no conda / CUDA / MKL hard requirements).

## Skip if

- You must use conda for CUDA / MKL / R interop → defer to a future
  `pixi` addon.

## What it contributes

- CLAUDE.md section: lockfile-frozen discipline + the `uv add --frozen`
  / `uv pip` lockfile guard.
- Hook: `lockfile-frozen.sh` (PostToolUse on `Bash` matching
  `pip install|uv add|uv pip`). Refuses unfrozen installs outside an
  explicit deps-update mode.

## Pairs with

`data-analyst-notebook` · `ml-pipeline` · `llm-app` · `analytics-engineering`
