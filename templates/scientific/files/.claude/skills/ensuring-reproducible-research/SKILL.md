---
name: ensuring-reproducible-research
description: Make a research project reproducible end to end — use when setting up the environment, wiring the analysis pipeline, handling input data, or building the manuscript.
---

# Ensuring reproducible research

Reproducibility is the deliverable, not a nice-to-have. Another researcher
must regenerate every number and figure from source. Build for that from the
start.

## Pinned environment

- Pin the toolchain, not just top-level packages. Use **uv** (lockfile) or
  **pixi** for Python; **Nix** for a fully declarative environment;
  `Project.toml` + `Manifest.toml` for Julia; `renv` for R.
- Commit the lockfile. The environment must recreate byte-for-byte on another
  machine.

## Deterministic computation

- Pin every RNG seed (numpy, torch, jax, R `set.seed`) and export
  `PYTHONHASHSEED`. The `seed-check` hook flags unseeded RNG use.
- Record library and CUDA versions that affect numerical output.

## Workflow engine

- Express the analysis as a DAG in **Snakemake** or **Nextflow**, not a pile
  of scripts run by hand. The engine makes the pipeline re-runnable and
  resumable, and parses failures cleanly.

## Content-hashed inputs

- Hash every input dataset (e.g. SHA256) and record the hash. The pipeline
  should fail loudly if an input's hash changes — silent data drift invalidates
  every downstream result.

## Manuscript substrate

- Write the manuscript in **Quarto** (or Typst/LaTeX). It executes Python, R,
  Julia, Observable inline and renders to PDF/HTML.
- Every figure and table is generated from code in the document or pipeline —
  no pasted images, no hand-typed numbers. If you cannot regenerate it from
  source, it does not ship.
