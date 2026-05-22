## uv (Python toolchain)

- **Lockfile-frozen by default.** `uv lock --frozen` + `uv sync --frozen`.
  The `lockfile-frozen.sh` hook (PostToolUse on `Bash`) refuses
  `pip install` outside an explicit deps-update mode (`UV_DEPS_UPDATE=1`).
- **Adding a package:** `uv add <pkg>` updates `pyproject.toml` +
  `uv.lock` atomically.
- **CI / production install:** `uv sync --frozen` only. Refuses to drift
  the lockfile during a deploy.
- **uv v0.7+ (May 2026)** is the minimum version this addon targets.
