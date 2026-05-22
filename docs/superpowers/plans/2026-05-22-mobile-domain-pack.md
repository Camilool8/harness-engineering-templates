# Mobile Domain Pack — Phase B Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Graduate `templates/mobile/` from a v1 thin recipe to a curated three-layer pack with four sub-domains (native-ios, native-android, react-native-expo, flutter-app), ten addons, three shared agents, two shared hooks, and one promoted shared skill. Spec: `docs/superpowers/specs/2026-05-22-mobile-domain-pack-design.md`.

**Architecture:** Mirror the data cycle (cycle 1) exactly. Shared layer (DOMAIN.md, domain.claude-md.md, hooks, agents, skills, references) → four sub-domain trees → ten addons grouped by category → test runner extension → public-doc flip → thin-recipe retirement.

**Tech Stack:** Bash hooks, Markdown content. No runtime code. The pack ships configuration, prompts, and skills; assemble.sh layers them onto a target.

---

## Conventions used in this plan

- `templates/mobile/` is the root of the new pack.
- All shared-layer files live directly under `templates/mobile/` and `templates/mobile/files/`.
- Sub-domains live at `templates/mobile/<sub-domain>/`.
- Addons live at `templates/mobile/_addons/<addon>/`.
- Each commit is small enough that running `./templates/tests/run.sh` between commits stays under 30 seconds.
- Forward references inside the cycle are accepted (e.g., `DOMAIN.md` links to `references.md` before `references.md` is committed — both resolve by end of cycle). Devops/data precedent.

---

### Task 1: Shared scaffold — `DOMAIN.md`, `domain.claude-md.md`, MCP fragments

**Files:**
- Create: `templates/mobile/DOMAIN.md`
- Create: `templates/mobile/domain.claude-md.md`
- Create: `templates/mobile/files/.mcp.json.fragment`
- Create: `templates/mobile/files/.claude/context7.mcp.json.fragment`

- [ ] **Step 1: Write `templates/mobile/DOMAIN.md`**

````markdown
# Mobile domain pack

Curated harness content for mobile teams: native iOS, native Android,
React Native + Expo, and Flutter.

> **Status: curated three-layer pack** (fourth after `web/`, `devops/`, `data/`).
> Specialised via per-MCP, per-tester, per-build/distribution, and per-compliance
> addons.

## Sub-domain decision guide

Pick by team composition and platform targets, not by framework popularity.

| Sub-domain | Adopt if… |
|---|---|
| [`native-ios`](native-ios/) | Swift/SwiftUI app to the App Store with maximum platform integration (Foundation Models, App Intents); iOS-only or iOS-first team. |
| [`native-android`](native-android/) | Kotlin/Compose app to Google Play with maximum Android integration (Gemini Nano / AICore, foreground services); Android-only or Android-first team. |
| [`react-native-expo`](react-native-expo/) | Cross-platform to iOS + Android with a JS/TS team; deepest AI-tooling MCP coverage; OTA JS updates via EAS Update. |
| [`flutter-app`](flutter-app/) | Pixel-perfect uniform cross-platform UI with heavy custom animation; Dart team or willingness to build one. |

Each sub-domain ships a `SUBDOMAIN.md` with deeper adopt-if / skip-if guidance and the curated agent team.

## Addons

Composable extras declared in `domain.addons`. Each sub-domain config ships sensible defaults; override as needed.

| Addon | Pairs with | Purpose |
|---|---|---|
| `xcodebuild-mcp` | `native-ios`, `react-native-expo`, `flutter-app` | `getsentry/XcodeBuildMCP` + `ios-simulator-mcp`; build, sim, screenshot, log, test. |
| `expo-mcp` | `react-native-expo` | `mcp.expo.dev` hosted OAuth MCP; EAS Build/Submit/Workflow inspection. |
| `firebase-mcp` | `native-android`, `flutter-app`, `react-native-expo` | `firebase-tools mcp`; Auth, Firestore, FCM, Crashlytics (Experimental), Remote Config. |
| `sentry-mcp` | all four | `mcp.sentry.dev` hosted OAuth MCP; issues, breadcrumbs, releases, replays. |
| `maestro-e2e` | `react-native-expo`, `native-ios`, `native-android` | Maestro CLI + flow author skill; cross-platform E2E. |
| `patrol-flutter` | `flutter-app` | LeanCode Patrol; Flutter `integration_test` with native automation. |
| `eas-build` | `react-native-expo` | EAS Build/Submit/Update profiles + release coordinator agent. |
| `fastlane` | `native-ios`, `native-android`, `flutter-app` | Fastfile / Appfile / Matchfile templates; lane author skill. |
| `privacy-manifest-ios` | `native-ios`, `react-native-expo`, `flutter-app` | `PrivacyInfo.xcprivacy` + Required Reason API helpers. |
| `play-data-safety` | `native-android`, `react-native-expo`, `flutter-app` | Google Play "Data safety" form walker agent. |

Each addon ships a `MODULE.md` with adopt-if / skip-if guidance. Browse [`_addons/`](_addons/).

## What we deliberately do not curate (yet)

- **Kotlin Multiplatform / Compose Multiplatform** — reshapes project structure too deeply for v1; reachable from `native-android` + `native-ios` with manual setup. Graduation target.
- **Bitrise MCP** — PAT-only as of May 2026 (post-Anodot posture gap). EAS / Fastlane / GitHub Actions cover the same need with OAuth-first MCPs.
- **MobSF MCP, AppSweep, DexGuard, Detekt, SwiftLint** — invoked via Bash; no OAuth MCP path yet.
- **App Store Connect / Play Console first-party MCP** — no first-party server exists; reach via EAS Submit, fastlane `deliver` / `supply`.
- **Wearables, TV, CarPlay, VisionOS** — out of scope; pick `native-ios` or `native-android` and document the secondary target in `references.md`.

## Assemble

The sub-domain config is the assemble unit. Pass it directly to `assemble.sh`:

```bash
./assemble.sh mobile/native-ios/harness.config.yml ./my-ios-app
./assemble.sh mobile/native-android/harness.config.yml ./my-android-app
./assemble.sh mobile/react-native-expo/harness.config.yml ./my-rn-app
./assemble.sh mobile/flutter-app/harness.config.yml ./my-flutter-app
```

## See also

- [`docs/how-to/pick-a-recipe.md`](../../docs/how-to/pick-a-recipe.md) — decision flow including the mobile sub-domain choice.
- [`docs/reference/domains.md`](../../docs/reference/domains.md) — full domain and addon catalog.
- [`docs/HARNESS_ENGINEERING.md`](../../docs/HARNESS_ENGINEERING.md) §2 — engineering guide for the mobile domain.
- [`references.md`](references.md) — curated mobile-platform dossier (refresh quarterly).
````

- [ ] **Step 2: Write `templates/mobile/domain.claude-md.md` (≤32 lines including trailing newline)**

```markdown
## Mobile rules

### Stack lockdown
- Pick one sub-domain (native-ios, native-android, react-native-expo, flutter-app) and hold to it. Do not mix paradigms (e.g. SwiftUI screens with UIKit view-controller patterns) unless the screen genuinely requires it.

### Verification (simulator/emulator-in-the-loop)
- After any screen change, run the `verifying-on-simulator` skill: boot device, install, screenshot, diff. A UI change is not verified until it has run on a device.
- TDD applies to deterministic code — view models, reducers, networking, formatting. UI verification is the simulator/emulator loop, not a unit test.

### Build logs
- Consume build logs as structured/categorized output, never a 3000-line raw log. iOS: XcodeBuildMCP parses `xcodebuild` to JSON. Android: parse `gradle --console=plain` or use Gemini Agent Mode's structured Logcat readback.

### Store compliance
- Apple Guideline 5.1.2(i) (Nov 13, 2025) requires explicit user consent before personal data is sent to any third-party AI. A privacy-policy link is not enough — implement a pre-action consent UI.
- Google Play AI-Generated Content policy requires in-app reporting/flagging of generative output and labeling of AI-generated content.

### Credentials posture
- Prefer OAuth MCPs (Expo, Firebase, Sentry, GitHub) over PAT/API-key MCPs (Bitrise, MobSF). After the April 2026 Anodot/ShinyHunters breach, long-lived broker-held tokens are the new weakest link.

### Never do
- Never claim a UI change works without running it on a simulator/emulator.
- Never ship an AI-data-sharing feature without the 5.1.2(i) consent UI.
- Never paste App Store Connect API keys, Play service account JSON, EXPO_TOKEN, SENTRY_AUTH_TOKEN, or FIREBASE_TOKEN inline.
```

- [ ] **Step 3: Write `templates/mobile/files/.mcp.json.fragment`**

```json
{ "mcpServers": {} }
```

- [ ] **Step 4: Write `templates/mobile/files/.claude/context7.mcp.json.fragment`**

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

- [ ] **Step 5: Run structure-lint to confirm no new violations**

Run: `./templates/tests/checks/structure-lint.sh`
Expected: PASS with count ≥ 215 (cycle 1 baseline).

- [ ] **Step 6: Commit**

```bash
git add templates/mobile/DOMAIN.md templates/mobile/domain.claude-md.md \
        templates/mobile/files/.mcp.json.fragment \
        templates/mobile/files/.claude/context7.mcp.json.fragment
git commit -m "feat: mobile pack shared scaffold (DOMAIN, claude-md, MCP fragments)"
```

---

### Task 2: Shared references dossier

**Files:**
- Create: `templates/mobile/references.md`

- [ ] **Step 1: Write `templates/mobile/references.md`**

```markdown
# Mobile pack — references dossier

> Verified: 2026-05. Refresh quarterly. Cite the canonical source per item.

## Stack settled in 2026

- React Native 0.84 (Hermes V1 default, precompiled iOS XCFrameworks): <https://reactnative.dev/blog/2026/02/11/react-native-0.84>
- Expo SDK 54 stable + SDK 56 beta: <https://expo.dev/changelog/sdk-54> · <https://expo.dev/changelog/sdk-56-beta>
- Compose Multiplatform 1.11.0 (May 2026): <https://blog.jetbrains.com/kotlin/2026/05/compose-multiplatform-1-11-0/>
- Flutter 2026 roadmap (Impeller-only iOS, decoupling Material): <https://blog.flutter.dev/flutter-darts-2026-roadmap-89378f17ebbd>
- Xcode 26.3 agentic coding (Claude + Codex agents in Xcode, Feb 2026): <https://www.apple.com/newsroom/2026/02/xcode-26-point-3-unlocks-the-power-of-agentic-coding/>
- Android Studio Otter 3 Feature Drop (Jan 2026): <https://android-developers.googleblog.com/2026/01/llm-flexibility-agent-mode-improvements.html>

## Compliance gates

- Apple App Review Guideline 5.1.2(i) — third-party AI disclosure (Nov 2025): <https://developer.apple.com/app-store/review/guidelines/>
- Apple PrivacyInfo.xcprivacy + Required Reason API reference: <https://developer.apple.com/documentation/bundleresources/privacy-manifest-files>
- Google Play AI-Generated Content policy + April 15, 2026 update: <https://support.google.com/googleplay/android-developer/answer/14094294>
- Apple DMA / Core Technology Commission (Jan 1, 2026): <https://developer.apple.com/support/dma-and-apps-in-the-eu/>
- European Accessibility Act (in force Jun 28, 2025): <https://commission.europa.eu/strategy-and-policy/policies/justice-and-fundamental-rights/disability/european-accessibility-act-eaa_en>
- California SB 942 (operative Aug 2, 2026): <https://leginfo.legislature.ca.gov/faces/billTextClient.xhtml?bill_id=202320240SB942>
- Android target SDK 35 → 36 (Aug 31, 2026 deadline): <https://developer.android.com/google/play/requirements/target-sdk>

## MCPs and AI tooling

- Sentry acquires XcodeBuildMCP (Feb 2026): <https://blog.sentry.io/sentry-acquires-xcodebuildmcp/>
- Expo MCP (mcp.expo.dev) OAuth Streamable HTTP: <https://docs.expo.dev/eas/ai/mcp/>
- Firebase MCP Server GA (Oct 2025): <https://firebase.blog/posts/2025/10/firebase-mcp-server-ga/>
- Sentry MCP (mcp.sentry.dev): <https://docs.sentry.io/product/sentry-mcp/>
- Maestro: best mobile testing frameworks 2026: <https://maestro.dev/insights/best-mobile-app-testing-frameworks>

## Deferred / not yet graduated

- Kotlin Multiplatform / Compose Multiplatform sub-domain — v2 target.
- Bitrise MCP — PAT-only; awaiting OAuth.
- MobSF MCP — API-key only; awaiting OAuth.
- App Store Connect / Play Console first-party MCP — none exist as of May 2026.

## Anodot 2026 context

- ShinyHunters → Anodot → Snowflake/BigQuery supply-chain breach (Apr 4–15, 2026): the same broker-token failure mode mandates OAuth-first MCP posture for mobile too. See data pack's references for full citations.
```

- [ ] **Step 2: Commit**

```bash
git add templates/mobile/references.md
git commit -m "docs(mobile): references dossier (verified 2026-05)"
```

---

### Task 3: Two shared hooks + settings.fragment.json wiring

**Files:**
- Create: `templates/mobile/files/.claude/hooks/audit-log-mobile-build.sh`
- Create: `templates/mobile/files/.claude/hooks/block-static-store-creds.sh`
- Create: `templates/mobile/files/.claude/settings.fragment.json`

- [ ] **Step 1: Write `audit-log-mobile-build.sh`**

```bash
#!/usr/bin/env bash
# audit-log-mobile-build.sh — PostToolUse hook.
# Matchers: Bash (mobile build/sim CLIs: xcodebuild, xcrun simctl, xcrun
# devicectl, gradle, gradlew, adb, expo, eas, fastlane, pod, flutter, dart)
# and XcodeBuildMCP / Sentry / Expo / Firebase MCP tools.
#
# Appends one JSON line per invocation to .claude/logs/agent_audit.jsonl.
# The log is the Play Console "evidence of testing" surface and the iOS
# build provenance trail for store-submission audits.
#
# Exit 0 always — this hook records, never blocks.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"

cmd="$(printf '%s' "$event" | jq -r '
  .tool_input.command // .tool_input.cmd // .tool_input.query // empty' 2>/dev/null)"

case "$tool" in
  Bash)
    [ -z "$cmd" ] && exit 0
    printf '%s' "$cmd" | grep -Eq '\b(xcodebuild|xcrun|gradle|gradlew|adb|expo|eas|fastlane|pod|flutter|dart)\b' || exit 0
    ;;
  mcp__XcodeBuildMCP__*|mcp__xcodebuildmcp__*|mcp__expo__*|mcp__firebase__*|mcp__sentry__*) ;;
  *) exit 0 ;;
esac

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
session="${CLAUDE_SESSION_ID:-unknown}"
exit_code="$(printf '%s' "$event" | jq -r '.tool_response.exit_code // .tool_response.code // empty' 2>/dev/null)"

record="$(jq -nc \
  --arg ts "$ts" \
  --arg session "$session" \
  --arg tool "$tool" \
  --arg command "$cmd" \
  --arg exit_code "$exit_code" \
  '{timestamp:$ts, session_id:$session, tool_name:$tool, command:$command,
    exit_code:($exit_code // null)}')"

log_dir="${CLAUDE_PROJECT_DIR}/.claude/logs"
mkdir -p "$log_dir"
printf '%s\n' "$record" >> "$log_dir/agent_audit.jsonl"

exit 0
```

