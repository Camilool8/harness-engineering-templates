---
name: requiring-two-key-confirmation
description: Gate irreversible actions (production deploys, data deletion, moving money, flashing firmware) behind a human-held confirmation token the agent cannot self-issue. Use when work can reach destructive or production operations; arm with two_key = true in .claude/HARNESS.toml.
---

# Safety — two-key confirmation

Irreversible actions — production deploys, data deletion, moving money, flashing
firmware — are gated by a **two-key** rule. You hold one key (you propose the
action). A human holds the second key (a secret token). You cannot turn one key
twice.

## Arming the gate

Add this to `.claude/HARNESS.toml` (create the file if needed):

```toml
[harness]
two_key = true
```

Then provision the second key out-of-band — either set `HARNESS_TWO_KEY_TOKEN`
in the environment, or write a nonce to `.claude/.two-key-nonce`. The
`two-key-confirm.sh` PreToolUse hook is inert until both the flag is set and a
destructive command is attempted.

## The flow

1. You run a command that matches a destructive/prod pattern. The hook blocks it
   and prints the exact confirmation phrase required.
2. You **stop and ask the human** for the confirmation token. You must not
   guess, generate, or invent the token — it is a nonce held outside your
   context, and you cannot read it as a shortcut to self-approve.
3. The human supplies the token. You re-issue the **same** command with
   `CONFIRM <token>` appended. The hook validates the token and allows it.

## Rules

- A single "yes" or one click is never sufficient. The typed token is the
  contract.
- One token authorizes one action. Do not reuse a token to skip confirmation on
  a later destructive command.
- If you find yourself wanting to read or write the nonce file to move faster,
  stop — that defeats the gate. Ask the human instead.
