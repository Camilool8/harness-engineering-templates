## Spec-Driven Development

Non-trivial work starts with a spec, not with code.

- **Write the spec first.** Copy `specs/TEMPLATE.md` to `specs/<slug>.md` and
  fill it: problem, acceptance criteria, out-of-scope, verification. The agent
  reading a precise spec is constrained against drift; the agent reading a vague
  request will hallucinate scope.
- **Plan Mode before editing.** Once the spec exists, enter Plan Mode to
  research and produce an implementation plan. No file edits until the plan is
  approved.
- **The spec is a living contract, not a Gantt chart.** When reality contradicts
  it, update the spec in the same change and note what moved — do not silently
  diverge. A spec without acceptance criteria is just prose; always state how
  we will know it is done.
- **Skip the spec only when the diff fits in one sentence** (a typo, a config
  bump). When in doubt, write one.

See the `writing-specs` skill for how to turn an ambiguous request into a spec.
