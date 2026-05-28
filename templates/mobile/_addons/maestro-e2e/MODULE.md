# Module: mobile/addon/maestro-e2e

> Config: `domain.addons` · Depends on: Maestro CLI.

**What it does.** Installs the Maestro CLI install hook, scaffolds a `.maestro/` directory with example flows, and contributes the `maestro-flow-author` skill. Works across native-ios, native-android, react-native-expo, flutter-app.

## Adopt if
- Cross-platform E2E testing in scope.
- Want LLM-writable YAML flows.

## Skip if
- Single-platform native shop with deep XCUITest / Espresso investment that you do not want to replace.

## Dependencies
- Maestro CLI: `curl -Ls "https://get.maestro.mobile.dev" | bash`.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Copy `maestro-flow-author/SKILL.md` into `.claude/skills/`.
3. Create `.maestro/` directory.

## Install (assemble.sh)
Add `maestro-e2e` to `domain.addons` and run `./assemble.sh`.

## Remove
- Remove the `## Maestro E2E` section from `CLAUDE.md`.
- Delete `.claude/skills/maestro-flow-author/`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/.claude/skills/maestro-flow-author/SKILL.md`
