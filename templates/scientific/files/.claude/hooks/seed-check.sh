#!/usr/bin/env bash
# PreToolUse hook — matcher: Edit|Write|MultiEdit
# Reproducibility gate. Flags Python/R analysis code that touches a random
# number generator without a pinned seed. Advisory (warn, exit 0) — an
# unseeded RNG is sometimes intentional, but it should never be silent.
set -euo pipefail

input="$(cat)"
path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
[ -z "$path" ] && exit 0

case "$path" in
  *.py|*.R|*.r|*.ipynb|*.qmd|*.Rmd) ;;
  *) exit 0 ;;
esac

body="$(printf '%s' "$input" | jq -r '
  (.tool_input.content // empty),
  (.tool_input.new_string // empty)
' 2>/dev/null || true)"
[ -z "$body" ] && exit 0

# Does the new code use an RNG?
uses_rng='np\.random|numpy\.random|random\.|torch\.(rand|randn|randint|manual_seed)'
uses_rng="$uses_rng|jax\.random|rng\.|set\.seed|sample\(|runif\(|rnorm\("
printf '%s' "$body" | grep -Eq "$uses_rng" || exit 0

# Is a seed pinned anywhere in the new code?
has_seed='seed=|seed *=|manual_seed|set\.seed|default_rng\(|PYTHONHASHSEED'
has_seed="$has_seed|np\.random\.seed|random\.seed|PRNGKey"
if printf '%s' "$body" | grep -Eq "$has_seed"; then
  exit 0
fi

echo "WARNING: '$path' uses a random number generator with no pinned seed." >&2
echo "Reproducibility is the deliverable here — pin it:" >&2
echo "  Python: np.random.default_rng(SEED) / torch.manual_seed(SEED)" >&2
echo "  JAX:    jax.random.PRNGKey(SEED)" >&2
echo "  R:      set.seed(SEED)" >&2
echo "  Process: also export PYTHONHASHSEED for hash-order determinism." >&2
exit 0
