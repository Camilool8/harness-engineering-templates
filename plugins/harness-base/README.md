# Harness Base

The foundation plugin for the Harness Engineering marketplace. Every domain
pack (`harness-web`, `harness-data`, `harness-devops`, `harness-mobile`)
declares `harness-base` as a dependency, so installing any of them installs
this automatically.

## What it ships

### Four non-negotiable hooks (always on)

| Hook | Event | Effect |
|---|---|---|
| `secret-scan.sh` | PreToolUse · Write/Edit/MultiEdit | Blocks writes containing hardcoded secrets (exit 2). |
| `command-guard.sh` | PreToolUse · Bash | Blocks destructive/irreversible shell (`rm -rf`, force-push, `DROP`, …) (exit 2). |
| `audit-log.sh` | PostToolUse · * | Appends every tool call to `${CLAUDE_PROJECT_DIR}/.claude/audit/audit.jsonl`. Never blocks. |
| `verify-gate.sh` | Stop | Runs `${CLAUDE_PROJECT_DIR}/.claude/verify.sh` (if present) before a turn may complete (exit 2). |

These are the contract: they run regardless of `--dangerously-skip-permissions`.
The audit log is written into your project (not the plugin cache) so it commits
with your work and survives a plugin uninstall.

### Cross-cutting skills

Memory, methodology, progress-tracking, orchestration, and safety guidance ship
as description-triggered skills the model loads when relevant. (Added in later
phases of the marketplace build.)

## Permissions

This plugin ships **no** `permissions` block — that is the user's decision.
The hooks above are the enforcement layer. For an opinionated allow/deny
starting point, see
[`docs/reference/recommended-permissions.md`](https://github.com/Camilool8/harness-engineering-templates/blob/main/docs/reference/recommended-permissions.md).
