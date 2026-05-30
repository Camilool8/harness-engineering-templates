# SessionStart harness auto-loader — design

**Date:** 2026-05-30
**Status:** Approved for planning

## Problem

A user installs a domain pack (e.g. `harness-web`) via the plugin marketplace and
expects the harness to "just work" in their repo. Two things surprise them:

1. **Nothing lands in the project `.claude/`.** This is correct — plugins load from
   the plugin cache, not the repo. Hooks and agents are active session-wide; agents
   are available as agent *types*. This is by design and only needs documenting.
2. **The domain rules feel like they must be re-invoked every session.** This is a
   real gap. The pack skills (`web-domain`, the subdomain skills) are *model-invoked*
   by description matching. There is no `SessionStart` hook pinning them, so the
   `web-domain` skill's own claim — "Auto-loads for any web engineering work" — is
   currently false.

The activation marker already exists: each pack's `/<pack>:init` command writes
`[<domain>] subdomain = "..."` to `.claude/HARNESS.toml`. Nothing reads it at
session start.

## Goal

After a one-time `/<pack>:init`, every new session in that repo automatically pins
the pack's `*-domain` shared rules **and** the selected subdomain skill into context,
with no model-invocation required. Make the "auto-loads" claim true.

## Decisions (from brainstorming)

- **Injection strategy:** full skill content, superpowers-style. The loader `cat`s the
  actual `SKILL.md` bodies into `additionalContext`, guaranteeing the rules are present
  rather than relying on the model obeying a nudge.
- **Location/scope:** per-pack loader, all four packs (`web`, `data`, `devops`,
  `mobile`) in one pass. Each pack reads its own skills via its own
  `${CLAUDE_PLUGIN_ROOT}` — no fragile `../sibling` hop into another plugin's cache dir.
- **Subdomain → skill-dir mapping:** resolve **by existence**, not by a hardcoded
  prefix rule (the packs are inconsistent — web is unprefixed, the others are
  `<domain>-<sub>`). Try `skills/<subdomain>/` then `skills/<domain>-<subdomain>/`.
- **Fix data `init.md`:** its `data-analyst-notebook` option label is prefixed while
  its three siblings are not. Rename the label to `analyst-notebook` so all four data
  subdomain values are unprefixed (matching devops/mobile). Resolver maps it to the
  `data-analyst-notebook/` skill dir.

## Component: `hooks/load-harness.sh`

One per pack, identical logic. Wired by a new `SessionStart` block in each pack's
`hooks.json`:

```json
"SessionStart": [
  { "hooks": [
    { "type": "command",
      "command": "${CLAUDE_PLUGIN_ROOT}/hooks/load-harness.sh web" } ] }
]
```

The domain (`web`/`data`/`devops`/`mobile`) is passed as an explicit positional arg —
robust, no basename guessing.

### Logic

1. Read `${CLAUDE_PROJECT_DIR}/.claude/HARNESS.toml`. Absent → `exit 0`, no output.
2. Parse the `[<domain>]` table (awk: track the current `[header]`, grab
   `subdomain = "..."` only while inside `[<domain>]`). No `[<domain>]` table →
   `exit 0`, no output. (A data repo must not get web rules injected.)
3. Always include `skills/<domain>-domain/SKILL.md` (the shared rules).
4. Resolve the subdomain by existence: try `skills/<subdomain>/SKILL.md`, then
   `skills/<domain>-<subdomain>/SKILL.md`; include whichever exists.
   - Subdomain set but unresolvable → include the domain skill plus a one-line
     warning naming the bad value.
   - `[<domain>]` table present but `subdomain` unset → include the domain skill only.
5. Emit one JSON object built with `jq` (already a dependency) so content is safely
   encoded:
   ```json
   {"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"..."}}
   ```
   `additionalContext` wraps the skill bodies under a header, e.g.:
   `# Harness: this project is web/fullstack-app — the following rules are pinned for this session.`

### Error handling

- Read-only; **never blocks session start**. Any internal failure (missing `jq`,
  unreadable file, parse miss) → `exit 0`, fail-open. A broken loader must not brick
  every session in the repo.

## Wiring

Each pack's `plugin.json` already declares `"hooks": "./hooks/hooks.json"`. The change
is: add the `SessionStart` block to each `hooks.json` and drop `load-harness.sh` into
each pack's `hooks/`. Four near-identical script copies (plugins cannot share files
across cache dirs) — accepted cost.

## Documentation

A short "how activation works" note (plugin path vs eject path; one-time
`/<pack>:init`; what gets pinned each session) so the original confusion does not
recur. Placement: extend the existing how-to / getting-started docs rather than add a
new top-level page.

## Testing

New `plugins/tests/test-load-harness.sh`, wired into `run-plugin-tests.sh`,
table-driven against fixture TOMLs + `CLAUDE_PROJECT_DIR`:

- no `HARNESS.toml` → empty output, exit 0
- `[<other-domain>]` only → empty output, exit 0
- web unprefixed resolve (`fullstack-app` → `skills/fullstack-app`)
- data prefixed resolve (`ml-pipeline` → `skills/data-ml-pipeline`)
- `analyst-notebook` → `skills/data-analyst-notebook` (post-fix value)
- bad subdomain → domain skill only + warning, exit 0
- output is valid JSON with non-empty `additionalContext`
- missing `jq` simulated → exit 0

## Out of scope (YAGNI)

- Addon / `using-*` skills stay model-invoked by description.
- Base module skills (tdd/memory/orchestration) keyed off other TOML keys are not
  auto-loaded — separate concern.
- No change to the eject (`templates/assemble.sh`) path; vendored files are already
  physically present and need no loader.
