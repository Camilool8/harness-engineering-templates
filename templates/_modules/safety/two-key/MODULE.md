# Module: safety/two-key

> Config: `safety.two_key` · Depends on: none

**What it does.** Adds a `PreToolUse` hook on `Bash` that intercepts commands
matching prod/destructive patterns and blocks them until a typed
`CONFIRM <token>` confirmation appears in the command. The token is a nonce the
LLM cannot self-generate — it is validated against an environment variable or a
human-created `.claude/.two-key-nonce` file. A single yes/click is never enough.

## Adopt if
- The agent can reach tools that delete data, move money, deploy to production,
  or flash firmware — anything irreversible with real blast radius.
- You want the second key held by a principal the agent cannot impersonate: the
  agent proposes the action, a human (or out-of-band system) supplies the token.
- You are in a regulated or finance context where two-person integrity on
  irreversible actions is a requirement.

## Skip if
- The agent has no irreversible tools — there is nothing to gate.
- The base command-guard already hard-blocks every dangerous command you care
  about and you never want those commands to run at all (two-key is for
  actions you *do* sometimes need, under control).
- A non-interactive CI agent runs unattended with no human to supply a token —
  there, prefer hard denial or a pre-issued scoped nonce, not interactive
  two-key.

## Dependencies
- `jq` (parses the hook's stdin event).
- A human-supplied nonce: either the env var `HARNESS_TWO_KEY_TOKEN` set in the
  session, or a `.claude/.two-key-nonce` file created out-of-band by a human.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. `chmod +x .claude/hooks/two-key-confirm.sh`.
4. Register the hook in `.claude/settings.json` under `hooks.PreToolUse` for
   matcher `Bash`. To also gate prod-tagged MCP/custom tools, add their tool
   names to the same matcher (the hook reads `tool_input.command` for Bash and
   falls back to scanning the serialized `tool_input` for other tools).
5. Provide the nonce out-of-band — either `export HARNESS_TWO_KEY_TOKEN=...`
   before launching Claude Code, or have a human write `.claude/.two-key-nonce`.
   Never let the agent create or read-then-echo this value as a shortcut.

## Install (assemble.sh)
Set `safety.two_key: true` in `harness.config.yml`; run `./assemble.sh`.

## Remove
- Delete `.claude/hooks/two-key-confirm.sh`.
- Delete `.claude/.two-key-nonce` if present.
- Remove the `two-key-confirm.sh` entry from `.claude/settings.json`
  `hooks.PreToolUse`.
- Remove the `## Safety — two-key confirmation` section from `CLAUDE.md`.

## Files
- `files/.claude/hooks/two-key-confirm.sh` — `PreToolUse` hook on `Bash`. If the
  command matches a destructive/prod pattern, it requires a `CONFIRM <token>`
  substring whose token matches the human-held nonce; exits 2 to block
  otherwise.
- `files/.claude/settings.fragment.json` — settings fragment registering the
  hook. `assemble.sh` deep-merges it into `.claude/settings.json`; for a manual
  install, merge its `hooks.PreToolUse` entry by hand.
