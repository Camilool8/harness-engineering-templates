## Game development rules

**Engine.** This project targets <Unity | Godot | Unreal | Bevy> — pick one and
state the version. Stay on its idioms (Unity C# / GDScript / Unreal C++ &
Blueprint / Bevy Rust ECS). Do not introduce a second scripting language or a
parallel build system.

**Never break the asset pipeline.** `.meta`, `.uasset`, `.umap`, `.import` and
`uid://` lines carry GUIDs that bind every asset reference. Do not hand-edit
them — let the engine regenerate them. A rewritten GUID silently orphans
references and produces an unreviewable source-control diff. The
`asset-guid-guard` hook enforces this.

**Visual verification is required.** A green build is not "done" for anything
spatial, animated, shader-based, or UI. Boot the engine, enter play mode,
capture a screenshot, and inspect it — see the `verifying-in-engine` skill.
Text logs are insufficient evidence for visual work.

**Deterministic logic is the TDD surface.** Simulation math, ECS systems,
save/load, and pure game logic get unit tests. Visual work does not — it gets
the screenshot loop instead.
