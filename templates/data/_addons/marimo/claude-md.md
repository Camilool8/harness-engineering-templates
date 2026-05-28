## marimo (reactive .py notebooks)

- **marimo notebooks are `.py` files.** Edit the file directly; never
  raw `NotebookEdit` on `.ipynb`.
- **Reactive dependency graph.** When a cell changes, marimo
  automatically re-runs downstream cells in the right order. The
  Restart-and-Run-All gate is `marimo export script <notebook>.py`
  followed by `python <export>.py` — clean process, no hidden state.
- **`marimo pair` (April 2026)** is the agent-pair-on-notebook surface.
  The agent edits cells in the file; the human observes in the browser.
  Use the `marimo-pair-mode` skill.
- **DataFrames in cells** are visualized inline via marimo's table
  widget — no extra `display()` call needed.
- **Git-diffable.** Pure `.py` means every change is reviewable.