- [ ] **Step 2: Write `block-static-store-creds.sh`**

```bash
#!/usr/bin/env bash
# block-static-store-creds.sh — PreToolUse hook on Bash.
# Refuses to proceed if static store/build credentials are present in env
# when an OAuth alternative exists. Codifies the post-ShinyHunters (April
# 2026) credential-posture default for the mobile domain: agent hosts do
# not hold long-lived App Store Connect / Play / Expo / Sentry tokens.
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
tool="$(printf '%s' "$event" | jq -r '.tool_name // empty' 2>/dev/null)"
[ "$tool" = "Bash" ] || exit 0

cmd="$(printf '%s' "$event" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Only police mobile build/distribution CLIs. Other Bash is fine.
printf '%s' "$cmd" | grep -Eq '\b(xcodebuild|fastlane|eas|expo|gradle|gradlew|adb|flutter|pod)\b' || exit 0

issues=()
[ -n "${APP_STORE_CONNECT_API_KEY_BASE64:-}" ]         && issues+=("APP_STORE_CONNECT_API_KEY_BASE64 set — use App Store Connect API short-lived JWT via fastlane spaceship.")
[ -n "${ASC_API_KEY_ID:-}${ASC_API_KEY_ISSUER_ID:-}" ] && issues+=("ASC_API_KEY_* set — store .p8 outside repo; use fastlane app_store_connect_api_key with key_filepath, not env paste.")
[ -n "${GOOGLE_PLAY_SERVICE_ACCOUNT_JSON:-}" ]         && issues+=("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON set — use GCP Workload Identity Federation to fastlane supply.")
[ -n "${EXPO_TOKEN:-}" ]                               && issues+=("EXPO_TOKEN set — use Expo MCP OAuth (mcp.expo.dev) instead.")
[ -n "${SENTRY_AUTH_TOKEN:-}" ]                        && issues+=("SENTRY_AUTH_TOKEN set — use Sentry MCP OAuth (mcp.sentry.dev) instead.")
[ -n "${FIREBASE_TOKEN:-}" ]                           && issues+=("FIREBASE_TOKEN set — use Firebase CLI interactive OAuth or ADC instead.")
[ -n "${FASTLANE_PASSWORD:-}" ]                        && issues+=("FASTLANE_PASSWORD set — use App Store Connect API key, not Apple ID password.")
[ -n "${MATCH_PASSWORD:-}" ]                           && issues+=("MATCH_PASSWORD set inline — store in Keychain or use match storage_mode=git_basic_authorization with PAT scoped to one repo.")

if [ "${#issues[@]}" -gt 0 ]; then
  echo "BLOCKED: static store/build credentials present in env (post-ShinyHunters 2026 posture)." >&2
  for i in "${issues[@]}"; do echo "  - $i" >&2; done
  echo "Remove the static cred from env; use the OAuth / Managed-MCP path." >&2
  exit 2
fi

exit 0
```

- [ ] **Step 3: Mark hooks executable**

Run: `chmod +x templates/mobile/files/.claude/hooks/*.sh`
Expected: exit 0.

- [ ] **Step 4: Write `templates/mobile/files/.claude/settings.fragment.json`**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-static-store-creds.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash|mcp__XcodeBuildMCP__.*|mcp__xcodebuildmcp__.*|mcp__expo__.*|mcp__firebase__.*|mcp__sentry__.*",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/audit-log-mobile-build.sh" }
        ]
      }
    ]
  }
}
```

- [ ] **Step 5: Run hook-lint + structure-lint**

Run: `./templates/tests/checks/hook-lint.sh && ./templates/tests/checks/structure-lint.sh`
Expected: both PASS; hook-lint count goes up by 2 (104+).

- [ ] **Step 6: Commit**

```bash
git add templates/mobile/files/.claude/hooks/ templates/mobile/files/.claude/settings.fragment.json
git commit -m "feat(mobile): shared hooks (audit-log-mobile-build, block-static-store-creds)"
```

---

### Task 4: Three shared agents

**Files:**
- Create: `templates/mobile/files/.claude/agents/app-store-compliance-auditor.md`
- Create: `templates/mobile/files/.claude/agents/mobile-release-coordinator.md`
- Create: `templates/mobile/files/.claude/agents/mobile-ux-screenshot-critic.md`

- [ ] **Step 1: Write `app-store-compliance-auditor.md`**

```markdown
---
name: app-store-compliance-auditor
description: Audits a mobile project for App Store + Play compliance — 5.1.2(i) AI disclosure, PrivacyInfo.xcprivacy completeness, Required Reason API coverage, Data Safety form alignment, foregroundServiceType declarations, account-deletion paths. Produces a red/amber/green checklist. Read-only; never modifies source.
tools: Read, Glob, Grep
---

You are the App Store + Google Play compliance auditor for a 2026 mobile project. Your job is to read the project tree and produce a checklist of pass/fail items. You never modify source — remediation belongs to implementer agents.

## What you check

### iOS / App Store
1. `PrivacyInfo.xcprivacy` exists at app and SDK bundle roots; parses as XML.
2. `NSPrivacyTracking` flag matches `Info.plist` ATT presence.
3. `NSPrivacyTrackingDomains` non-empty if `NSPrivacyTracking=true`.
4. Required Reason API entries declared with Apple-approved reason codes for every referenced API in source: `UserDefaults` (`CA92.1`), `FileTimestamp`, `SystemBootTime`, `DiskSpace`, `ActiveKeyboards`.
5. ATT prompt code path (`ATTrackingManager.requestTrackingAuthorization`) present if any tracking domain is listed.
6. AI-data-sharing UI: grep for `URLSession`, `fetch(`, known LLM hostnames (`api.openai.com`, `api.anthropic.com`, `generativelanguage.googleapis.com`); if found, expect a `consent` / `disclosure` referenced from the call site.
7. Account-deletion path (Guideline 5.1.1(v)) — search for `delete account` or `deleteAccount` button referenced from settings.
8. DSA Trader status acknowledged in `references.md` or a `compliance-checklist.md`.

### Android / Play
9. Every declared `<service android:foregroundServiceType="…">` in `AndroidManifest.xml` has a matching `play-console-checklist.md` entry.
10. `play-data-safety.md` (or equivalent) has all fields plus deletion-request URL.
11. `POST_NOTIFICATIONS` runtime permission requested on Android 13+ if `notification` references exist.
12. Photo Picker pattern used — search for `READ_MEDIA_VISUAL_USER_SELECTED` or `PickVisualMedia` if any media code path exists; no broad `READ_MEDIA_*` without selected-access variant.
13. Generative-AI labeling + in-app report-flag UI present if any LLM call is referenced.
14. Target SDK ≥ 35 (≥ 36 after Aug 31, 2026).

## Output

A checklist with `[ ]` / `[~]` / `[x]` per item, plus a one-line remediation pointer for each amber/red. Do not write code. Do not modify files.
```

- [ ] **Step 2: Write `mobile-release-coordinator.md`**

```markdown
---
name: mobile-release-coordinator
description: Coordinates a mobile release — version + build number bumps, changelog scaffolding, TestFlight + Internal Testing track choice, store metadata draft, screenshot-set verification. Enforces safety.two_key for store-upload commands.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You are the mobile release coordinator. You walk the developer through the steps of a release without ever taking destructive store actions without explicit consent.

## What you do

1. **Read `harness.config.yml`** to learn `safety.two_key` posture. If `two_key: false`, warn that store-upload commands run autonomously will proceed; recommend turning it on once the release loop is autonomous.
2. **Bump version and build number** in the right file per stack:
   - iOS: `Info.plist` (`CFBundleShortVersionString`, `CFBundleVersion`) or `project.pbxproj` (`MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`).
   - Android: `app/build.gradle.kts` (`versionName`, `versionCode`).
   - Expo: `app.json`/`app.config.ts` (`version`, `ios.buildNumber`, `android.versionCode`).
   - Flutter: `pubspec.yaml` (`version: x.y.z+buildNumber`).
3. **Scaffold a `CHANGELOG.md`** entry from `git log` since the last tag. Group by feat / fix / chore.
4. **Choose distribution track**:
   - TestFlight (iOS) → internal vs external groups; external groups need Beta App Review.
   - Play Internal Testing → Internal vs Closed vs Open testing; Internal skips review.
   - Production → final gate; requires `safety.two_key=true` to upload autonomously.
5. **Verify screenshot set**: each required device size has at least one screenshot per locale.
6. **Refuse to invoke `fastlane deliver`, `fastlane supply`, `eas submit`, or any store-upload command** unless `safety.two_key=true` OR the user has typed the release token. Print the typed-token prompt instead.

## Output

A markdown checklist of the release steps with `[ ]` per step, plus the exact commands the developer (or you, post-token) will run.
```

- [ ] **Step 3: Write `mobile-ux-screenshot-critic.md`**

```markdown
---
name: mobile-ux-screenshot-critic
description: Visual review of mobile simulator/emulator screenshots. Flags accessibility violations (contrast ≥4.5:1, touch targets ≥44pt iOS / ≥48dp Android, Dynamic Type / large-font tolerance), layout regressions vs a baseline, and locale/bidirectional regressions.
tools: Read, Glob, Grep
---

You are a mobile UX critic. The user gives you a directory of simulator/emulator screenshots; you produce a structured critique.

## What you check, per screenshot

1. **Color contrast** — text-on-background ≥ 4.5:1 (WCAG AA) for body text; ≥ 3:1 for large text. Flag specifically.
2. **Touch target size** — interactive controls ≥ 44pt iOS / ≥ 48dp Android. Flag the smallest visible target.
3. **Dynamic Type / large font** — text not truncated/clipped at the largest tested size.
4. **Locale handling** — RTL screenshots mirror layout direction; CJK character rendering looks complete.
5. **Safe area / notch / dynamic island** — no content under system UI.
6. **Empty / loading / error states** — present in the set, not just happy path.
7. **Baseline diff** — if a `baseline/` subdir is provided, flag any large pixel-difference regions.

## What you do not do

- Do not modify code.
- Do not change screenshots.
- Do not approve a release on visual grounds alone (`mobile-release-coordinator` owns the final gate).

## Output

A structured markdown report: per-screenshot findings, then a roll-up "ship / revise / blocked" verdict.
```

- [ ] **Step 4: Run structure-lint to confirm agents parse**

Run: `./templates/tests/checks/structure-lint.sh`
Expected: PASS with count ≥ 218 (cycle 1 baseline + 3 new agents).

- [ ] **Step 5: Commit**

```bash
git add templates/mobile/files/.claude/agents/
git commit -m "feat(mobile): shared agents (compliance-auditor, release-coordinator, screenshot-critic)"
```

---

### Task 5: Promote `verifying-on-simulator` skill to shared layer

**Files:**
- Move: `templates/mobile/files/.claude/skills/verifying-on-simulator/SKILL.md` *(already exists at this path from the v1 thin recipe — verify and keep)*

- [ ] **Step 1: Verify the existing skill is at the right path**

Run: `ls -la templates/mobile/files/.claude/skills/verifying-on-simulator/`
Expected: `SKILL.md` present.

If present, no commit needed for this task — the file is preserved as-is from the thin recipe. Move on to step 2.

If NOT present (defensive — should not happen given the thin-recipe layout):

Read the original file contents from `git show HEAD:templates/mobile/files/.claude/skills/verifying-on-simulator/SKILL.md` and recreate at the same path.

- [ ] **Step 2: Confirm structure-lint sees the skill**

Run: `./templates/tests/checks/structure-lint.sh 2>&1 | grep -i verifying-on-simulator || echo 'skill recognized (no errors)'`
Expected: no errors mentioning the skill.

- [ ] **Step 3: No commit if file is already present**

This task is a checkpoint, not a code change. The shared layer is now complete; sub-domains in Tasks 6–9 will inherit this skill via the same path. Proceed to Task 6.

---

### Task 6: `native-ios` sub-domain

**Files:**
- Create: `templates/mobile/native-ios/SUBDOMAIN.md`
- Create: `templates/mobile/native-ios/harness.config.yml`
- Create: `templates/mobile/native-ios/claude-md.md`
- Create: `templates/mobile/native-ios/references.md`
- Create: `templates/mobile/native-ios/files/.claude/settings.fragment.json`
- Create: `templates/mobile/native-ios/files/.claude/agents/ios-architect.md`
- Create: `templates/mobile/native-ios/files/.claude/agents/swiftui-implementer.md`
- Create: `templates/mobile/native-ios/files/.claude/agents/swift-test-implementer.md`
- Create: `templates/mobile/native-ios/files/.claude/agents/xcode-build-resolver.md`
- Create: `templates/mobile/native-ios/files/.claude/skills/parsing-xcodebuild-errors/SKILL.md`
- Create: `templates/mobile/native-ios/files/.claude/skills/foundation-models-app-intent/SKILL.md`

- [ ] **Step 1: Write `SUBDOMAIN.md`**

```markdown
# Sub-domain: mobile/native-ios

Curated harness for Swift / SwiftUI iOS apps targeting App Store Connect in 2026.

## Adopt if

- You're shipping a Swift app to the App Store with maximum platform integration: Foundation Models, App Intents, Live Activities, Widgets.
- Your team is iOS-only or iOS-first.
- You want first-class Xcode + XcodeBuildMCP integration for AI-assisted dev.

## Skip if

- You need cross-platform Android coverage from the same codebase — pick `react-native-expo` or `flutter-app`.
- You're shipping a web app inside a shell — Capacitor lives outside this pack.

## Addons that pair well

- `xcodebuild-mcp` (default) · XcodeBuildMCP + ios-simulator-mcp for build/sim/screenshot loops.
- `sentry-mcp` (default) · Crash + release triage via OAuth-hosted MCP.
- `privacy-manifest-ios` (default) · `PrivacyInfo.xcprivacy` + Required Reason API helpers.
- `fastlane` (default) · `match` for signing, `deliver` for App Store upload, `snapshot` for screenshots.
- `maestro-e2e` (opt-in) · Cross-platform E2E if you also target other stacks.

## Agent team

- `ios-architect` — module layout, dependency tree, iOS minimum target.
- `swiftui-implementer` — SwiftUI views + `@Observable` view models.
- `swift-test-implementer` — Swift Testing suites + XCUITest flows.
- `xcode-build-resolver` — parse XcodeBuildMCP errors; fix dependency / signing / scheme drift.

