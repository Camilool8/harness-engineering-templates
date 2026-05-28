---
name: fastlane-lane-author
description: Author Fastlane lanes — signing, screenshots, store upload. Enforces two-key on release lanes.
---

# Authoring a Fastlane lane

## Inputs

- The lane's purpose (`beta`, `release`, `screenshots`, `internal`, `production`).
- The platform (`ios` or `android`).
- The signing strategy (`match` for iOS; Play JSON key for Android).

## Process

1. Drop the lane into `Fastfile` under the right `platform(:ios)` / `platform(:android)` block.
2. Reference credentials via env vars; never inline secrets.
3. For store-upload lanes (`release`, `production`), guard with `before_all` that checks `ENV["TWO_KEY_TOKEN"]`.
4. Test locally via `bundle exec fastlane ios beta` (or equivalent) on a Mac with the right toolchain.

## Constraints
- Never check in `.p8`, `.p12`, or service account JSON.
- Never check in `match` repo credentials with a token wider than the one repo.
- Document the lane in `fastlane/README.md`.

Reference: <https://docs.fastlane.tools/>.
