# Reference: recommended permissions

The assembled harness does not ship a `permissions` block in `.claude/settings.json`. Permissions are intentionally yours to set — every project's threat model differs, every team's tolerance for prompt fatigue differs, and Claude Code's defaults are the right starting point for most users.

The hooks `_base` ships (`secret-scan`, `command-guard`, `audit-log`, `verify-gate`) are the *runtime* enforcement contract. They block destructive shell, secret writes, and unverified completion regardless of what's in `permissions`. The permission block below is *defence-in-depth* — it stops bad calls from reaching the hook layer in the first place, and it gives you the `ask`-mode prompt for non-trivial tool use.

---

## The block

If you want the opinionated starting point this repo previously shipped by default, paste this into your project's `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": ["Read", "Grep", "Glob"],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Bash(rm -rf /*)"
    ],
    "defaultMode": "ask"
  }
}
```

If `settings.json` already exists with hooks or other keys, deep-merge — do not overwrite.

---

## What each piece does

| Rule | Effect |
|---|---|
| `allow: [Read, Grep, Glob]` | Pre-approves read-only filesystem tools. Claude does not have to prompt for every file lookup. |
| `deny: [Read(./.env), Read(./.env.*), Read(./secrets/**)]` | Static deny on common secret-file paths. The `secret-scan.sh` hook catches *writes* of secrets; this catches *reads*. |
| `deny: [Bash(rm -rf /*)]` | Static deny on the canonical destructive shell pattern. The `command-guard.sh` hook is the primary defence; this is the belt-and-braces layer. |
| `defaultMode: "ask"` | Non-allowlisted tools prompt before running. The alternative (`auto`) skips prompts; the alternative (`deny`) blocks everything not pre-approved. `ask` is the default-safe choice. |

---

## When to adapt it

| Situation | Change |
|---|---|
| Your secrets live somewhere other than `./.env*` and `./secrets/` | Add more `Read(...)` deny rules for the actual paths. |
| You routinely run `Bash(npm test)` or `Bash(pytest)` | Add them to `allow` to skip the ask prompt. |
| You want stricter — every tool prompts | `defaultMode: "deny"`, then allowlist explicitly. |
| You want looser — power-user flow | `defaultMode: "auto"`, rely on the hooks alone. Not recommended unless you understand what `_base` does and does not block. |

---

## Where these rules sit

The four scopes Claude Code reads, in precedence order (highest wins for the same key; rules in `permissions` *merge* across scopes):

1. Managed (`managed-settings.json`) — admin-deployed, immutable to the user.
2. Local (`.claude/settings.local.json`) — your machine only, gitignored.
3. Project (`.claude/settings.json`) — shared with collaborators, committed.
4. User (`~/.claude/settings.json`) — your defaults across every project.

For a team-shared policy, put the block in project settings (`.claude/settings.json`). For per-machine tweaks, use local. For org-wide enforcement, the admin sets managed.

---

## See also

- [`explanation/non-negotiables.md`](../explanation/non-negotiables.md) — why the four hooks are the contract, not the prompt.
- [`reference/assembled-output.md`](assembled-output.md) — what `_base` actually drops into your project.
- Claude Code's own [permissions reference](https://code.claude.com/docs/en/iam) — the authoritative spec for what `allow`, `deny`, `ask`, `defaultMode`, and `additionalDirectories` accept.