Shared agents inherited: `app-store-compliance-auditor`, `mobile-release-coordinator`, `mobile-ux-screenshot-critic`.

Shared skill inherited: `verifying-on-simulator`.
```

- [ ] **Step 2: Write `harness.config.yml`**

```yaml
project:
  name: my-ios-app

memory:
  backend: md-files

progress:
  backend: linear

methodology:
  tdd: true
  spec_driven: true
  eval_driven: false
  bdd: false

orchestration:
  topology: single-agent

safety:
  two_key: false
  kill_switch: false
  sandbox: false

hitl:
  plan_mode_default: true
  diff_review_required: true

domain:
  pack: mobile
  subdomain: native-ios
  addons: [xcodebuild-mcp, sentry-mcp, privacy-manifest-ios, fastlane]

agents:
  team: curated
  exclude: []
  include: []

docs:
  context7_mcp: true
```

- [ ] **Step 3: Write `claude-md.md`**

```markdown
## native-ios rules

### Stack lockdown
- Swift 6.2 with Approachable Concurrency on (`SWIFT_DEFAULT_ACTOR_ISOLATION=MainActor`, `Approachable Concurrency = Yes`).
- SwiftUI as the primary UI framework. Use `@Observable` macros and `@State` for ownership; do not write new `@StateObject` / `@ObservedObject` code.
- SwiftData for persistence in new projects; Core Data only if the schema is >5 years old or migrations require it (justify in PR).
- Swift Testing for unit tests; XCUITest for UI tests; both can coexist in one target.
- Build SDK: Xcode 26+ (mandatory for App Store Connect after Apr 28, 2026).

### Build loop
- Drive `xcodebuild` exclusively through XcodeBuildMCP; read structured errors, never raw 3000-line logs.
- Boot the simulator with `xcrun simctl` or XcodeBuildMCP `boot_simulator`; screenshot after every UI change.

### Apple Intelligence
- Use the Foundation Models framework for on-device summarization / extraction / classification / rewriting.
- Do not call Foundation Models on devices ineligible for Apple Intelligence; ship a fallback path (hosted LLM with 5.1.2(i) consent UI, or graceful degradation).

### Never do
- Never paste an App Store Connect API key, `.p8` private key, or `MATCH_PASSWORD` into a tool call.
- Never disable Approachable Concurrency on a per-file basis without a documented reason.
- Never claim a UI change works without a simulator screenshot.
```

- [ ] **Step 4: Write `references.md`**

```markdown
# native-ios — references

> Verified: 2026-05.

- Swift 6.2 Approachable Concurrency (Xcode 26): <https://forums.swift.org/t/swift-concurrency-in-xcode-26/80539>
- Observation framework + SwiftUI: <https://nilcoalescing.com/blog/ObservableInSwiftUI/>
- Swift Testing complete guide: <https://www.atelier-socle.com/en/articles/swift-testing-guide>
- Foundation Models framework: <https://developer.apple.com/documentation/FoundationModels>
- WWDC25 — Meet Foundation Models (session 286): <https://developer.apple.com/videos/play/wwdc2025/286/>
- XcodeBuildMCP repo: <https://github.com/getsentry/XcodeBuildMCP>
- ios-simulator-mcp repo: <https://github.com/joshuayoes/ios-simulator-mcp>
- Apple App Review Guidelines (5.1.2(i)): <https://developer.apple.com/app-store/review/guidelines/>
- Apple privacy manifest: <https://developer.apple.com/documentation/bundleresources/privacy-manifest-files>
- Xcode 26 SDK mandatory Apr 28, 2026: <https://developer.apple.com/news/upcoming-requirements/>
```

- [ ] **Step 5: Write `files/.claude/settings.fragment.json`**

```json
{
  "hooks": {}
}
```

(Sub-domain inherits the domain layer's hooks; no extras at this level.)

- [ ] **Step 6: Write the four agents**

`ios-architect.md`:

```markdown
---
name: ios-architect
description: Designs the iOS app shape — module layout, dependency tree, target/min iOS version, Package.swift vs Xcode project, integration of XcodeBuildMCP and Foundation Models.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You design the structure of a Swift / SwiftUI iOS app for 2026:

- Target iOS 18 as minimum unless a compelling reason argues otherwise (Foundation Models requires iOS 18+).
- Prefer SwiftPM packages over Xcode-only frameworks for new dependencies.
- One feature = one module = one Swift package (Tuist, SwiftPM workspace, or in-Xcode static library).
- Dependency graph stays acyclic; check with `swift package show-dependencies` and document.
- Wire XcodeBuildMCP early; document the scheme names and configurations in `README.md`.
- If Apple Intelligence is in scope, justify the iOS 18 / Apple Silicon device gating and document the fallback path for ineligible devices.

You do not write feature code — that's `swiftui-implementer`. You do not write tests — that's `swift-test-implementer`. You scope architectural decisions in writing first.
```

`swiftui-implementer.md`:

```markdown
---
name: swiftui-implementer
description: Writes SwiftUI views and @Observable view models. Reviews itself against the simulator screenshot before claiming done.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You write SwiftUI feature code:

- `@Observable` view models with `@MainActor` isolation by default (Swift 6.2 Approachable Concurrency).
- `@State` for ownership; `let` for inputs; never `@StateObject` or `@ObservedObject` in new code.
- One view per file; one view model per file.
- Use `NavigationStack`, `NavigationLink(value:)`, and typed routes; no `NavigationView`.
- After every meaningful UI change, invoke the `verifying-on-simulator` skill: boot simulator, build via XcodeBuildMCP, install, launch, screenshot, diff against baseline.
- Do not claim done without a fresh simulator screenshot.

You consume errors as structured JSON from XcodeBuildMCP, never raw logs.
```

`swift-test-implementer.md`:

```markdown
---
name: swift-test-implementer
description: Writes Swift Testing suites for view models, networking, formatting; XCUITest flows for end-to-end. Pairs with swiftui-implementer.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You write tests:

- Unit tests with Swift Testing — `@Test` functions, parametrized via `@Test(arguments: …)`, `#expect` macros.
- One `@Suite` per behavior cluster; one file per `@Suite`.
- XCUITest for true end-to-end paths only; favor Maestro flows if `maestro-e2e` addon is wired.
- Snapshot tests via `swift-snapshot-testing` (Point-Free) only when the view is logically static; otherwise rely on the simulator screenshot loop.
- Coverage is *meaningful coverage*, not 100% — view-model branches, network error paths, formatting edge cases.

Run tests via `xcodebuild test` through XcodeBuildMCP; never via the Xcode UI button.
```

`xcode-build-resolver.md`:

```markdown
---
name: xcode-build-resolver
description: Diagnoses xcodebuild failures via XcodeBuildMCP structured error tree. Fixes dependency drift, signing/provisioning errors, scheme issues.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You read XcodeBuildMCP error output (structured JSON) and produce a minimal fix:

- Dependency resolution (`Package.swift` revs, `Podfile` revs, Xcode project SwiftPM cache).
- Signing/provisioning — usually a `match` cache stale, wrong team ID, or expired provisioning profile.
- Scheme issues — missing scheme, wrong configuration, undeclared dependencies.
- Module-not-found — usually a `target_dependencies` gap in `Package.swift` or `project.pbxproj`.

You never disable signing, never check in `.p8` private keys, never set `CODE_SIGNING_ALLOWED=NO` in production code paths. If the fix would weaken security, escalate to the architect.
```

- [ ] **Step 7: Write the two skills**

`parsing-xcodebuild-errors/SKILL.md`:

```markdown
---
name: parsing-xcodebuild-errors
description: Read structured XcodeBuildMCP error output and produce a focused fix list — failing target, file, line, error category, remediation.
---

# Parsing xcodebuild errors via XcodeBuildMCP

## Inputs

- The JSON error tree returned by XcodeBuildMCP `build_*` tools.
- The project's `Package.swift` and `project.pbxproj` (read-only).

## Process

1. Walk the JSON error tree and extract every leaf error.
2. Group errors by category: `compilation`, `linking`, `signing`, `dependency`, `provisioning`, `scheme`.
3. For each error, identify: failing target, failing file, line number, exact compiler/linker message.
4. Produce a one-line remediation per error or per error-group.
5. Surface the *first* error in each category as the highest priority — later errors are often cascades.

## Output

```
Errors (sorted by category, priority first):

[compilation] FooTarget · Sources/Foo/Bar.swift:42 — "cannot convert value of type 'Int' to expected argument type 'String'"
  → Cast or change the function signature. Likely caller-side mismatch from a recent API rename.

[signing] AppTarget · No provisioning profile matching bundle id "com.example.app"
  → Run fastlane match development; ensure team_id matches in Appfile.

...
```

Never invoke fixes from this skill — handoff to `xcode-build-resolver`.
```

`foundation-models-app-intent/SKILL.md`:

```markdown
---
name: foundation-models-app-intent
description: Wire Apple Foundation Models to an App Intent — typed guided generation, tool calls, streaming. Includes the device-gating fallback pattern.
---

# Foundation Models in an App Intent

## When to use

- On-device summarization / extraction / classification / rewriting for an App Intent surface (Siri, Shortcuts, Spotlight, Widgets).
- NOT for: world knowledge, advanced reasoning, multi-turn chat — push those to a hosted LLM with explicit 5.1.2(i) consent.

## Pattern

```swift
import FoundationModels
import AppIntents

@available(iOS 18.0, *)
struct SummarizeNotesIntent: AppIntent {
    static let title: LocalizedStringResource = "Summarize Notes"

    @Parameter(title: "Notes")
    var notes: [String]

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard SystemLanguageModel.default.isAvailable else {
            // Apple Intelligence not available on this device — fall back.
            return .result(dialog: "Summaries are not available on this device.")
        }
        let session = LanguageModelSession()
        let summary = try await session.respond(to: "Summarize these notes: \(notes.joined(separator: "\n"))")
        return .result(dialog: "\(summary.content)")
    }
}
```

## Device gating

`SystemLanguageModel.default.isAvailable` is the canonical check. Always ship the non-Apple-Intelligence path.

## Guarded outputs

Use `LanguageModelSession.respond(to:generating:)` with a `@Generable` Swift type for structured output. Validate at the boundary; do not pass raw model output to a privileged sink.
```

- [ ] **Step 8: Run structure-lint + assemble-coverage**

Run: `./templates/tests/checks/structure-lint.sh && ./templates/tests/checks/assemble-coverage.sh`
Expected: both PASS, counts up by at least 8 + 1 (8 new files contributing structure-lint checks, 1 new sub-domain auto-discovered).

- [ ] **Step 9: Commit**

```bash
git add templates/mobile/native-ios/
git commit -m "feat(mobile): native-ios sub-domain (Swift 6.2 + SwiftUI + Foundation Models)"
```

---

### Task 7: `native-android` sub-domain

**Files:**
- Create: `templates/mobile/native-android/SUBDOMAIN.md`
- Create: `templates/mobile/native-android/harness.config.yml`
- Create: `templates/mobile/native-android/claude-md.md`
- Create: `templates/mobile/native-android/references.md`
- Create: `templates/mobile/native-android/files/.claude/settings.fragment.json`
- Create: 4 agent files under `files/.claude/agents/`
- Create: 2 skill files under `files/.claude/skills/`

- [ ] **Step 1: Write `SUBDOMAIN.md`**

```markdown
# Sub-domain: mobile/native-android

Curated harness for Kotlin / Jetpack Compose Android apps targeting Google Play in 2026.

## Adopt if

- You're shipping a Kotlin app to Google Play with maximum Android integration: Gemini Nano / AICore, foreground services, Health Connect, Photo Picker.
- Your team is Android-only or Android-first.
- You want first-class Gradle + Android Studio Otter+ Gemini Agent Mode integration.

## Skip if

- You need cross-platform iOS coverage from the same codebase — pick `react-native-expo` or `flutter-app`.

## Addons that pair well

- `firebase-mcp` (default) · Auth, Firestore, FCM, Crashlytics (Experimental), Remote Config.
- `sentry-mcp` (default) · Crash + release triage via OAuth-hosted MCP.
- `fastlane` (default) · `supply` for Play upload, `screengrab` for screenshots.
- `play-data-safety` (default) · Walks the Play Console "Data safety" form.
- `maestro-e2e` (opt-in) · Cross-platform E2E.

## Agent team

- `android-architect` — module layout, Gradle config (KSP + Compose compiler), target/min SDK, Hilt graph.
- `compose-implementer` — Compose UI with Strong Skipping in mind.
- `android-test-implementer` — Compose UI Test + Espresso + Roborazzi snapshots.
- `gradle-build-resolver` — parse `gradle --console=plain` output, fix dependency conflicts.

Shared agents inherited: `app-store-compliance-auditor`, `mobile-release-coordinator`, `mobile-ux-screenshot-critic`.

Shared skill inherited: `verifying-on-simulator` (interpreted as "emulator" for Android).
```

- [ ] **Step 2: Write `harness.config.yml`**

```yaml
project:
  name: my-android-app

memory:
  backend: md-files

progress:
  backend: linear

methodology:
  tdd: true
  spec_driven: true
  eval_driven: false
  bdd: false

orchestration:
  topology: single-agent

safety:
  two_key: false
  kill_switch: false
  sandbox: false

hitl:
  plan_mode_default: true
  diff_review_required: true

domain:
  pack: mobile
  subdomain: native-android
  addons: [firebase-mcp, sentry-mcp, fastlane, play-data-safety]

agents:
  team: curated
  exclude: []
  include: []

docs:
  context7_mcp: true
```

- [ ] **Step 3: Write `claude-md.md`**

```markdown
## native-android rules

### Stack lockdown
- Kotlin 2.x (≥2.1 for Compose Compiler Gradle Plugin).
- Jetpack Compose 1.9+ as the primary UI; do not write new XML layouts.
- ViewModel + StateFlow + `collectAsStateWithLifecycle()`; no LiveData in new code.
- Hilt 2.56 with KSP. KAPT is banned in new modules.
- Target SDK 35 minimum (Android 15); raise to 36 (Android 16) by Aug 31, 2026.
- Android Studio Otter (2025.2.x) or newer.

### Build loop
- Use `./gradlew --console=plain` for agent-readable output; never the IDE button.
- For UI verification: boot emulator via `emulator -avd`, install with `adb install`, screenshot with `adb exec-out screencap -p`.
- Strong Skipping Mode is the default since Compose 1.7; keep state classes stable.

### Gemini Nano / on-device AI
- Use ML Kit GenAI APIs (Summarization, Proofreading, Rewriting, Image Description preview) for on-device LLM workloads.
- Device-gate carefully: Pixel 9 series / Galaxy S25 / Snapdragon / Tensor only. Ship a fallback path.

### Foreground services
- Every `<service>` with `android:foregroundServiceType` MUST also be declared in Play Console "App content"; missing the Console declaration breaks store review.
- Android 15: `dataSync` and `mediaProcessing` are time-bounded; `shortService` capped at 3 minutes.

