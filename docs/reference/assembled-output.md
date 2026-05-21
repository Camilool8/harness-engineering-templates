# Reference: the assembled output

What ends up in your project after `./templates/assemble.sh` succeeds. This is the contract: every file below has a defined purpose and a defined owner.

---

## The full tree (base + a typical recipe)

```
<your-project>/
├── CLAUDE.md                           agent-facing project memory (root)
├── AGENTS.md                           agent-facing repo conventions
├── .mcp.json                           MCP servers wired for this project
├── .gitignore                          baseline ignores (.env, secrets/, build artefacts)
└── .claude/
    ├── settings.json                   permissions + hooks registry
    ├── HARNESS.lock                    informational: what was assembled
    ├── verify.sh.example               template for the project-specific Stop gate
    │
    ├── hooks/                          shell hooks the runtime invokes
    │   ├── audit-log.sh                _base · PostToolUse · append-only audit log
    │   ├── command-guard.sh            _base · PreToolUse · blocks irreversible Bash
    │   ├── secret-scan.sh              _base · PreToolUse · blocks hardcoded secrets
    │   ├── verify-gate.sh              _base · Stop · refuses "done" until verify.sh passes
    │   └── …                           module hooks (tdd-guard, two-key, kill-switch, …)
    │
    ├── skills/                         opt-in skills the agent can invoke
    │   ├── practicing-tdd/             from methodology/tdd
    │   ├── writing-specs/              from methodology/spec-driven
    │   └── …                           per-module skills
    │
    ├── agents/                         specialist sub-agents (if any installed)
    │   ├── README.md                   roster description
    │   └── …                           one *.md per agent
    │
    ├── memory/                         from memory/md-files (if picked)
    │   └── README.md                   instructions for the agent
    │
    ├── progress/                       from progress-tracking/filesystem (if picked)
    │   └── README.md                   plan + task file conventions
    │
    └── audit/                          created lazily by audit-log.sh
        └── audit.jsonl                 append-only tool-call audit trail
```

The `.claude/` directory is Claude Code's project-local configuration root. Everything inside it is read by the runtime; nothing inside it ships outside this project unless you commit and push.

---

## What every file does

### Root files

| File | Owner | Purpose |
|---|---|---|
| `CLAUDE.md` | You, mostly | Project memory the agent reads on every turn. Starts as a template with placeholders; each module appends a section. Keep it under ~60 lines. |
| `AGENTS.md` | `_base` | Repo conventions every agent inherits — workflow loop, commit style, "evidence before assertions". Generic; rarely needs editing. |
| `.mcp.json` | `_base` + modules | MCP server registry. Servers are wired by addons and by `docs.context7_mcp`. Credentials are `${ENV_VAR}` placeholders. |
| `.gitignore` | `_base` | Baseline ignores. Add to it; do not remove without reason. |

### `.claude/settings.json`

Permissions and hooks registry. The `_base` shape:

```json
{
  "permissions": {
    "allow": ["Read", "Grep", "Glob"],
    "deny":  ["Read(./.env)", "Read(./.env.*)", "Read(./secrets/**)", "Bash(rm -rf /*)"],
    "defaultMode": "ask"
  },
  "hooks": {
    "PreToolUse":  [ { "matcher": "Write|Edit|MultiEdit", "hooks": [ secret-scan.sh ] },
                     { "matcher": "Bash",                 "hooks": [ command-guard.sh ] } ],
    "PostToolUse": [ { "matcher": "*",                    "hooks": [ audit-log.sh ] } ],
    "Stop":        [                                      { "hooks": [ verify-gate.sh ] } ]
  }
}
```

Modules add to `hooks` arrays via `settings.fragment.json` files that `assemble.sh` deep-merges (see [`reference/assemble-cli.md`](assemble-cli.md#merge-semantics)).

### `.claude/hooks/` — the four `_base` hooks

Every assembled project ships these four. See [`explanation/non-negotiables.md`](../explanation/non-negotiables.md) for *why* they are not configurable.

| Hook | Event | Matcher | Action |
|---|---|---|---|
| `secret-scan.sh` | `PreToolUse` | `Write\|Edit\|MultiEdit` | Greps the proposed payload for AWS/GCP/Stripe/GitHub/private-key patterns. Exit 2 blocks the write. |
| `command-guard.sh` | `PreToolUse` | `Bash` | Blocks `rm -rf`, `git push --force`, `git reset --hard`, raw `DROP/TRUNCATE`, and other irreversibles. Exit 2 blocks the command. |
| `audit-log.sh` | `PostToolUse` | `*` | Appends a JSON-lines record of every tool call to `.claude/audit/audit.jsonl`. Never blocks. |
| `verify-gate.sh` | `Stop` | — | Runs `./.claude/verify.sh` (if present) before letting the session end. Exit non-zero forces the agent to keep working until the gate passes. |

These run regardless of `--dangerously-skip-permissions`. That is the contract: documentation is a suggestion, exit-code-2 is not.

### `.claude/verify.sh.example`

Template for *your* project's Stop gate. Copy to `.claude/verify.sh`, fill in the real commands (lint, typecheck, tests), and `chmod +x` it. The `verify-gate.sh` hook runs whichever it finds.

### `.claude/HARNESS.lock`

Informational lock written by `assemble.sh`:

```
# Assembled by assemble.sh on 2026-05-15T14:00:00Z
# Config: /abs/path/to/harness.config.yml
base
module memory/md-files
module progress-tracking/filesystem
module methodology/tdd
module methodology/spec-driven
```

One layer per line, install order top-to-bottom. Nothing reads it back; the file is for humans and `grep`.

### `.claude/memory/`, `.claude/progress/`, `.claude/audit/`

Module-installed directories that the agent writes into at runtime. The README inside each tells the agent how to use it.

- `memory/` exists when `memory.backend: md-files`.
- `progress/` exists when `progress.backend: filesystem`.
- `audit/` is created lazily by `audit-log.sh` on the first tool call.

---

## What is *not* in the output

- **No source code.** The harness is paradigm-agnostic; it never writes application files.
- **No secrets.** MCP credentials are `${ENV_VAR}` placeholders.
- **No build artefacts.** `_base/.gitignore` keeps your project's outputs out of git.
- **No `*.fragment.json` files.** All fragments are merged and deleted by `assemble.sh`. If you see one, `jq` was missing during assembly — see [`troubleshooting.md`](troubleshooting.md).

---

## Customising the output

The output is yours after assembly. There is no "re-assemble" — you simply edit the files. The intended editing surfaces:

- **Always edit:** `CLAUDE.md` (fill placeholders, keep tight), `.mcp.json` (add servers your project actually uses), `.claude/verify.sh` (project verification commands).
- **Sometimes edit:** `.claude/settings.json` (add deny patterns, tighten allow lists), additional hooks under `.claude/hooks/`.
- **Rarely edit:** the four `_base` hook scripts. If you find yourself disabling one, surface it as an issue — your use case is probably interesting.

To *remove* a module after the fact, follow its `MODULE.md` → **Remove** section. Every module is independently removable: delete its files, delete its CLAUDE.md section, drop its hook entry from `settings.json`.

---

## See also

- [`reference/harness-config.md`](harness-config.md) — what each config key adds to this tree.
- [`reference/assemble-cli.md`](assemble-cli.md) — how the tree is produced.
- [`reference/modules.md`](modules.md) — catalog of every module's contribution.
- [`explanation/non-negotiables.md`](../explanation/non-negotiables.md) — why the four `_base` hooks always ship.
