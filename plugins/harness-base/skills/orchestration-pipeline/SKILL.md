---
name: orchestrating-a-pipeline
description: Runs work through a fixed sequential four-stage DAG (spec-writer to architect-reviewer to implementer to tester) with a gate between stages. Use when the steps are knowable and identical every time and the value is the gating between them, not parallelism.
---

# Orchestration — pipeline

Work flows through a **fixed sequential DAG** of four stages. You drive the
pipeline; each stage is a sub-agent that consumes the previous stage's typed
output and produces its own. The agents ship with this plugin: `spec-writer`,
`architect-reviewer`, `implementer`, `tester`.

```
spec-writer ──▶ architect-reviewer ──▶ implementer ──▶ tester
   spec            gate: approved?        diff          gate: pass?
```

## Stages and hand-offs

1. `spec-writer` takes the goal, returns a typed `spec` (acceptance criteria,
   constraints, file scope).
2. `architect-reviewer` takes the `spec`, returns `{approved, findings}`.
   **Gate:** if `approved: false`, return the findings to `spec-writer`. Code
   is never written against an unapproved spec.
3. `implementer` takes the approved `spec`, returns a typed `diff`.
4. `tester` takes the `diff` and `spec`, runs verification, returns
   `{pass, report}`. **Gate:** if `pass: false`, return the report to
   `implementer`.

## Rules

- A stage starts only when the prior stage's gate is satisfied. Never run stages
  out of order or in parallel — this is a sequential pipeline by design.
- Every hand-off is a typed JSON object, never free-form prose. The typed output
  of stage N is the only input to stage N+1.
- The pipeline is fixed. If the work needs parallel fan-out, this is the wrong
  topology — use `orchestrating-with-workers` instead.
