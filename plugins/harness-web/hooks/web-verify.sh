#!/usr/bin/env bash
# web-verify.sh — PostToolUse hook on Write|Edit|MultiEdit.
# Runs lint + typecheck on the file the agent just changed, so a broken edit
# is caught immediately instead of at the Stop gate. PostToolUse: a non-zero
# exit surfaces the output to the agent as feedback (it does not block).
#
# Detects the package manager from the lockfile; no-ops cleanly if the project
# is not a JS/TS project or has no lint/typecheck script.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)"
[ -z "$path" ] && exit 0

# Only act on web source files.
case "$path" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.vue|*.svelte|*.astro) ;;
  *) exit 0 ;;
esac

# Pick the package manager from whatever lockfile is present.
if   [ -f pnpm-lock.yaml ]; then PM="pnpm";        X="pnpm exec"
elif [ -f yarn.lock ];      then PM="yarn";        X="yarn"
elif [ -f bun.lockb ];      then PM="bun";         X="bunx"
elif [ -f package-lock.json ]; then PM="npm";      X="npx"
else exit 0
fi

have_script() { jq -e --arg s "$1" '.scripts[$s] // empty' package.json >/dev/null 2>&1; }

status=0

# Lint just the changed file when the project exposes a lint script.
if have_script lint; then
  if ! "$X" eslint "$path" 2>&1; then
    echo "web-verify: lint failed on $path — fix before continuing." >&2
    status=1
  fi
fi

# Typecheck is whole-project (tsc has no reliable single-file mode).
if have_script typecheck; then
  if ! "$PM" run typecheck 2>&1; then
    echo "web-verify: typecheck failed — fix before continuing." >&2
    status=1
  fi
elif [ -f tsconfig.json ]; then
  if ! "$X" tsc --noEmit 2>&1; then
    echo "web-verify: tsc --noEmit failed — fix before continuing." >&2
    status=1
  fi
fi

exit $status