### Never do
- Never paste a Play service account JSON or `FIREBASE_TOKEN` into a tool call.
- Never write KAPT-only annotation processors in new modules.
- Never claim a UI change works without an emulator screenshot.
```

- [ ] **Step 4: Write `references.md`**

```markdown
# native-android — references

> Verified: 2026-05.

- Kotlin / Compose Compiler setup: <https://developer.android.com/develop/ui/compose/setup-compose-dependencies-and-compiler>
- Jetpack Compose December '25 release: <https://android-developers.googleblog.com/2025/12/whats-new-in-jetpack-compose-december.html>
- Strong Skipping Mode explained: <https://medium.com/androiddevelopers/jetpack-compose-strong-skipping-mode-explained-cbdb2aa4b900>
- Hilt + KSP setup: <https://dagger.dev/dev-guide/ksp.html>
- Android Studio Agent Mode: <https://developer.android.com/studio/gemini/agent-mode>
- Otter 3 Feature Drop (Jan 2026): <https://android-developers.googleblog.com/2026/01/llm-flexibility-agent-mode-improvements.html>
- Gemini Nano / AICore: <https://developer.android.com/ai/gemini-nano>
- ML Kit GenAI APIs (May 2025): <https://android-developers.googleblog.com/2025/05/on-device-gen-ai-apis-ml-kit-gemini-nano.html>
- Behavior changes targeting Android 16: <https://developer.android.com/about/versions/16/behavior-changes-16>
- Foreground service types: <https://developer.android.com/develop/background-work/services/fgs/service-types>
- Photo picker: <https://developer.android.com/training/data-storage/shared/photo-picker>
- Target API requirements: <https://developer.android.com/google/play/requirements/target-sdk>
- Roborazzi: <https://github.com/takahirom/roborazzi>
```

- [ ] **Step 5: Write `files/.claude/settings.fragment.json`**

```json
{ "hooks": {} }
```

- [ ] **Step 6: Write the four agents**

`android-architect.md`:

```markdown
---
name: android-architect
description: Designs Kotlin / Jetpack Compose app shape — Gradle module graph (KSP + Compose compiler), target/min SDK, Hilt DI graph, Compose state management discipline.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You design the structure of a 2026 Android app:

- One feature = one Gradle module = one `:feature:<name>` path; `:core:*` for cross-feature utilities; `:app` is the assembly point only.
- Hilt DI graph is documented; modules expose narrow `@Module @InstallIn` interfaces, not god-objects.
- Target SDK 35 (raise to 36 by Aug 31, 2026); min SDK 26 unless a Pixel-9-only feature pushes it higher.
- Compose Compiler 2026.05+ wired via the Compose Compiler Gradle Plugin (not the legacy `kotlinCompilerExtensionVersion`).
- KSP everywhere; KAPT only as escape valve with a written justification.
- For on-device AI: device-gate Gemini Nano / ML Kit GenAI usage and provide a fallback.

You scope architecture decisions in writing first; you do not implement features.
```

`compose-implementer.md`:

```markdown
---
name: compose-implementer
description: Writes Jetpack Compose UI + ViewModels. Verifies on emulator before claiming done.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You write Compose code:

- Composable functions are pure; side effects via `LaunchedEffect`, `DisposableEffect`, `rememberCoroutineScope`.
- State holders are `@Stable` or `@Immutable` data classes — required for Strong Skipping efficiency.
- ViewModels expose `StateFlow<UiState>`; UI collects via `collectAsStateWithLifecycle()`.
- Use Material 3 components; theme tokens in `core:design-system`.
- After every meaningful UI change, invoke `verifying-on-simulator` (here: emulator): boot, install, screenshot.
- Do not claim done without a fresh emulator screenshot.

Use `./gradlew --console=plain assembleDebug` exclusively for agent-driven builds.
```

`android-test-implementer.md`:

```markdown
---
name: android-test-implementer
description: Writes JUnit unit tests, Compose UI Test, Espresso, and Roborazzi snapshots. Pairs with compose-implementer.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You write tests:

- Unit: JUnit 4 with Robolectric for ViewModel + use cases; pure-Kotlin tests for domain logic.
- UI: Compose UI Test (`createComposeRule()`) preferred; Espresso for legacy XML screens.
- Snapshot: Roborazzi for Compose + Activity/Fragment fidelity; Paparazzi if you need LayoutLib-only speed; Compose Preview Screenshot Testing for pure-Compose Previews.
- Coverage is meaningful, not 100%.

Run via `./gradlew testDebugUnitTest connectedDebugAndroidTest --console=plain`.
```

`gradle-build-resolver.md`:

```markdown
---
name: gradle-build-resolver
description: Diagnoses Gradle failures. Resolves dependency conflicts, KSP/KAPT migration, Compose compiler / Kotlin version drift, AGP upgrade fallout.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You read `./gradlew --console=plain` output and produce a focused fix:

- Dependency resolution conflicts — `./gradlew :app:dependencies` to pinpoint the divergence, then version-catalog (`libs.versions.toml`) edit.
- KSP/KAPT migration — replace `kapt` configurations with `ksp` in `build.gradle.kts`; check annotation-processor compatibility.
- Compose compiler vs Kotlin version — use the Compose Compiler Gradle Plugin to align automatically.
- AGP upgrade fallout — read the AGP migration guide for the target version; gate behind a feature branch.

Never disable `enableProguardInReleaseBuilds`, never check in `signing` blocks with literal passwords.
```

- [ ] **Step 7: Write the two skills**

`parsing-gradle-errors/SKILL.md`:

```markdown
---
name: parsing-gradle-errors
description: Turn `./gradlew --console=plain` output into a structured fix list (failing module, task, line, remediation).
---

# Parsing Gradle errors

## Inputs

- The plain-text Gradle output (always invoke with `--console=plain`).
- `libs.versions.toml`, `settings.gradle.kts`, root `build.gradle.kts`.

## Process

1. Find the first `> Task :module:task FAILED` line.
2. Read backwards 20 lines to find the actual error text (Gradle prints reverse-chronological causes).
3. Categorize: `compilation`, `linking`, `dependency-resolution`, `ksp/kapt`, `compose-compiler`, `signing`, `r8/proguard`.
4. For dependency-resolution, run `./gradlew :module:dependencies --console=plain` and locate the conflicting transitives.
5. Produce one-line remediation per error.

## Output

```
[ksp/kapt] :feature:checkout · "Cannot find generated Hilt module"
  → Replace `kapt 'com.google.dagger:hilt-android-compiler'` with `ksp 'com.google.dagger:hilt-android-compiler'`. Run `./gradlew clean`.

[compose-compiler] :feature:product · "Kotlin version 2.0.20 incompatible with Compose Compiler 1.5.10"
  → Use Compose Compiler Gradle Plugin (id("org.jetbrains.kotlin.plugin.compose") version "2.1.0"). Remove `kotlinCompilerExtensionVersion`.
```
```

`foreground-service-type-author/SKILL.md`:

```markdown
---
name: foreground-service-type-author
description: Declare correct foregroundServiceType per Android 14/15/16 rules; pair with Play Console "App content" entry.
---

# Declaring foregroundServiceType correctly

## Why

Android 14+ throws `MissingForegroundServiceTypeException` if a `<service>` running as foreground does not declare `android:foregroundServiceType`. Android 15 added time bounds to `dataSync` / `mediaProcessing`. Android 16 applies runtime quotas to jobs from FGS in non-active buckets.

## Inputs

- The use case: "what is the foreground service doing?"
- The current `AndroidManifest.xml`.

## Process

1. Pick the most specific type from: `dataSync`, `mediaProcessing`, `mediaPlayback`, `phoneCall`, `connectedDevice`, `location`, `health`, `shortService`, `specialUse`, `remoteMessaging`, `systemExempted`.
2. Declare in manifest:

```xml
<service
    android:name=".MyForegroundService"
    android:foregroundServiceType="dataSync"
    android:exported="false" />
```

3. Add the corresponding permission to the manifest: `FOREGROUND_SERVICE_DATA_SYNC` for `dataSync`, etc.
4. Document the matching Play Console "App content" entry in `play-console-checklist.md` (missing this breaks store review).

## Output

The manifest edit, the permission addition, and the checklist update.
```

- [ ] **Step 8: Run structure-lint + assemble-coverage**

Run: `./templates/tests/checks/structure-lint.sh && ./templates/tests/checks/assemble-coverage.sh`
Expected: both PASS, counts up further.

- [ ] **Step 9: Commit**

```bash
git add templates/mobile/native-android/
git commit -m "feat(mobile): native-android sub-domain (Kotlin 2.x + Compose + Hilt+KSP)"
```

---

### Task 8: `react-native-expo` sub-domain

**Files:**
- Create: `templates/mobile/react-native-expo/SUBDOMAIN.md`
- Create: `templates/mobile/react-native-expo/harness.config.yml`
- Create: `templates/mobile/react-native-expo/claude-md.md`
- Create: `templates/mobile/react-native-expo/references.md`
- Create: `templates/mobile/react-native-expo/files/.claude/settings.fragment.json`
- Create: 4 agents
- Create: 2 skills (verifying-on-simulator is inherited from shared layer — do NOT duplicate here)

- [ ] **Step 1: Write `SUBDOMAIN.md`**

```markdown
# Sub-domain: mobile/react-native-expo

Curated harness for Expo SDK 54+ React Native apps targeting iOS + Android in 2026.

## Adopt if

- Cross-platform iOS + Android with a JS/TS team.
- Want deepest AI-tooling MCP coverage (XcodeBuildMCP + Expo MCP + Sentry MCP + Firebase MCP all OAuth-first).
- Want OTA JS updates via EAS Update.

## Skip if

- You need pixel-perfect platform UI per OS (pick `native-ios` + `native-android`).
- You need first-class on-device Apple Intelligence / Gemini Nano APIs (pick native).

## Addons that pair well

- `xcodebuild-mcp` (default) · iOS build/sim loop.
- `expo-mcp` (default) · EAS Build/Submit/Workflow inspection via hosted OAuth MCP.
- `sentry-mcp` (default) · OAuth-hosted crash triage.
- `eas-build` (default) · `eas.json` profiles + release coordinator.
- `maestro-e2e` (default) · Cross-platform E2E.
- `privacy-manifest-ios` (default) · `PrivacyInfo.xcprivacy` + Required Reason API helpers.
- `play-data-safety` (default) · Play Console "Data safety" walker.
- `firebase-mcp` (opt-in) · If using Firebase services.

## Agent team

- `expo-architect` — Expo project shape, EAS profiles, expo-router structure.
- `rn-screen-implementer` — screens + components with Expo Router + React 19.
- `rn-test-implementer` — Jest + Maestro flows.
- `eas-release-resolver` — EAS Build errors, OTA vs native rebuild decision.

Shared agents inherited. Shared skill `verifying-on-simulator` inherited.
```

- [ ] **Step 2: Write `harness.config.yml`**

```yaml
project:
  name: my-rn-app

memory:
  backend: md-files

progress:
  backend: linear

methodology:
  tdd: true
  spec_driven: true
  eval_driven: false
  bdd: false

orchestration:
  topology: single-agent

safety:
  two_key: false
  kill_switch: false
  sandbox: false

hitl:
  plan_mode_default: true
  diff_review_required: true

domain:
  pack: mobile
  subdomain: react-native-expo
  addons: [xcodebuild-mcp, expo-mcp, sentry-mcp, eas-build, maestro-e2e, privacy-manifest-ios, play-data-safety]

agents:
  team: curated
  exclude: []
  include: []

docs:
  context7_mcp: true
```

- [ ] **Step 3: Write `claude-md.md`**

```markdown
## react-native-expo rules

### Stack lockdown
- Expo SDK 54+ (RN 0.81+; consider SDK 56 beta only if a specific RN 0.84 feature is required).
- React 19.1+; React Compiler enabled.
- New Architecture (Fabric/TurboModules/JSI) is default-on and not optional in RN 0.82+.
- Hermes V1 default (RN 0.84+); legacy JSC banned.
- Expo Router v6 (file-based routing); React Navigation consumed *through* Expo Router.
- EAS Build for native; EAS Update for OTA JS-only diffs; EAS Submit for store delivery.

### Build loop
- iOS: drive via XcodeBuildMCP. Android: drive via `./gradlew --console=plain` from `android/`.
- Use Expo MCP (`mcp.expo.dev`) for EAS Build queue + logs.
- Precompiled iOS XCFrameworks ship in SDK 54+; clean iOS builds drop from ~120s to ~10s on M4 Max.

### OTA vs native rebuild
- JS / image / locale change → EAS Update (instant, bypasses App Store review).
- Native module change → EAS Build (new binary, requires resubmission).
- Decision rule: if `npx expo prebuild --check` reports drift, you need a native rebuild.

### Compatibility
- Verify every library is New-Architecture-ready before adding. Use `react-native-directory` compatibility column.

### Never do
- Never disable the New Architecture.
- Never pin RN < 0.81 in a new project.
- Never paste `EXPO_TOKEN` into a tool call.
```

- [ ] **Step 4: Write `references.md`**

```markdown
# react-native-expo — references

> Verified: 2026-05.

- React Native 0.84 (Hermes V1 default): <https://reactnative.dev/blog/2026/02/11/react-native-0.84>
- Get started with React Native (Expo-first guidance): <https://reactnative.dev/docs/environment-setup>
- Expo SDK 54 changelog: <https://expo.dev/changelog/sdk-54>
- Expo SDK 56 beta: <https://expo.dev/changelog/sdk-56-beta>
- Expo Router v6 intro: <https://docs.expo.dev/router/introduction/>
- Expo MCP: <https://docs.expo.dev/eas/ai/mcp/>
- EAS Build + Submit + Update: <https://docs.expo.dev/eas/>
- XcodeBuildMCP: <https://github.com/getsentry/XcodeBuildMCP>
- Sentry MCP: <https://docs.sentry.io/product/sentry-mcp/>
- Maestro: <https://maestro.dev/>
- React Native New Architecture: <https://reactnative.dev/architecture/landing-page>
- React Native directory (New-Arch compatibility): <https://reactnative.directory/>
```

- [ ] **Step 5: Write `files/.claude/settings.fragment.json`**

```json
{ "hooks": {} }
```

- [ ] **Step 6: Write the four agents**

`expo-architect.md`:

```markdown
---
name: expo-architect
description: Designs Expo project shape — EAS profiles, expo-router structure, native config plugins, OTA strategy.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You design Expo SDK 54+ projects:

- File-based routing under `app/`; typed routes via `expo-router/types` codegen.
- Server middleware (`+middleware.ts`) for auth / locale / feature flags.
- `app.config.ts` over `app.json` for branch-driven config; never edit native `ios/` or `android/` directly.
- EAS profiles: `development` (dev client), `preview` (internal QA), `production`.
- Native libraries declared via Expo config plugins, never patched in `ios/`/`android/`.
- Document OTA strategy in `README.md`: which channels, how rollback works, EAS Update vs build cadence.

