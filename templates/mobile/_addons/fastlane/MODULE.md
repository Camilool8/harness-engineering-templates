# Module: mobile/addon/fastlane

> Config: `domain.addons` · Depends on: Ruby, `fastlane` gem, App Store Connect / Play Console accounts.

**What it does.** Drops `Fastfile`, `Appfile`, `Matchfile` templates and contributes the `fastlane-lane-author` skill. Covers signing (`match`), screenshots (`snapshot` / `screengrab`), App Store upload (`deliver`), Play upload (`supply`).

## Adopt if
- Native iOS / native Android shop without EAS.
- Flutter shop shipping outside EAS.

## Skip if
- React Native + Expo using EAS for everything.

## Dependencies
- Ruby ≥ 3.1.
- `fastlane`: `bundle install` with `Gemfile` containing `gem "fastlane"`.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Copy `files/fastlane/` to `fastlane/` in project root.
3. Copy `fastlane-lane-author/SKILL.md` into `.claude/skills/`.

## Install (assemble.sh)
Add `fastlane` to `domain.addons` and run `./assemble.sh`.

## Remove
- Delete `fastlane/` directory.
- Delete `.claude/skills/fastlane-lane-author/`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/fastlane/Fastfile`
- `files/fastlane/Appfile`
- `files/fastlane/Matchfile`
- `files/.claude/skills/fastlane-lane-author/SKILL.md`
