# Module: mobile/addon/play-data-safety

> Config: `domain.addons` · Depends on: Google Play Console access.

**What it does.** Drops a `play-data-safety.md` template + checklist and contributes the `data-safety-author` agent that walks the developer through the Play Console "Data safety" form: encryption-in-transit attestation, deletion-request URL, account-deletion paths, generative-AI labeling.

## Adopt if
- Shipping any Android app (native-android, react-native-expo, flutter-app Android target).

## Skip if
- Pure-iOS project.

## Dependencies
- Google Play Console developer account.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Copy `files/play-data-safety.md` to project root.
3. Copy `data-safety-author.md` into `.claude/agents/`.

## Install (assemble.sh)
Add `play-data-safety` to `domain.addons` and run `./assemble.sh`.

## Remove
- Delete `play-data-safety.md`.
- Delete `.claude/agents/data-safety-author.md`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/play-data-safety.md`
- `files/.claude/agents/data-safety-author.md`