Architecture decisions in writing first; no feature code.
```

`rn-screen-implementer.md`:

```markdown
---
name: rn-screen-implementer
description: Writes Expo Router screens + components. Verifies on iOS simulator and Android emulator.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You write screens and components:

- Functional components only; React 19 Server Components considered carefully (RSC in RN is still evolving — confirm Expo Router support before adopting).
- Theme tokens via `@expo/vector-icons` + your design-system package; no inline color literals.
- Lists via `@shopify/flash-list` for large datasets; `FlatList` for small.
- After every meaningful UI change, invoke `verifying-on-simulator` for iOS (XcodeBuildMCP boot+install) and emulator path for Android.
- Do not claim done without simulator+emulator screenshots for cross-platform screens.
```

`rn-test-implementer.md`:

```markdown
---
name: rn-test-implementer
description: Writes Jest unit tests + Maestro YAML flows. Pairs with rn-screen-implementer.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You write tests:

- Unit: Jest with `@testing-library/react-native`; one test file per component.
- E2E: Maestro flows in `.maestro/` directory; LLM-writable YAML.
- Test selectors via `testID=` on every interactive element.
- Snapshot tests sparingly — only for stable, regression-prone visuals.

Run unit tests via `npx jest --ci`; run Maestro via `maestro test .maestro/`.
```

`eas-release-resolver.md`:

```markdown
---
name: eas-release-resolver
description: Diagnoses EAS Build errors. Decides between EAS Update (OTA JS-only) and EAS Build (native rebuild).
tools: Read, Write, Edit, Bash, Glob, Grep
---

You read EAS Build logs (via Expo MCP) and produce a fix:

- Cocoapods failure → usually a config-plugin drift; rerun `npx expo prebuild --clean`.
- Gradle failure → usually a Kotlin/AGP/SDK mismatch; check Expo SDK release notes.
- Provisioning failure → fastlane `match` and EAS credentials state diverge; reset via `eas credentials`.
- iOS signing → use EAS-managed credentials by default; only switch to manual if a corporate policy requires it.

For OTA decisions: run `npx expo prebuild --check` to detect native drift. If JS-only, `eas update --branch production`. Otherwise `eas build --profile production`.
```

- [ ] **Step 7: Write the two skills**

`expo-fast-iteration/SKILL.md`:

```markdown
---
name: expo-fast-iteration
description: Decide between Expo Go, dev client, and full native build for the inner loop. Apply EAS Update vs EAS Build decision rules.
---

# Expo fast iteration

## Inner loop choice

| Situation | Use |
|---|---|
| Pure-JS feature, no new native deps | Expo Go (fastest) |
| Adding a config-plugin dep that's compatible with Expo Go | Expo Go after `npx expo install` |
| Adding a native module not in Expo Go's bundled set | Dev client (`npx expo run:ios --device`, `npx expo run:android`) |
| Working on the native side (config-plugin authoring, custom ObjC/Kotlin) | Full prebuild + native run |

## OTA vs native rebuild

`npx expo prebuild --check` is the source of truth.

- Diff is empty → safe for `eas update`.
- Diff non-empty → must `eas build`; OTA cannot ship native changes.

## Caching

- SDK 54 precompiled XCFrameworks: clean iOS build drops from ~120s to ~10s.
- EAS Build cache: persistent across builds in the same profile.
- Local: keep `node_modules` and `Pods` in cache between iterations.
```

`react-native-new-arch-guardrails/SKILL.md`:

```markdown
---
name: react-native-new-arch-guardrails
description: Detect Old-Architecture-only libraries; recommend New-Architecture-ready replacements.
---

# New Architecture compatibility check

## Why

RN 0.82+ removes the legacy bridge. Old-Arch-only libraries will not load. Verify *before* `expo install`.

## Process

1. Look up the candidate library on `https://reactnative.directory/` — "New Architecture" column.
2. If "✅" — proceed.
3. If "❌" or unknown — check the library's repo for a recent (2025–2026) release noting New-Arch support.
4. If still unknown — search GitHub issues for "new architecture" / "fabric" / "turbomodule".
5. If no support exists — recommend the New-Arch-ready alternative (the directory typically lists one).

## Known-good 2026 replacements

| Old-Arch-only | New-Arch-ready replacement |
|---|---|
| `react-native-camera` (deprecated) | `react-native-vision-camera` ≥ 4.0 |
| `react-navigation` v5 | React Navigation 7.2+ via Expo Router v6 |
| Legacy Reanimated 2 | Reanimated 3.5.1+ |
| `react-native-gesture-handler` < 2.16 | 2.16.2+ |

Document the choice in `README.md`.
```

- [ ] **Step 8: Run tests**

Run: `./templates/tests/checks/structure-lint.sh && ./templates/tests/checks/assemble-coverage.sh`
Expected: both PASS.

- [ ] **Step 9: Commit**

```bash
git add templates/mobile/react-native-expo/
git commit -m "feat(mobile): react-native-expo sub-domain (Expo SDK 54+ RN 0.84)"
```

---

### Task 9: `flutter-app` sub-domain

**Files:**
- Create: `templates/mobile/flutter-app/SUBDOMAIN.md`
- Create: `templates/mobile/flutter-app/harness.config.yml`
- Create: `templates/mobile/flutter-app/claude-md.md`
- Create: `templates/mobile/flutter-app/references.md`
- Create: `templates/mobile/flutter-app/files/.claude/settings.fragment.json`
- Create: 4 agents
- Create: 2 skills

- [ ] **Step 1: Write `SUBDOMAIN.md`**

```markdown
# Sub-domain: mobile/flutter-app

Curated harness for Flutter 3.27+ / Dart 3.x apps targeting iOS + Android in 2026.

## Adopt if

- Pixel-perfect uniform UI across iOS + Android with heavy custom animation.
- Dart expertise (or willingness to build it).
- Want Impeller's render performance ceiling.

## Skip if

- You need OTA JS updates — pick `react-native-expo`.
- You need first-class Apple Intelligence Foundation Models or Gemini Nano APIs — pick native.
- You need maximum AI-tooling MCP integration — `react-native-expo` has deeper coverage in 2026.

## Addons that pair well

- `xcodebuild-mcp` (default) · iOS build/sim loop.
- `firebase-mcp` (default) · Auth/Firestore/FCM/Crashlytics — Flutter's de-facto BaaS.
- `sentry-mcp` (default) · OAuth-hosted crash triage.
- `patrol-flutter` (default) · `integration_test` with native automation via UIAutomator/XCUITest.
- `privacy-manifest-ios` (default) · `PrivacyInfo.xcprivacy` + Required Reason API helpers.
- `play-data-safety` (default) · Play Console "Data safety" walker.
- `fastlane` (opt-in) · If shipping outside EAS.

## Agent team

- `flutter-architect` — project shape, package layout, Dart linter config.
- `flutter-screen-implementer` — Material 3 + Cupertino widget composition.
- `flutter-test-implementer` — `flutter_test` + Patrol.
- `riverpod-state-modeler` — Provider/Notifier/AsyncNotifier discipline.

Shared agents inherited. Shared skill `verifying-on-simulator` inherited.
```

- [ ] **Step 2: Write `harness.config.yml`**

```yaml
project:
  name: my-flutter-app

memory:
  backend: md-files

progress:
  backend: linear

methodology:
  tdd: true
  spec_driven: true
  eval_driven: false
  bdd: false

orchestration:
  topology: single-agent

safety:
  two_key: false
  kill_switch: false
  sandbox: false

hitl:
  plan_mode_default: true
  diff_review_required: true

domain:
  pack: mobile
  subdomain: flutter-app
  addons: [xcodebuild-mcp, firebase-mcp, sentry-mcp, patrol-flutter, privacy-manifest-ios, play-data-safety]

agents:
  team: curated
  exclude: []
  include: []

docs:
  context7_mcp: true
```

- [ ] **Step 3: Write `claude-md.md`**

```markdown
## flutter-app rules

### Stack lockdown
- Flutter 3.27+ stable channel; Dart 3.x.
- Impeller renderer (the only iOS option since 2024; default on Android API 29+).
- Riverpod 2.5+ for state management in new code; BLoC retained only for regulated enterprise codebases that already standardize on it.
- Material 3 + Cupertino widget composition; use `Theme.adaptive` patterns where rules differ per platform.
- `flutter_test` + Patrol for integration tests; no `flutter_driver` in new code.

