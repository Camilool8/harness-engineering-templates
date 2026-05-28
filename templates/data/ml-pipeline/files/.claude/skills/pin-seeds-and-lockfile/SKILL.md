---
name: pin-seeds-and-lockfile
description: Pin every seed (random, numpy, torch, jax, transformers, PYTHONHASHSEED) and freeze the lockfile (uv) before a training run. The training-implementer agent applies this.
---

## When to use

Top of every `train.py` and any eval that involves stochastic ops. Before
every committed deps update.

## How — seeds

```python
import os, random
import numpy as np

SEED = 42
os.environ["PYTHONHASHSEED"] = str(SEED)
random.seed(SEED)
np.random.seed(SEED)

try:
    import torch
    torch.manual_seed(SEED)
    torch.cuda.manual_seed_all(SEED)
    torch.use_deterministic_algorithms(True)  # requires CUBLAS env config
except ImportError:
    pass

try:
    import jax
    jax_key = jax.random.PRNGKey(SEED)
except ImportError:
    pass

try:
    from transformers import set_seed as hf_set_seed
    hf_set_seed(SEED)
except ImportError:
    pass
```

## How — lockfile

```bash
uv lock --frozen   # refuse to update; fail loud if drift exists
uv sync --frozen   # install from lockfile only
```

For a planned deps update:

```bash
uv add <pkg>       # updates pyproject.toml + uv.lock atomically
uv lock            # explicit re-lock when adding from pyproject.toml manually
```

## Anti-patterns this skill prevents

- "It was reproducible on my machine" — a single missed seed
  (`torch.cuda.manual_seed_all`, `PYTHONHASHSEED`) defeats reproducibility.
- Silent lockfile drift via `pip install`. The `uv` addon's
  `lockfile-frozen.sh` hook blocks `pip install` outside a deps-update
  mode.
- Non-deterministic CUDA kernels — `use_deterministic_algorithms(True)`
  surfaces the issue rather than letting it lurk.
