---
name: model-version-pin
description: Every LLM call goes through a single pinned model-ID env var. Pin bumps require typed-token confirmation.
---

## When to use

When starting an LLM app, when bumping a pin, or any time you see a
hard-coded model-ID string in the codebase.

## How

### Pin via env var

```python
import os
from anthropic import Anthropic

MODEL_ID = os.environ["LLM_MODEL_ID"]  # fail loud if missing
client = Anthropic()
response = client.messages.create(model=MODEL_ID, ...)
```

The env var name is project-specific (`LLM_MODEL_ID`,
`PRODUCTION_MODEL_ID`, etc.) but uniform within the codebase.

### Pin to dated snapshots

Pin to dated snapshots, not floating aliases:

- ✅ `claude-opus-4-7-2026-04-15`
- ✅ `gpt-5-2026-03-10`
- ❌ `claude-opus-4-7`  (latest — drifts under you)
- ❌ `gpt-5`             (latest)

### Bump

Bumping `LLM_MODEL_ID` is a production-affecting change. The two-key
gate in `harness.config.yml` (`safety.two_key: true`) requires
typed-token confirmation. The `prompt-implementer` agent refuses to
bump the pin AND edit a prompt in the same diff.

The pin-bump PR also re-runs the full prompt-regression suite (the
`prompt-regression-suite` skill above) — a new model is treated like a
new prompt for eval purposes.

## Anti-patterns this skill prevents

- Hard-coded model IDs scattered across 20 files — one source of truth
  is the env var.
- Pinning to `latest` and pretending you have a pinned model.
- Bumping the pin "to see if it improves" without running the regression.