### Build loop
- iOS: drive via XcodeBuildMCP (Flutter's `ios/` is a real Xcode project).
- Android: `flutter build apk --debug` then drive with `adb`.
- Use `flutter --enable-impeller --verbose` to capture renderer traces when investigating jank.

### Cupertino / Material parity
- Do not force a single design language on both platforms unless the brand demands it. Use `Platform.isIOS` switches sparingly; prefer `CupertinoApp`+`MaterialApp` composition through `AdaptiveApp` pattern.

### Never do
- Never check in `google-services.json` or `GoogleService-Info.plist` with production keys.
- Never disable Impeller on iOS without a documented bug.
- Never claim a UI change works without simulator+emulator screenshots.
```

- [ ] **Step 4: Write `references.md`**

```markdown
# flutter-app — references

> Verified: 2026-05.

- Flutter 2026 roadmap (Impeller-only iOS, decoupling Material): <https://blog.flutter.dev/flutter-darts-2026-roadmap-89378f17ebbd>
- Impeller rendering engine: <https://docs.flutter.dev/perf/impeller>
- Riverpod vs BLoC 2026: <https://sharpskill.dev/en/blog/flutter/flutter-state-management-riverpod-vs-bloc>
- Patrol (LeanCode): <https://github.com/leancodepl/patrol>
- Compose Multiplatform 1.11.0 (alternative, for awareness): <https://blog.jetbrains.com/kotlin/2026/05/compose-multiplatform-1-11-0/>
- Firebase MCP GA: <https://firebase.blog/posts/2025/10/firebase-mcp-server-ga/>
- Sentry MCP: <https://docs.sentry.io/product/sentry-mcp/>
- XcodeBuildMCP: <https://github.com/getsentry/XcodeBuildMCP>
```

- [ ] **Step 5: Write `files/.claude/settings.fragment.json`**

```json
{ "hooks": {} }
```

- [ ] **Step 6: Write the four agents**

`flutter-architect.md`:

```markdown
---
name: flutter-architect
description: Designs Flutter app shape — package layout (features/, core/), Dart linter rules, target SDKs, dependency graph.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You design Flutter projects:

- One feature = one Dart package under `packages/features/<name>`; `packages/core/<name>` for cross-feature utilities.
- `pubspec.yaml` constraints pinned tight; transitive resolution checked in CI.
- `analysis_options.yaml` extends `package:lints/recommended.yaml` + a custom strictness layer.
- Target: iOS 15+ minimum (so Impeller works correctly); Android minSdk 24.
- Riverpod scope: one `ProviderScope` per app; features expose their own providers; do not share `ProviderContainer` instances.

You scope decisions in writing first; no feature code.
```

`flutter-screen-implementer.md`:

```markdown
---
name: flutter-screen-implementer
description: Writes Flutter screens with Material 3 + Cupertino composition. Verifies on iOS simulator and Android emulator.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You write screens and widgets:

- StatefulWidget for things with private state; HookConsumerWidget (flutter_hooks + Riverpod) for reactive flows.
- Theme tokens via `ThemeData` and `CupertinoThemeData`; no hard-coded colors/font sizes.
- Animations use `flutter_animate` for declarative composition; explicit `AnimationController` only when truly necessary.
- After every meaningful UI change, invoke `verifying-on-simulator` for both iOS simulator AND Android emulator.
- Do not claim done without both screenshots when a screen is cross-platform.
```

`flutter-test-implementer.md`:

```markdown
---
name: flutter-test-implementer
description: Writes flutter_test widget tests + Patrol integration tests.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You write tests:

- Unit / widget: `flutter_test` with `testWidgets()`, `tester.pumpWidget()`, `expect()` matchers.
- Integration / E2E: Patrol — drives native permission dialogs, notifications, Settings, Wi-Fi/Bluetooth.
- Golden tests via `flutter_test`'s `matchesGoldenFile` for stable visuals; run with `--update-goldens` to regenerate.

Run tests via `flutter test` (widget) and `patrol test` (integration).
```

`riverpod-state-modeler.md`:

```markdown
---
name: riverpod-state-modeler
description: Designs Provider / Notifier / AsyncNotifier shape per feature. Enforces one scope, narrow exposure, no shared containers.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You model Riverpod state:

- One Notifier per feature unit-of-state; expose narrowly typed providers.
- AsyncNotifier for any provider that touches IO; never wrap an AsyncNotifier in a sync provider.
- `@riverpod` codegen (riverpod_generator) for boilerplate elimination; never hand-write `StateNotifierProvider` boilerplate in new code.
- Lifecycle: providers auto-dispose by default; opt out with `keepAlive: true` only when persistence is justified.
- Test each Notifier with `ProviderContainer` in isolation.

You do not write feature UI; you draft state providers and hand off to `flutter-screen-implementer`.
```

- [ ] **Step 7: Write the two skills**

`flutter-impeller-diagnostics/SKILL.md`:

```markdown
---
name: flutter-impeller-diagnostics
description: Read Impeller renderer traces; identify shader stutters; decide when to fall back to Skia (Android only).
---

# Impeller diagnostics

## Inputs

- Output of `flutter run --enable-impeller --verbose`.
- A jank report (`Jank` lines in the log) or DevTools timeline.

## Process

1. Look for `Impeller` lines in the verbose log; Impeller is the iOS-only renderer (cannot be disabled there since 2024).
2. On Android: Impeller is default on API 29+. If you see shader-compilation stutters in the first frames, that's the classic Impeller-Android pattern.
3. Capture the shader hot path with DevTools' performance timeline.
4. Mitigations:
   - Add `@pragma('vm:prefer-inline')` to hot paths; precompile shaders with `flutter run --cache-sksl` (Skia only — for Android-Skia fallback) or `--impeller-precompile-shaders`.
   - Reduce shader variants: avoid runtime gradient math; bake into constants.
5. Android fallback to Skia (`--no-enable-impeller`) is allowed *only* for an emergency: document the bug ID and link the Flutter issue.

## Output

The renderer choice, the shader hot path, the mitigation applied, and a regression test if applicable.
```

`verifying-on-device-flutter/SKILL.md`:

```markdown
---
name: verifying-on-device-flutter
description: Flutter-specific simulator/emulator verification loop with flutter drive and screenshot capture for both platforms.
---

# Verifying a Flutter UI change on device

## Process

1. Boot simulator: `xcrun simctl boot 'iPhone 16 Pro'` (or via XcodeBuildMCP `boot_simulator`).
2. Boot emulator: `emulator -avd Pixel_8 -no-snapshot-load &`.
3. Build for both: `flutter build ios --debug --simulator` and `flutter build apk --debug`.
4. Install + run: `flutter run -d "iPhone 16 Pro"` and (in parallel terminal) `flutter run -d emulator-5554`.
5. Drive UI: either Patrol from the test suite, or `flutter drive --target=integration_test/<flow>.dart`.
6. Capture screenshots: `xcrun simctl io booted screenshot ios.png` and `adb exec-out screencap -p > android.png`.
7. Diff against baseline if `baselines/` exists; if no baseline, save the current screenshot as the new baseline (one file per platform).

## Output

- `ios.png` + `android.png` saved to `.claude/screenshots/<feature>/<timestamp>/`.
- A one-line verdict: "iOS PASS / Android PASS" or specific deltas.
```

- [ ] **Step 8: Run tests**

Run: `./templates/tests/checks/structure-lint.sh && ./templates/tests/checks/assemble-coverage.sh`
Expected: both PASS.

- [ ] **Step 9: Commit**

```bash
git add templates/mobile/flutter-app/
git commit -m "feat(mobile): flutter-app sub-domain (Flutter 3.27+ Impeller + Riverpod)"
```

---

### Task 10: Mobile MCP addons (xcodebuild-mcp, expo-mcp, firebase-mcp, sentry-mcp)

**Files (per addon):** `MODULE.md`, `claude-md.md`, `files/.mcp.json.fragment`, optional `files/.claude/agents/<contributed>.md`, optional `files/.claude/skills/<contributed>/SKILL.md`.

- [ ] **Step 1: Write `_addons/xcodebuild-mcp/MODULE.md`**

```markdown
# Module: mobile/addon/xcodebuild-mcp

> Config: `domain.addons` · Depends on: macOS host with Xcode 26+ installed; Node + npm.

**What it does.** Wires `getsentry/XcodeBuildMCP` and `ios-simulator-mcp` into `.mcp.json` so the agent can build, boot simulator, install, launch, screenshot, log, and run tests on iOS / macOS / tvOS / watchOS / visionOS targets. Contributes the `xcode-simulator-driver` agent.

## Adopt if
- iOS work is in scope (native-ios, react-native-expo iOS targets, flutter-app iOS targets).

## Skip if
- Project targets Android-only.

## Dependencies
- macOS with Xcode 26+ installed.
- `npx` on PATH.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Add the `XcodeBuildMCP` + `ios-simulator-mcp` blocks to `.mcp.json`.
3. Copy `xcode-simulator-driver.md` into `.claude/agents/`.

## Install (assemble.sh)
Add `xcodebuild-mcp` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `## XcodeBuildMCP` section from `CLAUDE.md`.
- Remove the `XcodeBuildMCP` + `ios-simulator-mcp` entries from `.mcp.json`.
- Delete `.claude/agents/xcode-simulator-driver.md`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/.mcp.json.fragment`
- `files/.claude/agents/xcode-simulator-driver.md`
```

- [ ] **Step 2: Write `_addons/xcodebuild-mcp/claude-md.md`**

```markdown
## XcodeBuildMCP

The agent has access to:

- **XcodeBuildMCP** (`getsentry/XcodeBuildMCP`): build, scheme management, sim boot/install/launch, screenshot, log streaming, test execution, UI automation. Around 59 tools, headless (no Xcode UI required).
- **ios-simulator-mcp** (`joshuayoes/ios-simulator-mcp`): accessibility-tree driven UI automation (tap, swipe, type) — resolves elements by accessibility label, robust to layout changes.

### Telemetry posture
XcodeBuildMCP ships opt-out Sentry telemetry to its new maintainer. Set `XCODEBUILDMCP_SENTRY_DISABLED=true` in the MCP env block to disable.

### Credentials
Local Xcode keychain only. No remote tokens. No App Store Connect API key in the env.
```

- [ ] **Step 3: Write `_addons/xcodebuild-mcp/files/.mcp.json.fragment`**

```json
{
  "mcpServers": {
    "XcodeBuildMCP": {
      "command": "npx",
      "args": ["-y", "xcodebuildmcp@latest", "mcp"],
      "env": {
        "XCODEBUILDMCP_SENTRY_DISABLED": "true"
      }
    },
    "ios-simulator": {
      "command": "npx",
      "args": ["-y", "ios-simulator-mcp@latest"]
    }
  }
}
```

- [ ] **Step 4: Write `_addons/xcodebuild-mcp/files/.claude/agents/xcode-simulator-driver.md`**

```markdown
---
name: xcode-simulator-driver
description: Drives the iOS simulator end-to-end via XcodeBuildMCP + ios-simulator-mcp. Builds, boots, installs, launches, captures accessibility tree, taps/swipes/types, screenshots.
tools: Read, Bash
---

You drive the iOS simulator for verification flows. You do not author feature code.

## Standard loop

1. `discover_projects` → confirm scheme + workspace.
2. `build_sim` → build for the target simulator (parse structured errors if it fails; hand off to `xcode-build-resolver`).
3. `boot_simulator` → boot the chosen device.
4. `install_app` → install the built `.app`.
5. `launch_app` → launch with explicit bundle ID.
6. `describe_ui` (ios-simulator-mcp) → fetch accessibility tree.
7. Tap/swipe/type to reach the screen under test.
8. `screenshot` → save to `.claude/screenshots/<feature>/<timestamp>/`.

## Constraints
- Never tap on coordinates — always resolve via accessibility label.
- Always save screenshots with timestamps; never overwrite a previous run.
- If `describe_ui` returns an empty tree, fail loud rather than guess coordinates.
```

- [ ] **Step 5: Write `_addons/expo-mcp/MODULE.md`**

```markdown
# Module: mobile/addon/expo-mcp

> Config: `domain.addons` · Depends on: an Expo account with EAS paid plan.

**What it does.** Wires the hosted Expo MCP (`mcp.expo.dev`) into `.mcp.json` via Streamable HTTP + OAuth. The agent gets EAS Build/Submit/Workflow inspection, latest Expo docs, `npx expo install` resolution, and simulator/visual verification. Contributes the `eas-workflow-author` skill.

## Adopt if
- Using Expo SDK 54+ with EAS.
- Want OAuth-first MCP credential posture (post-Anodot reference standard).

## Skip if
- Not using Expo (e.g., bare RN, native-only).

## Dependencies
- Expo account, EAS paid plan.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Run `claude mcp add --transport http expo-mcp https://mcp.expo.dev/mcp`.
3. Run `/mcp` and OAuth-authenticate.
4. Copy `eas-workflow-author/SKILL.md` into `.claude/skills/`.

## Install (assemble.sh)
Add `expo-mcp` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Remove the `## Expo MCP` section from `CLAUDE.md`.
- `claude mcp remove expo-mcp`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/.claude/skills/eas-workflow-author/SKILL.md`
```

- [ ] **Step 6: Write `_addons/expo-mcp/claude-md.md`**

```markdown
## Expo MCP

The agent has access to **Expo's hosted MCP** at `https://mcp.expo.dev/mcp` (Streamable HTTP + OAuth). Tools include:

- `build_list`, `build_info`, `build_logs`, `build_run`, `build_cancel`, `build_submit`
- `workflow_create`, `workflow_list`, `workflow_info`, `workflow_logs`, `workflow_run`, `workflow_cancel`, `workflow_validate`

### Credentials posture
OAuth via Expo accounts (reference standard post-Anodot). No `EXPO_TOKEN` in env. EAS paid plan required.

### Gating
Calls that trigger billable resources (`build_run`, `build_submit`, `workflow_run`) should respect `safety.two_key` — if it's true, require a typed token before invoking.
```

- [ ] **Step 7: Write `_addons/expo-mcp/files/.claude/skills/eas-workflow-author/SKILL.md`**

```markdown
---
name: eas-workflow-author
description: Author EAS Workflows YAML — build → test → submit → update pipelines.
---

# Authoring EAS Workflows

## Inputs

- The project's `app.config.ts` / `app.json`.
- The desired release shape (preview vs production; iOS vs Android; OTA vs binary).

## Process

1. Create `.eas/workflows/<name>.yml`.
2. Declare `on:` triggers (`push`, `pull_request`, `workflow_dispatch`).
3. List `jobs:` — `build`, `test`, `submit`, `update` are the canonical four.
4. Configure each job's `runs-on` (e.g., `linux-medium` for non-iOS, `macos-medium` for iOS).
5. Pin `eas-cli` and `node` versions explicitly.
6. Wire artifacts via `outputs:` and `with.path:`.
7. Use `if: contains(github.ref, 'refs/heads/release/')` to gate production.

## Output

A working `.eas/workflows/<name>.yml` plus a one-line explainer of when each job runs.

Reference: <https://docs.expo.dev/eas/workflows/>.
```

- [ ] **Step 8: Write `_addons/firebase-mcp/MODULE.md`**

```markdown
# Module: mobile/addon/firebase-mcp

> Config: `domain.addons` · Depends on: Firebase CLI, gcloud (for ADC).

**What it does.** Wires Firebase's official MCP server (`firebase-tools mcp`) into `.mcp.json`. The agent gets Auth, Firestore, FCM, Crashlytics (Experimental), Remote Config, App Hosting, and Realtime DB tools. Contributes the `crashlytics-triager` agent.

## Adopt if
- Using Firebase services (Auth, Firestore, FCM, Crashlytics, etc.).

## Skip if
- No Firebase in the project.

## Dependencies
- `firebase-tools` installed (`npm i -g firebase-tools` or `npx`).
- Firebase CLI login (`firebase login`) or Application Default Credentials (`gcloud auth application-default login`).

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Add the `firebase` block to `.mcp.json`.
3. Copy `crashlytics-triager.md` into `.claude/agents/`.

## Install (assemble.sh)
Add `firebase-mcp` to `domain.addons` and run `./assemble.sh`.

## Remove
- Remove the `## Firebase MCP` section from `CLAUDE.md`.
- Remove `firebase` from `.mcp.json`.
- Delete `.claude/agents/crashlytics-triager.md`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/.mcp.json.fragment`
- `files/.claude/agents/crashlytics-triager.md`
```

- [ ] **Step 9: Write `_addons/firebase-mcp/claude-md.md`**

```markdown
## Firebase MCP

The agent has access to **Firebase MCP** via `firebase-tools mcp`. Tool groups:

- Core: project / app management, security rules.
- Auth: users, SMS region policy.
- Firestore: CRUD, indexes, databases (remote MCP variant GA Mar 2026).
- Storage, Realtime DB.
- Cloud Functions logs.
- FCM (push).
- **Crashlytics (Experimental)** — issues, events, reports, notes. Not subject to SLA or deprecation policy; expect breaking changes.
- Remote Config templates.
- App Hosting backend logs.

### Credentials posture
OAuth via Firebase CLI / ADC. No `FIREBASE_TOKEN` in env.

### Experimental warning
The Crashlytics tool surface is Experimental. The `crashlytics-triager` agent is defensively written; degrade gracefully when tools are absent or change shape.
```

- [ ] **Step 10: Write `_addons/firebase-mcp/files/.mcp.json.fragment`**

```json
{
  "mcpServers": {
    "firebase": {
      "command": "npx",
      "args": ["-y", "firebase-tools@latest", "mcp"]
    }
  }
}
```

- [ ] **Step 11: Write `_addons/firebase-mcp/files/.claude/agents/crashlytics-triager.md`**

```markdown
---
name: crashlytics-triager
description: Triages Firebase Crashlytics issues for a mobile app. Reads top issues by frequency / impact, fetches sample events, maps to source code (if symbols are uploaded).
tools: Read, Bash, Glob, Grep
---

You triage Crashlytics issues. The Crashlytics MCP surface is Experimental — degrade gracefully when tools are absent or return unexpected shapes.

## Standard flow

1. List top N issues by user-impact (most affected users, last 7d).
2. For each issue: fetch the event sample, examine stack trace, identify the failing module.
3. Cross-reference with the symbol upload state (warn loudly if dSYMs / R8 mapping files are missing for the build).
4. Classify: regression vs known-issue vs noise.
5. Produce a one-paragraph triage per issue plus a remediation pointer.

## Constraints
- Never auto-resolve a Crashlytics issue from this agent.
- Never close issues; that's a human decision.
- If tool calls fail or return malformed data, fall back to documenting the issue ID + last-seen timestamp and ask the user to retry later.
```

- [ ] **Step 12: Write `_addons/sentry-mcp/MODULE.md`**

```markdown
# Module: mobile/addon/sentry-mcp

> Config: `domain.addons` · Depends on: Sentry account.

**What it does.** Wires Sentry's hosted MCP (`mcp.sentry.dev`) into `.mcp.json` via Streamable HTTP + OAuth. The agent gets issue search, breadcrumbs, source-mapped stack traces, releases, replays. Contributes the `mobile-crash-triager` agent.

## Adopt if
- Using Sentry for any mobile target.

## Skip if
- Using Firebase Crashlytics exclusively (still consider Sentry — different strengths).

## Dependencies
- Sentry account, OAuth-capable.

## Install (manual)
1. Append `claude-md.md` to your `CLAUDE.md`.
2. Run `claude mcp add --transport http sentry-mcp https://mcp.sentry.dev/mcp`.
3. OAuth-authenticate.
4. Copy `mobile-crash-triager.md` into `.claude/agents/`.

## Install (assemble.sh)
Add `sentry-mcp` to `domain.addons` and run `./assemble.sh`.

## Remove
- Remove the `## Sentry MCP` section from `CLAUDE.md`.
- `claude mcp remove sentry-mcp`.
- Delete `.claude/agents/mobile-crash-triager.md`.

## Files
- `MODULE.md`
- `claude-md.md`
- `files/.claude/agents/mobile-crash-triager.md`
```

- [ ] **Step 13: Write `_addons/sentry-mcp/claude-md.md`**

```markdown
## Sentry MCP

The agent has access to **Sentry's hosted MCP** at `https://mcp.sentry.dev/mcp` (Streamable HTTP + OAuth). Tools (~20):

- `search_issues`, `search_events`, `get_issue_details`
- Project / team / organization / DSN management
- Releases, session replays
- **Seer** integration — Sentry's AI debugging agent for root-cause analysis

### Credentials posture
OAuth-only, remote hosted. Reference standard post-Anodot. No `SENTRY_AUTH_TOKEN` in env.

### Mobile relevance
Crash issues for iOS/Android SDKs, release tracking for App Store/Play submissions, replay/session triage on production users.
```

- [ ] **Step 14: Write `_addons/sentry-mcp/files/.claude/agents/mobile-crash-triager.md`**

```markdown
---
name: mobile-crash-triager
description: Triages Sentry issues for a mobile app. Searches issues, examines events with source-mapped stacks, correlates with releases.
tools: Read, Bash, Glob, Grep
---

You triage Sentry issues for an iOS / Android / RN / Flutter app.

## Standard flow

1. `search_issues` for the active project — filter by `level:error environment:production last_seen:-7d`.
2. Group by `culprit` (file / module / function).
3. For each group: pick a representative event; examine the stack trace; confirm source maps / dSYMs / Proguard mapping are uploaded for the release.
4. Cross-reference with `releases` — is the regression tied to a specific release?
5. Optionally invoke Seer for root-cause analysis on the top issue.
6. Produce a triage doc: issue → root-cause-hypothesis → remediation pointer.

## Constraints
- Never close Sentry issues from this agent.
- Never mark releases as resolved.
- Document the assumed mapping-upload state; if missing, escalate to `mobile-release-coordinator`.
```

- [ ] **Step 15: Run tests**

Run: `./templates/tests/run.sh` (full suite)
Expected: all PASS, counts up by at least 4 addons × multiple files.

- [ ] **Step 16: Commit**

```bash
git add templates/mobile/_addons/xcodebuild-mcp/ \
        templates/mobile/_addons/expo-mcp/ \
        templates/mobile/_addons/firebase-mcp/ \
        templates/mobile/_addons/sentry-mcp/
git commit -m "feat(mobile): mobile MCP addons (xcodebuild, expo, firebase, sentry)"
```

---

### Task 11: E2E testing addons (maestro-e2e, patrol-flutter)

**Files:** Same shape as Task 10, one tree per addon.

- [ ] **Step 1: Write `_addons/maestro-e2e/MODULE.md`**

```markdown
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
```

- [ ] **Step 2: Write `_addons/maestro-e2e/claude-md.md`**

```markdown
## Maestro E2E

`maestro` is the 2026 cross-platform E2E tool — adopted by Microsoft, Meta, DoorDash. Declarative YAML flows, robust to UI changes.

### Flow conventions
- One file per user journey under `.maestro/<journey>.yaml`.
- Use `testID` (RN) / accessibility identifiers (native) / Semantics labels (Flutter) as selectors.
- Prefer `tapOn` with text labels for hardiness; avoid coordinates.

### Running
- Local: `maestro test .maestro/login.yaml`.
- Studio: `maestro studio` for interactive flow authoring.
- Cloud: `maestro cloud --apiKey $MAESTRO_API_KEY` for parallel cross-device runs.

### Maestro MCP
A Maestro MCP shipped Feb 2026. When wired, the agent can boot device, run flows, and read structured pass/fail output without shelling out. Treat it as preferred when available.
```

- [ ] **Step 3: Write `_addons/maestro-e2e/files/.claude/skills/maestro-flow-author/SKILL.md`**

```markdown
---
name: maestro-flow-author
description: Author Maestro YAML flows — selectors, gestures, assertions, app launch/state setup.
---

# Authoring a Maestro flow

## Inputs

- The user journey ("user logs in with email", "user adds item to cart").
- The app's identifier (`bundleId` iOS, `appId` Android).

## Pattern

```yaml
appId: com.example.myapp
---
- launchApp:
    clearState: true
- tapOn: "Sign in"
- inputText: "user@example.com"
- tapOn:
    id: "password-input"
- inputText: "correct-horse-battery-staple"
- tapOn: "Continue"
- assertVisible: "Welcome back, user@example.com"
```

## Constraints
- Always start with `clearState: true` for deterministic runs.
- Always use `id:` or `text:` selectors; never coordinates.
- Use `extendedWaitUntil` for network-bound flows.
- For each Maestro command, see <https://maestro.mobile.dev/api-reference/commands>.

## Output
A working `.maestro/<journey>.yaml` plus a one-line description of the flow.
```

- [ ] **Step 4: Write `_addons/patrol-flutter/MODULE.md`**

```markdown
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
```

- [ ] **Step 5: Write `_addons/patrol-flutter/claude-md.md`**

```markdown
## Patrol (Flutter E2E)

Patrol extends Flutter's `integration_test` with native automation via UIAutomator (Android) + XCUITest (iOS):

- Tap native permission dialogs (`grantNotificationPermission`, `grantLocationPermission`).
- Toggle Settings (Wi-Fi, Bluetooth, Airplane Mode).
- Pull down notifications and tap them.
- Interact with other apps (deep links from email, share extensions).

### Running
- `patrol test --target integration_test/login_test.dart`.
- `patrol develop` for incremental dev loop.

### Conventions
- One file per integration journey under `integration_test/`.
- Use `patrolTest` (not `testWidgets`) for any flow needing native automation.
- Pump UI with `await $.pumpAndSettle()` consistently.
```

- [ ] **Step 6: Write `_addons/patrol-flutter/files/.claude/skills/patrol-flow-author/SKILL.md`**

```markdown
---
name: patrol-flow-author
description: Author Patrol integration tests for Flutter — UI + native automation interleaved.
---

# Authoring a Patrol integration test

## Pattern

```dart
import 'package:patrol/patrol.dart';
import 'package:my_app/main.dart' as app;

void main() {
  patrolTest(
    'user signs in and allows notifications',
    ($) async {
      app.main();
      await $.pumpAndSettle();

      await $(#emailField).enterText('user@example.com');
      await $(#passwordField).enterText('correct-horse-battery-staple');
      await $(#continueButton).tap();

      // Native permission dialog
      await $.native.grantPermissionWhenInUse();

      expect($('Welcome back'), findsOneWidget);
    },
  );
}
```

## Constraints
- Use `$` (PatrolTester) finder API, not raw `find.byKey()`.
- Use `Key('emailField')` and reference as `$(#emailField)` for hardiness.
- Always `pumpAndSettle()` after navigation.

Reference: <https://patrol.leancode.co/>.
```

- [ ] **Step 7: Run tests**

Run: `./templates/tests/run.sh`
Expected: all PASS.

- [ ] **Step 8: Commit**

```bash
git add templates/mobile/_addons/maestro-e2e/ templates/mobile/_addons/patrol-flutter/
git commit -m "feat(mobile): E2E testing addons (maestro-e2e, patrol-flutter)"
```

---

### Task 12: Build & distribution addons (eas-build, fastlane)

- [ ] **Step 1: Write `_addons/eas-build/MODULE.md`**

```markdown
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
```

- [ ] **Step 2: Write `_addons/eas-build/claude-md.md`**

```markdown
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
```

- [ ] **Step 3: Write `_addons/eas-build/files/eas.json`**

```json
{
  "cli": {
    "version": ">=14.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": { "simulator": true }
    },
    "preview": {
      "distribution": "internal",
      "channel": "preview"
    },
    "production": {
      "channel": "production",
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {
      "ios": {},
      "android": {
        "track": "internal"
      }
    }
  }
}
```

- [ ] **Step 4: Write `_addons/eas-build/files/.claude/agents/eas-release-coordinator.md`**

```markdown
---
name: eas-release-coordinator
description: Coordinates EAS Build/Submit/Update releases. Inspects safety.two_key; refuses store-upload without typed token.
tools: Read, Write, Edit, Bash, Glob, Grep
---

You coordinate Expo releases for an Expo project.

## Process

1. Read `harness.config.yml` `safety.two_key`. If false, warn that store-upload commands will proceed without a typed-token gate.
2. Bump `version` + `ios.buildNumber` + `android.versionCode` in `app.config.ts` / `app.json`.
3. Decide OTA vs binary via `npx expo prebuild --check`.
4. If OTA: `eas update --branch production --message "<changelog summary>"`.
5. If binary: `eas build --profile production --platform all`, then await success, then `eas submit --profile production --platform all`.
6. **Before invoking `eas submit`**: refuse unless `safety.two_key=true` OR the user has typed the release token. Print the typed-token prompt instead.

## Constraints
- Never bypass `two_key` for store-upload commands.
- Never check `eas.json` `credentials` into source with raw secrets.
- Always cite the EAS Build URL when reporting a build.
```

- [ ] **Step 5: Write `_addons/fastlane/MODULE.md`**

```markdown
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
```

- [ ] **Step 6: Write `_addons/fastlane/claude-md.md`**

```markdown
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
```

- [ ] **Step 7: Write `_addons/fastlane/files/fastlane/Fastfile`**

```ruby
# Fastfile — see https://docs.fastlane.tools

default_platform(:ios)

before_all do |lane, options|
  if [:release, :production].include?(lane)
    UI.user_error!("Store-upload lane requires safety.two_key=true or TWO_KEY_TOKEN env. See claude-md.md.") unless ENV["TWO_KEY_TOKEN"]
  end
end

platform :ios do
  lane :beta do
    match(type: "appstore", readonly: true)
    build_app(scheme: ENV["IOS_SCHEME"] || "App", configuration: "Release")
    upload_to_testflight(skip_waiting_for_build_processing: true)
  end

  lane :release do
    match(type: "appstore", readonly: true)
    build_app(scheme: ENV["IOS_SCHEME"] || "App", configuration: "Release")
    upload_to_app_store(submit_for_review: false, automatic_release: false)
  end

  lane :screenshots do
    capture_screenshots
    frame_screenshots
  end
end

platform :android do
  lane :internal do
    gradle(task: "bundle", build_type: "Release")
    upload_to_play_store(track: "internal", aab: "app/build/outputs/bundle/release/app-release.aab")
  end

  lane :production do
    gradle(task: "bundle", build_type: "Release")
    upload_to_play_store(track: "production", aab: "app/build/outputs/bundle/release/app-release.aab")
  end

  lane :screenshots do
    capture_android_screenshots
  end
end
```

- [ ] **Step 8: Write `_addons/fastlane/files/fastlane/Appfile`**

```ruby
# Appfile — see https://docs.fastlane.tools/advanced/Appfile

app_identifier(ENV["IOS_BUNDLE_ID"] || "com.example.app")
apple_id(ENV["APPLE_ID"] || "you@example.com")
team_id(ENV["APPLE_TEAM_ID"] || "ABCDE12345")

package_name(ENV["ANDROID_PACKAGE_NAME"] || "com.example.app")
json_key_file(ENV["GOOGLE_PLAY_JSON_KEY_PATH"] || File.expand_path("~/.config/play-service-account.json"))
```

- [ ] **Step 9: Write `_addons/fastlane/files/fastlane/Matchfile`**

```ruby
# Matchfile — see https://docs.fastlane.tools/actions/match/

git_url(ENV["MATCH_GIT_URL"] || "git@github.com:your-org/your-match-repo.git")
storage_mode("git")
type("development")  # change per lane via match(type: …)
app_identifier([ENV["IOS_BUNDLE_ID"] || "com.example.app"])
username(ENV["APPLE_ID"] || "you@example.com")
```

- [ ] **Step 10: Write `_addons/fastlane/files/.claude/skills/fastlane-lane-author/SKILL.md`**

```markdown
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
```

- [ ] **Step 11: Run tests**

Run: `./templates/tests/run.sh`
Expected: all PASS.

- [ ] **Step 12: Commit**

```bash
git add templates/mobile/_addons/eas-build/ templates/mobile/_addons/fastlane/
git commit -m "feat(mobile): build & distribution addons (eas-build, fastlane)"
```

---

### Task 13: Compliance scaffold addons (privacy-manifest-ios, play-data-safety)

- [ ] **Step 1: Write `_addons/privacy-manifest-ios/MODULE.md`**

```markdown
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
```

- [ ] **Step 2: Write `_addons/privacy-manifest-ios/claude-md.md`**

```markdown
## PrivacyInfo.xcprivacy (iOS privacy manifest)

Mandatory for App Store submissions since May 1, 2024. App and every third-party SDK must ship one.

### Required Reason API categories
Declare each API used with an Apple-approved reason code:
- `UserDefaults` (typical reason: `CA92.1` — access to user defaults belonging to the app).
- `NSPrivacyAccessedAPICategoryFileTimestamp` (`C617.1`, `0A2A.1`).
- `NSPrivacyAccessedAPICategorySystemBootTime` (`35F9.1`, `8FFB.1`).
- `NSPrivacyAccessedAPICategoryDiskSpace` (`E174.1`, `85F4.1`).
- `NSPrivacyAccessedAPICategoryActiveKeyboards` (`3EC4.1`, `54BD.1`).

### Other keys
- `NSPrivacyTracking` — true if the app does ATT-defined tracking.
- `NSPrivacyTrackingDomains` — list of domains used for tracking (auto-blocked without ATT consent).
- `NSPrivacyCollectedDataTypes` — every data type collected.

### SDK signed manifests
Since Feb 12, 2025, third-party SDKs on Apple's "commonly used SDKs" list must ship signed manifests. Xcode upload fails otherwise.

The `privacy-manifest-author` agent walks through gap-checking your project's manifest vs the APIs you actually reference.
```

- [ ] **Step 3: Write `_addons/privacy-manifest-ios/files/PrivacyInfo.xcprivacy`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

- [ ] **Step 4: Write `_addons/privacy-manifest-ios/files/.claude/agents/privacy-manifest-author.md`**

```markdown
---
name: privacy-manifest-author
description: Walks through filling in PrivacyInfo.xcprivacy by gap-checking actual API usage in source vs declared Required Reason API entries.
tools: Read, Write, Edit, Glob, Grep
---

You audit and complete `PrivacyInfo.xcprivacy`.

## Process

1. Read existing `PrivacyInfo.xcprivacy` (parse the plist).
2. Grep the iOS source tree for each Required Reason API: `UserDefaults`, `FileManager.attributesOfItem`, `mach_absolute_time` / `kern.boottime`, `NSFileSystemFreeSize`, `UITextInputMode.activeInputModes`.
3. For each API found in source: confirm a matching `NSPrivacyAccessedAPIType` entry with at least one approved reason code.
4. Grep for tracking domains in source (URL constants); confirm each appears in `NSPrivacyTrackingDomains`.
5. Walk through `NSPrivacyCollectedDataTypes` interactively: ask "do you collect <category>? what for? linked to user identity?".
6. Save the updated manifest.

## Constraints
- Never invent a reason code; only use Apple-approved codes from <https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api>.
- Never set `NSPrivacyTracking=false` if `NSPrivacyTrackingDomains` is non-empty.
```

- [ ] **Step 5: Write `_addons/play-data-safety/MODULE.md`**

```markdown
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
```

- [ ] **Step 6: Write `_addons/play-data-safety/claude-md.md`**

```markdown
## Play Data Safety

Google Play "Data safety" form is required for every app. The form must match actual SDK behavior, including third-party SDKs.

### Required answers
- Data types collected (per category).
- Data types shared (per category).
- Collection purposes.
- Optional vs required collection.
- **Encryption-in-transit attestation** — "all user data transferred over a secure connection."
- **Deletion-request URL** field.
- **In-app AND out-of-app** account/data deletion paths.

### Generative AI labeling
If the app uses generative AI:
- Label AI-generated content visibly in-app.
- Implement an in-app report/flag UI for offensive output.
- Document red-team approach (SAIF + OWASP GenAI Red Teaming Guide).

The `data-safety-author` agent walks through the form and saves your answers to `play-data-safety.md` for traceability.
```

- [ ] **Step 7: Write `_addons/play-data-safety/files/play-data-safety.md`**

```markdown
# Play Data Safety — Answers Worksheet

> Fill this before submitting to Play. Source of truth; mirror into Play Console.

## Data types collected

- [ ] Approximate location · Purpose: …
- [ ] Precise location · Purpose: …
- [ ] Name · Purpose: …
- [ ] Email address · Purpose: …
- [ ] User IDs · Purpose: …
- [ ] Phone number · Purpose: …
- [ ] Other personally identifiable info · Purpose: …
- [ ] Photos · Purpose: …
- [ ] Videos · Purpose: …
- [ ] Audio files · Purpose: …
- [ ] Files and docs · Purpose: …
- [ ] Calendar events · Purpose: …
- [ ] Contacts · Purpose: …
- [ ] App interactions · Purpose: …
- [ ] In-app search history · Purpose: …
- [ ] Installed apps · Purpose: …
- [ ] Other user-generated content · Purpose: …
- [ ] Web browsing history · Purpose: …
- [ ] Other actions · Purpose: …
- [ ] Crash logs · Purpose: …
- [ ] Diagnostics · Purpose: …
- [ ] Other app performance data · Purpose: …
- [ ] Device or other IDs · Purpose: …

## Data shared
(same categories — list those shared with third parties)

## Security practices

- [ ] All user data is encrypted in transit
- [ ] Users can request that their data be deleted

## Deletion

- **Deletion-request URL**: `https://example.com/delete-account`
- **In-app deletion path**: Settings → Account → Delete account
- **Out-of-app deletion**: deletion-request URL above

## Generative AI

- [ ] App uses generative AI features
- [ ] AI-generated content is labeled in-app
- [ ] In-app report/flag UI present
- [ ] Red-team approach documented (SAIF + OWASP GenAI Red Teaming)
```

- [ ] **Step 8: Write `_addons/play-data-safety/files/.claude/agents/data-safety-author.md`**

```markdown
---
name: data-safety-author
description: Walks through the Play Console Data safety form; saves answers to play-data-safety.md.
tools: Read, Write, Edit, Glob, Grep
---

You walk through the Play Console "Data safety" form with the developer.

## Process

1. Read `play-data-safety.md`.
2. Grep the Android source for each data category — `Location`, `Email`, `Phone`, `Photos`, `Contacts`, etc.
3. For each category found in source: ask "what purpose? optional or required? shared with third parties?" and check the matching boxes.
4. Verify the encryption-in-transit attestation (any non-HTTPS endpoint flips it false).
5. Verify the deletion-request URL is set and reachable.
6. Verify in-app + out-of-app deletion paths.
7. If LLM calls referenced anywhere, walk the generative-AI labeling + report-flag UI checklist.
8. Save the completed worksheet; remind the user to mirror into Play Console manually (no first-party MCP for Play Console exists in May 2026).

## Constraints
- Never claim a category is "not collected" without grepping the source.
- Never approve a release without the deletion-request URL set.
```

- [ ] **Step 9: Run full test suite**

Run: `./templates/tests/run.sh`
Expected: all PASS.

- [ ] **Step 10: Commit**

```bash
git add templates/mobile/_addons/privacy-manifest-ios/ templates/mobile/_addons/play-data-safety/
git commit -m "feat(mobile): compliance scaffold addons (privacy-manifest-ios, play-data-safety)"
```

---

### Task 14: Extend assemble-coverage to discover mobile

**Files:**
- Modify: `templates/tests/checks/assemble-coverage.sh`

- [ ] **Step 1: Read the current test runner**

Run: `grep -n 'web devops data' templates/tests/checks/assemble-coverage.sh; grep -n 'web/_addons devops/_addons data/_addons' templates/tests/checks/assemble-coverage.sh; grep -n 'analytics-engineering' templates/tests/checks/assemble-coverage.sh`
Expected output: lines that include the three existing curated packs.

- [ ] **Step 2: Add `mobile` to the curated-pack find expression**

Find: `find web devops data -mindepth 2 -maxdepth 2 -name 'harness.config.yml'`
Replace with: `find web devops data mobile -mindepth 2 -maxdepth 2 -name 'harness.config.yml'`

- [ ] **Step 3: Add `mobile` to the addons find expression**

Find: `find web/_addons devops/_addons data/_addons -mindepth 1 -maxdepth 1 -type d`
Replace with: `find web/_addons devops/_addons data/_addons mobile/_addons -mindepth 1 -maxdepth 1 -type d`

- [ ] **Step 4: Add the case statement entry for the probe-host-for-pack helper**

Find the line: `data)   echo "data/analytics-engineering" ;;`
Add immediately after: `mobile) echo "mobile/react-native-expo" ;;`

The new case statement covers selecting the "headline" sub-domain for each curated pack when the runner needs to probe combos against a representative sub-domain.

- [ ] **Step 5: Run the suite**

Run: `./templates/tests/run.sh`
Expected: assemble-coverage passes with count up sharply (mobile contributes 4 sub-domains × at least 1 combo each, plus 10 addons × individual checks).

- [ ] **Step 6: Commit**

```bash
git add templates/tests/checks/assemble-coverage.sh
git commit -m "test: extend assemble-coverage discovery to include mobile pack"
```

---

### Task 15: Public-doc flip (domains.md, pick-a-recipe.md, HARNESS_ENGINEERING.md)

**Files:**
- Modify: `docs/reference/domains.md`
- Modify: `docs/how-to/pick-a-recipe.md`
- Modify: `docs/HARNESS_ENGINEERING.md`

- [ ] **Step 1: Edit `docs/reference/domains.md`**

a. In the domain-status table, change the `mobile` row's status from `v1 thin recipe` to `curated (3-layer)`.

b. Add a new section `## The mobile/ pack (curated)` after `## The data/ pack (curated)` (or wherever data sits). Structure:

