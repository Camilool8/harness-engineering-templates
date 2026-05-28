# Module: mobile/addon/eas-build

> Config: `domain.addons` · Depends on: Expo SDK, `eas-cli`, Expo paid plan.

**What it does.** Drops an `eas.json` template with `development` / `preview` / `production` profiles, contributes the `eas-release-coordinator` agent, and documents OTA-vs-binary decision rules in `claude-md.md`.

## Adopt if
- React Native + Expo project shipping via EAS.

## Skip if
- Bare React Native shop using fastlane directly; native-only shop.

## Dependencies
- `eas-cli`: `npm i -g eas-cli` or `npx eas-cli`.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Copy `files/eas.json` to project root.
3. Copy `eas-release-coordinator.md` into `.claude/agents/`.

## Install (assemble.sh)
Add `eas-build` to `domain.addons` and run `./assemble.sh`.

## Remove
- Delete `eas.json`.
- Delete `.claude/agents/eas-release-coordinator.md`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/eas.json`
- `files/.claude/agents/eas-release-coordinator.md`
