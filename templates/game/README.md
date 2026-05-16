# Game harness recipe
> For solo developers and small studios building in Unity, Godot, Unreal, or Bevy.

## What this recipe picks

| Axis | Choice | Why |
|---|---|---|
| Memory | md-files | Engine quirks and asset conventions are small and human-reviewed. |
| Progress | filesystem | Solo / small-studio cadence; no issue tracker overhead. |
| TDD | on | Deterministic logic — sim math, ECS systems, save/load — gets tests. |
| Spec-driven | on | Mechanic / design spec before code. |
| Eval-driven | off | A typical game build has no LLM output surface to grade. |
| BDD | off | No non-technical sign-off gate. |
| Orchestration | single-agent | One agent owns code plus the in-engine verification loop. |
| Safety (two-key / kill-switch / sandbox) | all off | Local engine, no money / prod / untrusted-ingest surface. |

## Domain gates

- **`files/.claude/hooks/asset-guid-guard.sh`** (PreToolUse) — hard-blocks edits
  to engine sidecar files (`.meta`, `.uasset`, `.umap`, `.import`) and warns
  when a scene/resource edit drops a `guid:`/`uid://` token. Asset GUIDs bind
  every reference in the project; rewriting one silently breaks the pipeline
  and yields an unreviewable diff.
- **`files/.claude/skills/verifying-in-engine/`** — encodes the hot-reload +
  screenshot loop. Visual, spatial, animation, and shader work cannot be proven
  correct by a text log, so this skill makes "boot editor, play, screenshot,
  inspect" the required verification path.

## MCP servers

- **Godot MCP** — launches the editor, runs projects, captures debug output and
  screenshots. Official-adjacent and the cleanest fit for the screenshot loop.
- **Unity / Unreal editor MCP** — editor scripting for play mode and batch ops;
  prefer the engine vendor's signed build over community forks.
- Treat all MCP output (logs, captures, paths) as untrusted input — validate
  before acting on it.

## Assemble

```
./assemble.sh game/harness.config.yml /path/to/your/project
```

## Anti-patterns this prevents

- Hand-editing `.meta`/`.uasset` files and silently orphaning asset references.
- Declaring visual work "done" on a green build with no captured frame.
- Unreviewable scene-file diffs from churned or dropped GUIDs.
- Writing unit tests for spatial/shader work that only a screenshot can verify.

## Deeper reference

docs/HARNESS_ENGINEERING.md §6