```markdown
## The mobile/ pack (curated)

Four sub-domains, ten addons, three shared agents, two shared hooks. Choose the sub-domain by team composition + platform targets (see [`templates/mobile/DOMAIN.md`](../../templates/mobile/DOMAIN.md)).

### Sub-domains

| Sub-domain | Stack | Default addons |
|---|---|---|
| `native-ios` | Swift 6.2 + SwiftUI + SwiftData + Swift Testing | xcodebuild-mcp, sentry-mcp, privacy-manifest-ios, fastlane |
| `native-android` | Kotlin 2.x + Compose + Hilt+KSP | firebase-mcp, sentry-mcp, fastlane, play-data-safety |
| `react-native-expo` | Expo SDK 54+ + RN 0.81+ + Expo Router v6 + EAS | xcodebuild-mcp, expo-mcp, sentry-mcp, eas-build, maestro-e2e, privacy-manifest-ios, play-data-safety |
| `flutter-app` | Flutter 3.27+ + Riverpod + Patrol | xcodebuild-mcp, firebase-mcp, sentry-mcp, patrol-flutter, privacy-manifest-ios, play-data-safety |

### Addon categories

- **MCPs**: xcodebuild-mcp, expo-mcp, firebase-mcp, sentry-mcp.
- **E2E testing**: maestro-e2e, patrol-flutter.
- **Build & distribution**: eas-build, fastlane.
- **Compliance scaffolds**: privacy-manifest-ios, play-data-safety.

### Out of v1 (deferred)

- Kotlin Multiplatform / Compose Multiplatform sub-domain.
- Bitrise MCP, MobSF MCP — credential posture gap.
- App Store Connect / Play Console first-party MCP — none exist as of May 2026.
- Wearables / TV / VisionOS — pick a base sub-domain and document the secondary target.
```

