# .claude/skills/

Project skills land here — one folder per skill, each with a `SKILL.md`.

`_base` ships **no** skills on purpose. Skills come from three places:

1. **Modules** — picking a module in `harness.config.yml` drops its skills here
   (e.g. `methodology/tdd` adds a TDD skill).
2. **Domain recipes** — `<domain>/` recipes add domain-specific skills.
3. **The Superpowers plugin** — `brainstorming`, `writing-plans`,
   `test-driven-development`, `verification-before-completion`,
   `requesting-code-review` etc. Install it rather than re-authoring the loop:
   it is the canonical Brainstorm → Plan → TDD → Verify → Review → Ship harness.

Authoring norms: gerund-form names (`creating-x`, not `x-helper`), description =
"what + when", keep `SKILL.md` small, push reference data into linked files.
Keep **≤8–12 skills** in active rotation — past that, marginal value drops.
