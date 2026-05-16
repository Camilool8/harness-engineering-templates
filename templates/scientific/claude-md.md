## Scientific computing & research rules

**The manuscript is the harness target.** The deliverable is a reproducible
document — code runs in a pinned environment and renders to LaTeX / Typst /
HTML (Quarto is the substrate). Work toward "regenerate the whole paper from
source", not toward loose scripts.

**Reproducibility is the deliverable.** Anyone must be able to recreate every
number and figure. That means:
- A pinned environment — `uv`/`pixi` lockfile, Nix, or Julia
  `Project.toml`+`Manifest.toml`. Commit the lockfile.
- Every RNG seeded (numpy / torch / jax / R `set.seed`) and `PYTHONHASHSEED`
  exported. The `seed-check` hook flags unseeded RNG use.
- Input datasets content-hashed; the pipeline fails loud on a hash mismatch.
- The analysis expressed as a Snakemake / Nextflow DAG, not hand-run scripts.
See the `ensuring-reproducible-research` skill.

**Every figure regenerable from source.** No pasted images, no hand-typed
numbers. If it cannot be regenerated from code, it does not go in the
manuscript.

**Judgment calls go through evals.** Model choice, outlier handling, and any
LLM-graded extraction are decided against the golden eval set in `evals/`, not
ad hoc — so the reasoning is reproducible alongside the results.
