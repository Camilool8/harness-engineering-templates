---
name: verifying-in-engine
description: Verify gameplay, spatial, animation, and shader changes by booting the engine and capturing a screenshot — use after any change a text log cannot prove correct.
---

# Verifying in-engine

Text logs prove a build compiled. They do not prove a character is on screen,
an animation blends, a shader renders, or a collider is the right size. For any
spatial / visual / timing change, run the hot-reload + screenshot loop.

## The loop

1. **Build / hot-reload.** Compile the change. Prefer the engine's hot-reload
   path (Unity domain reload, Godot scene reload, Unreal Live Coding, Bevy
   `cargo watch`) so iteration stays fast.
2. **Boot the editor and enter play mode.** Drive it headlessly or scripted:
   - Unity: `-batchmode -runTests` or an editor MCP play-mode call.
   - Godot: `godot --path . scene.tscn` (Godot MCP can launch + capture).
   - Unreal: `-game` / editor scripting to PIE.
   - Bevy: run the binary; use a screenshot system on a timer.
3. **Capture a screenshot** of the relevant frame(s). For animation/timing,
   capture a short sequence, not one frame.
4. **Inspect the image.** Compare against the spec / expected layout. Read it
   like a reviewer: position, scale, color, z-order, visible artifacts.
5. **Iterate** until the screenshot matches intent — then report with the image.

## Rules

- Never claim a visual change is "done" on a green build alone.
- Animation, shader, VFX, UI layout, camera, collider, and lighting work
  ALWAYS require a captured frame.
- Deterministic logic (math, ECS systems, save/load) is verified by unit
  tests instead — that is the TDD surface.
- Keep screenshots out of the asset pipeline (a scratch dir), so they never
  pollute the project's source-control diff.