c. Remove `mobile` from the `## The v1 thin recipes` list.

- [ ] **Step 2: Edit `docs/how-to/pick-a-recipe.md`**

Add a new section `## Question — Which mobile sub-domain?` after the data sub-domain question (or wherever data's question lives). Structure:

```markdown
## Question — Which mobile sub-domain?

Pick by team composition and platform targets.

- **JS / TS team, cross-platform iOS + Android** → `react-native-expo`. Deepest AI-tooling MCP coverage in 2026; OTA via EAS Update.
- **Native team, iOS-only or iOS-first** → `native-ios`. Foundation Models, App Intents, deep Apple Intelligence integration.
- **Native team, Android-only or Android-first** → `native-android`. Gemini Nano / AICore, foreground services, Photo Picker.
- **Design-led cross-platform with heavy custom animation** → `flutter-app`. Impeller render performance; Riverpod state.

If you need shared business logic with platform-native UI per OS, build with `native-ios` + `native-android` and document the shared layer manually; the Kotlin Multiplatform sub-domain is a v2 graduation target.
```

- [ ] **Step 3: Edit `docs/HARNESS_ENGINEERING.md`**

Find the section §2 (Domain pack engineering guide). Add a new sub-section §2.11 (or whatever number follows the existing data sub-section) titled `Mobile — sub-domains by stack family, not by platform`:

```markdown
### 2.11 Mobile — sub-domains by stack family, not by platform

The mobile pack decomposes by *stack family* (native-ios, native-android, react-native-expo, flutter-app), not by platform (iOS / Android). This is deliberate.

A 2026 mobile project's harness is shaped by its toolchain (Xcode vs Gradle vs Expo CLI vs Flutter CLI), its UI framework (SwiftUI vs Compose vs RN+Expo-Router vs Flutter-Widget), its test runner (Swift Testing vs JUnit vs Jest+Maestro vs flutter_test+Patrol), and its distribution path (TestFlight via fastlane vs Play Internal via fastlane vs EAS Submit vs EAS Submit). Platform (iOS vs Android) is orthogonal — cross-platform stacks ship to both, native stacks ship to one.

Stack-family decomposition keeps the agent's mental model coherent: one sub-domain's `claude-md.md` covers the *whole* development loop end-to-end. A platform-decomposed pack would force every cross-platform stack into two recipes (the iOS path and the Android path) and miss the shared truths (Expo Router structure is the same on both; Compose Multiplatform UI lives in `commonMain`).

Compliance scaffolds (privacy-manifest-ios, play-data-safety) are platform-shaped addons that layer on top of any sub-domain. The pack documents which addons each sub-domain defaults-on for which platform (iOS-targeting sub-domains get privacy-manifest-ios, Android-targeting sub-domains get play-data-safety, cross-platform sub-domains get both).
```

- [ ] **Step 4: Run tests + structure-lint**

Run: `./templates/tests/run.sh`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add docs/reference/domains.md docs/how-to/pick-a-recipe.md docs/HARNESS_ENGINEERING.md
git commit -m "docs: flip mobile to curated 3-layer pack; document stack-family decomposition"
```

---

### Task 16: README quickstart + glossary touch

**Files:**
- Modify: `templates/README.md`
- Modify: `docs/reference/glossary.md` (only if a stale-prose item is found)
- Modify: `docs/reference/harness-config.md` (only if a stale-prose item is found)

- [ ] **Step 1: Update `templates/README.md` quickstart**

Find: `./assemble.sh data/ml-pipeline/harness.config.yml ./my-ml-project  # curated data sub-domain`

Add after that line:

```
./assemble.sh mobile/react-native-expo/harness.config.yml ./my-rn-app  # curated mobile sub-domain
```

Update the layout block: change `data/ devops/` line to `data/ devops/ mobile/` and remove `mobile/` from the v1 thin-recipe list. Restructure:

Find: `data/ devops/                                                 curated three-layer packs`
Replace with: `data/ devops/ mobile/                                        curated three-layer packs`

Find: `finance/ mobile/ game/ embedded/ scientific/ security/`
Replace with: `finance/ game/ embedded/ scientific/ security/`

- [ ] **Step 2: Check glossary for stale "only web/data/devops" prose**

Run: `grep -n 'only web' docs/reference/glossary.md docs/reference/harness-config.md`
If matches found, edit each to include `mobile` in the relevant list.

Look for sentences like "`web/`, `devops/`, and `data/` ship addons today" or "Today `web/`, `devops/`, and `data/` are three-layer packs". Update to include `mobile/`.

- [ ] **Step 3: Check the Recipe glossary entry for the v1 thin-recipe count**

Find lines that mention "Eleven domains are thin recipes" or "the v1 thin recipes (eight domains)" — update count to reflect the new total after mobile graduates (was 8 → now 7).

- [ ] **Step 4: Run tests**

Run: `./templates/tests/run.sh`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add templates/README.md docs/reference/glossary.md docs/reference/harness-config.md
git commit -m "docs: README quickstart + glossary touches for mobile graduation"
```

---

### Task 17: Retire v1 thin recipe

**Files:**
- Delete: `templates/mobile/harness.config.yml`
- Delete: `templates/mobile/claude-md.md`
- Delete: `templates/mobile/README.md`
- Modify: `templates/tests/checks/assemble-coverage.sh`

- [ ] **Step 1: Delete the three v1 thin-recipe files**

Run:
```bash
git rm templates/mobile/harness.config.yml templates/mobile/claude-md.md templates/mobile/README.md
```

- [ ] **Step 2: Remove `mobile` from the thin-recipe loop in `assemble-coverage.sh`**

Find: `for d in generic finance mobile game embedded scientific security content ops; do`
Replace with: `for d in generic finance game embedded scientific security content ops; do`

- [ ] **Step 3: Run the full test suite**

Run: `./templates/tests/run.sh`
Expected: all PASS. Counts higher than cycle-1 baseline across the board (assemble-coverage, hook-lint, structure-lint).

- [ ] **Step 4: Final commit**

```bash
git add templates/mobile templates/tests/checks/assemble-coverage.sh
git commit -m "feat: retire v1 thin mobile recipe in favor of curated pack"
```

- [ ] **Step 5: Final cycle-closing test run**

Run: `./templates/tests/run.sh && git log --oneline -20`
Expected: all PASS; the 17 cycle-2 commits visible at the head, plus the cycle-1 commits below them.

---

## Self-review checklist

After all 17 tasks are committed:

- [ ] Every spec requirement (§§ 1–14) of `docs/superpowers/specs/2026-05-22-mobile-domain-pack-design.md` maps to at least one task above.
- [ ] No placeholder text (`TBD`, `TODO`, "implement later") remains anywhere in the plan.
- [ ] Type / name consistency: agent names referenced in the same `harness.config.yml include:` lists match the files actually created (e.g., `crashlytics-triager` in addon vs sub-domain).
- [ ] Task 5 is a checkpoint that may produce no commit if `verifying-on-simulator/SKILL.md` already exists at the target path; that's expected.
- [ ] Task 14's case statement uses `react-native-expo` as the headline sub-domain for the mobile pack (data's headline was `analytics-engineering`).
- [ ] Task 16 only edits glossary / harness-config docs *if* stale "only web/data/devops" prose is actually present; do not invent edits.
- [ ] The retire task (17) removes both the directory files AND the thin-recipe loop reference.

## Expected post-cycle test counts

- `assemble-coverage.sh`: >> 77 (cycle 1 baseline + at least 10 new addons + 4 new sub-domains).
- `hook-lint.sh`: 104+ (cycle 1's 102 + 2 new mobile hooks).
- `structure-lint.sh`: >> 215 (cycle 1's 215 + many new MODULE.md/SUBDOMAIN.md/agent files).

All three suites must run green at end of Task 17.
