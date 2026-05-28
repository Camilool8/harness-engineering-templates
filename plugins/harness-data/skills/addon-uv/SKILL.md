---
name: data-addon-uv
description: Astral uv toolchain conventions — lockfile-frozen by default with uv lock --frozen and uv sync --frozen, uv add for atomic pyproject + lock updates, frozen-only CI/production installs, and uv v0.7+ as the minimum. Use when managing Python dependencies, freezing environments, or setting up a reproducible Python project.
---

# uv (Python toolchain)

- **Lockfile-frozen by default.** `uv lock --frozen` + `uv sync --frozen`.
  The `lockfile-frozen.sh` hook (PostToolUse on `Bash`) refuses
  `pip install` outside an explicit deps-update mode (`UV_DEPS_UPDATE=1`).
- **Adding a package:** `uv add <pkg>` updates `pyproject.toml` +
  `uv.lock` atomically.
- **CI / production install:** `uv sync --frozen` only. Refuses to drift
  the lockfile during a deploy.
- **uv v0.7+ (May 2026)** is the minimum version this addon targets.
