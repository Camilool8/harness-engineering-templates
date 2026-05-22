# Module: mobile/addon/privacy-manifest-ios

> Config: `domain.addons` · Depends on: an Xcode iOS target.

**What it does.** Drops a starter `PrivacyInfo.xcprivacy` with Required Reason API entries, ATT scaffolding, and tracking-domain placeholders. Contributes the `privacy-manifest-author` agent that walks the developer through filling it in.

## Adopt if
- Shipping any iOS app (native-ios, react-native-expo, flutter-app iOS target).

## Skip if
- Pure-Android project.

## Dependencies
- Xcode 26+.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Copy `files/PrivacyInfo.xcprivacy` to your iOS app target's root.
3. Copy `privacy-manifest-author.md` into `.claude/agents/`.

## Install (assemble.sh)
Add `privacy-manifest-ios` to `domain.addons` and run `./assemble.sh`.

## Remove
- Delete `PrivacyInfo.xcprivacy`.
- Delete `.claude/agents/privacy-manifest-author.md`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/PrivacyInfo.xcprivacy`
- `files/.claude/agents/privacy-manifest-author.md`
