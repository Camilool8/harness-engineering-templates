# Module: safety/sandbox

> Config: `safety.sandbox` · Depends on: none

**What it does.** Restricts the agent's filesystem and network reach for
sessions that ingest untrusted input. Ships a `.claude/sandbox/` settings
fragment with a write deny-list (no writes outside the working directory) and a
network-egress allow-list, plus guidance on running the agent under Anthropic's
sandbox-runtime or a container for enforcement that survives a sandbox escape.

## Adopt if
- The agent processes untrusted input — GitHub issues/PRs, web pages, scraped
  content, third-party API responses, or MCP tool output.
- A prompt-injection or sandbox-escape attempt is a realistic threat for your
  workload (it is, for any of the above).
- You want the blast radius of a compromised turn bounded to the working
  directory and a known set of network destinations.

## Skip if
- The agent only ever sees trusted, first-party input and runs no untrusted
  tools — the restriction adds friction with little gain.
- Your runtime already enforces equivalent isolation (a locked-down CI
  container, an ephemeral VM) — keep that; this fragment is then redundant.

## Dependencies
- `jq` is not required (no hook ships in this module).
- **Strongly recommended:** run Claude Code under
  [Anthropic sandbox-runtime](https://github.com/anthropic-experimental/sandbox-runtime)
  or inside a container/VM. The settings fragment is a policy declaration; an
  agent that escapes the harness can ignore `settings.json`. Real containment
  needs an OS-level boundary.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Merge `.claude/sandbox/settings.fragment.json` into your `.claude/settings.json`
   — specifically its `permissions.deny` and `permissions.allow` entries. Edit
   the network allow-list to the exact hosts your task needs; default-deny the
   rest.
4. For real enforcement, launch the agent under sandbox-runtime or a container
   with unscoped network egress disabled. See `.claude/sandbox/README` guidance
   in the fragment comments.

## Install (assemble.sh)
Set `safety.sandbox: true` in `harness.config.yml`; run `./assemble.sh`.

## Remove
- Delete `.claude/sandbox/`.
- Remove the merged `permissions` entries from `.claude/settings.json`.
- Remove the `## Safety — sandbox` section from `CLAUDE.md`.

## Files
- `files/.claude/sandbox/settings.fragment.json` — a `permissions` fragment: a
  write deny-list confining writes to the working directory and away from
  credential/config paths, and a `WebFetch` egress allow-list (default-deny).
  Merge into `.claude/settings.json`; the inline comments document the
  container/sandbox-runtime guidance and the egress-allow-list approach.
