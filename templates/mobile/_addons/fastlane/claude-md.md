## Fastlane

### Lanes (in `Fastfile`)
- `ios beta` → build + upload to TestFlight (internal group).
- `ios release` → build + upload to App Store, await review.
- `android internal` → build AAB + upload to Play Internal Testing.
- `android production` → build AAB + upload to Play Production track.
- `ios screenshots` → `snapshot` with `Snapfile`.
- `android screenshots` → `screengrab` with `Screengrabfile`.

### Credentials
- **iOS signing**: `match` with App Store Connect API key (`.p8`) stored in `~/.appstoreconnect/`, NOT in env.
- **Play upload**: Google Play service account JSON, path referenced via `--json_key`; service account scoped to the one app.
- **Match git auth**: PAT scoped to the one private match repo, not a global PAT.

### Two-key gating
`ios release` and `android production` lanes refuse to run without `safety.two_key=true` (or a typed token). Encoded in the Fastfile template.
