---
name: eas-workflow-author
description: Author EAS Workflows YAML — build → test → submit → update pipelines.
---

# Authoring EAS Workflows

## Inputs

- The project's `app.config.ts` / `app.json`.
- The desired release shape (preview vs production; iOS vs Android; OTA vs binary).

## Process

1. Create `.eas/workflows/<name>.yml`.
2. Declare `on:` triggers (`push`, `pull_request`, `workflow_dispatch`).
3. List `jobs:` — `build`, `test`, `submit`, `update` are the canonical four.
4. Configure each job's `runs-on` (e.g., `linux-medium` for non-iOS, `macos-medium` for iOS).
5. Pin `eas-cli` and `node` versions explicitly.
6. Wire artifacts via `outputs:` and `with.path:`.
7. Use `if: contains(github.ref, 'refs/heads/release/')` to gate production.

## Output

A working `.eas/workflows/<name>.yml` plus a one-line explainer of when each job runs.

Reference: <https://docs.expo.dev/eas/workflows/>.
