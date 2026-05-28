# Module: mobile/addon/patrol-flutter

> Config: `domain.addons` · Depends on: Flutter SDK, `patrol_cli`.

**What it does.** Adds `patrol` + `patrol_finders` to `pubspec.yaml`, scaffolds an `integration_test/` directory with `patrolTest` examples, and contributes the `patrol-flow-author` skill. Flutter-specific E2E with native automation (UIAutomator + XCUITest).

## Adopt if
- Flutter app with integration tests that need native permission dialogs, notifications, Settings, Wi-Fi/Bluetooth.

## Skip if
- Cross-platform shop using Maestro for everything.

## Dependencies
- `patrol_cli`: `dart pub global activate patrol_cli`.
- `patrol`, `patrol_finders` in `dev_dependencies`.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Add `patrol` to `dev_dependencies`.
3. Copy `patrol-flow-author/SKILL.md` into `.claude/skills/`.

## Install (assemble.sh)
Add `patrol-flutter` to `domain.addons` and run `./assemble.sh`.

## Remove
- Remove the `## Patrol` section from `CLAUDE.md`.
- Delete `.claude/skills/patrol-flow-author/`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/.claude/skills/patrol-flow-author/SKILL.md`
