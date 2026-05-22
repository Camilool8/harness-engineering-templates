## EAS Build / Submit / Update

### Profiles (in `eas.json`)
- `development` — dev client; internal distribution; for live-reload + native debugging.
- `preview` — internal QA build; internal distribution; tester groups can install via QR.
- `production` — store-bound build; store distribution; binary or OTA via EAS Update.

### OTA vs binary decision
Run `npx expo prebuild --check` before deciding:
- Diff empty → `eas update --branch production` (OTA, no review needed).
- Diff non-empty → `eas build --profile production` then `eas submit --profile production` (requires App Store / Play Store review).

### Two-key gating
The `eas-release-coordinator` agent refuses `eas submit` without `safety.two_key=true` or a typed token in autonomous loops.
