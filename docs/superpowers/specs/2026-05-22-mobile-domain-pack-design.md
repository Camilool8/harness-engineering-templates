# Mobile domain pack — design

**Author:** maintainer (cycle 2 of the thin-recipe graduation roadmap)
**Status:** draft for approval
**Verified:** 2026-05
**Supersedes:** the v1 thin recipe at `templates/mobile/`

---

## 1. Goal

Graduate `templates/mobile/` from a single-`harness.config.yml` v1 thin recipe to a curated three-layer domain pack (domain → sub-domain → addons), matching the shape already shipped for `web/`, `devops/`, and `data/`.

The pack must let an AI-assisted everyday developer (Claude Code / Cursor / Copilot) assemble a working harness for any of the four 2026 stack families — native iOS, native Android, React Native + Expo, Flutter — with the addon constellation needed to actually ship an app to the App Store and Google Play in 2026.

It must not over-curate: the pack ships what is *settled* in 2026 (Compose default on Android, SwiftUI default on iOS, Expo as the RN entrypoint, Impeller on Flutter), and stops short of stack-family wars (KMP shared UI vs CMP shared UI vs native — left as references/notes, not as an addon).

---

## 2. Architecture

Three layers, same mechanics as `web/`, `devops/`, `data/`:

```
templates/mobile/
├── DOMAIN.md                     # decision guide: which sub-domain + which addons
├── domain.claude-md.md           # shared rules (≤30 lines) applied to all sub-domains
├── references.md                 # dossier (5+ cited 2026 links)
├── files/
│   ├── .mcp.json.fragment        # empty by design (sub-domain/addon MCPs layer in)
│   └── .claude/
│       ├── context7.mcp.json.fragment
│       ├── settings.fragment.json
│       ├── hooks/
│       │   ├── audit-log-mobile-build.sh
│       │   └── block-static-store-creds.sh
│       ├── agents/
│       │   ├── app-store-compliance-auditor.md
│       │   ├── mobile-release-coordinator.md
│       │   └── mobile-ux-screenshot-critic.md
│       └── skills/
│           └── verifying-on-simulator/SKILL.md  # promoted from v1 thin recipe
├── _addons/
│   ├── xcodebuild-mcp/
│   ├── expo-mcp/
│   ├── firebase-mcp/
│   ├── sentry-mcp/
│   ├── maestro-e2e/
│   ├── patrol-flutter/
│   ├── eas-build/
│   ├── fastlane/
│   ├── privacy-manifest-ios/
│   └── play-data-safety/
├── native-ios/
├── native-android/
├── react-native-expo/
└── flutter-app/
```

The v1 thin-recipe artifacts (`harness.config.yml`, `claude-md.md`, `README.md` at `templates/mobile/`) get removed by the closing task of the cycle.

---

## 3. Sub-domain decomposition

Four sub-domains, each mapping to a 2026 stack family with deep AI-tooling support:

| Sub-domain | Adopt if… | Skip if… | Default `two_key` |
|---|---|---|---|
| `native-ios` | You're shipping a Swift/SwiftUI app to the App Store, want maximum platform integration (Foundation Models, App Intents), and have an iOS-only or iOS-first team. | You also need Android — pick `react-native-expo` or `flutter-app` instead. | `false` (set true once EAS/fastlane upload is wired into autonomous loops) |
| `native-android` | You're shipping a Kotlin/Compose app to Google Play, want maximum Android integration (Gemini Nano / AICore, foreground services, Health Connect), and have an Android-only or Android-first team. | You also need iOS — pick `react-native-expo` or `flutter-app` instead. | `false` |
| `react-native-expo` | You're shipping cross-platform to iOS + Android with a JavaScript/TypeScript team, want deepest AI-tooling MCP coverage (XcodeBuildMCP + Expo MCP + Sentry MCP + Firebase MCP), and want OTA JS updates via EAS Update. | You need pixel-perfect platform UI per OS, or you need shared business logic with native UI per OS (use `native-ios` + `native-android`, or KMP — see §11.4). | `false` |
| `flutter-app` | You want maximum render performance and pixel-perfect uniform UI across iOS + Android, you're shipping heavy custom animation or design-system parity, and you have or are building Dart expertise. | You need OTA JS updates (use `react-native-expo`), or you need first-class on-device Apple Intelligence / Gemini Nano APIs (use native). | `false` |

**Decision rule encoded in `DOMAIN.md`:** "Pick by team composition, not by framework popularity. JS team → `react-native-expo`. Native team with iOS-only → `native-ios`. Native team with Android-only → `native-android`. Design-led cross-platform with custom animation → `flutter-app`."

Kotlin Multiplatform (with shared business logic + native UI) and Compose Multiplatform 1.11+ (with shared UI) are powerful 2026 options but reshape project structure too deeply to ship as an addon in v1. They are documented in `references.md` and DOMAIN.md as graduation targets for v2; out-of-scope here.

---

## 4. Addon catalog

Ten addons across four categories. Each follows the established addon shape (`MODULE.md`, `claude-md.md`, `files/`, optional `.mcp.json.fragment`).

### 4.1 Mobile MCPs (4)

| Addon | What it adds | Default in which sub-domain | Credential posture |
|---|---|---|---|
| `xcodebuild-mcp` | `getsentry/XcodeBuildMCP` + `ios-simulator-mcp` configs; `xcode-simulator-driver` agent. Build, sim boot/install/launch, screenshot, log, test, scheme management. | `native-ios` (default-on), `react-native-expo` (default-on), `flutter-app` (default-on for iOS targets) | Local Xcode keychain only — no remote tokens. Telemetry opt-out flag documented. |
| `expo-mcp` | `https://mcp.expo.dev/mcp` config (Streamable HTTP, OAuth); `eas-workflow-author` skill. EAS Build/Submit/Workflow inspection from Claude. | `react-native-expo` (default-on) | OAuth via Expo accounts. EAS paid plan gate. |
| `firebase-mcp` | `firebase-tools mcp` config; `crashlytics-triager` agent. Auth, Firestore, FCM, Crashlytics (Experimental), Remote Config, App Hosting logs. | `native-android` (default-on), `flutter-app` (default-on) | OAuth via Firebase CLI / ADC. Crashlytics MCP is Experimental — `claude-md.md` warns. |
| `sentry-mcp` | `https://mcp.sentry.dev/mcp` config (Streamable HTTP, OAuth); `mobile-crash-triager` agent. Issue search, breadcrumbs, source-mapped stacks, releases, replays. | All four sub-domains (default-on) — Sentry is the reference standard post-Anodot. | OAuth-only, remote hosted. |

### 4.2 E2E testing (2)

| Addon | What it adds | Default in which sub-domain |
|---|---|---|
| `maestro-e2e` | `mobile.dev/maestro` CLI install hooks; `maestro-flow-author` skill (write `.yaml` flows); Maestro MCP config when present. | `react-native-expo` (default-on), `native-ios` (opt-in), `native-android` (opt-in) |
| `patrol-flutter` | `leancodepl/patrol` install hooks for `pubspec.yaml`; `patrol-flow-author` skill (write `integration_test/` flows with native automation). | `flutter-app` (default-on) |

### 4.3 Build & distribution (2)

| Addon | What it adds | Default in which sub-domain |
|---|---|---|
| `eas-build` | `eas.json` template (production / preview / development profiles); `eas-release-coordinator` agent; EAS Submit + Update guidance in `claude-md.md`. | `react-native-expo` (default-on) |
| `fastlane` | `Fastfile` + `Appfile` + `Matchfile` templates; `fastlane-lane-author` skill. Wraps signing (`match`), screenshots (`snapshot`), App Store upload (`deliver`), Play upload (`supply`). | `native-ios` (default-on), `native-android` (default-on), `flutter-app` (opt-in) |

### 4.4 Compliance scaffolds (2)

| Addon | What it adds | Default in which sub-domain |
|---|---|---|
| `privacy-manifest-ios` | `PrivacyInfo.xcprivacy` template + Required Reason API helper; `privacy-manifest-author` agent. Covers `UserDefaults` (`CA92.1`), `FileTimestamp`, `SystemBootTime`, `DiskSpace`, `ActiveKeyboards` reason codes plus tracking-domain wiring. | `native-ios` (default-on), `react-native-expo` (default-on), `flutter-app` (default-on for iOS targets) |
| `play-data-safety` | `data-safety-author` agent that walks the developer through the Play Console "Data safety" form: encryption-in-transit, deletion-request URL, account-deletion paths, third-party SDK alignment, generative-AI labeling. | `native-android` (default-on), `react-native-expo` (default-on), `flutter-app` (default-on for Android targets) |

### 4.5 Notes on what is deliberately *not* an addon

- **Kotlin Multiplatform / Compose Multiplatform** — reshapes project structure too deeply for v1; documented in references and DOMAIN.md.
- **AppSweep / MobSF / DexGuard / Detekt / SwiftLint** — invoked via Bash from the agent, no native MCP that ships an OAuth path in May 2026; deferred to v2 when their MCP credential hygiene improves.
- **Bitrise MCP** — PAT-only as of May 2026; flagged in references but not graduated to an addon until OAuth lands. EAS + Fastlane + GitHub Actions cover the same need with OAuth-first MCPs.
- **App Store Connect MCP / Play Console MCP** — no first-party MCP exists in May 2026; teams reach them via EAS Submit, Fastlane `deliver`/`supply`, or `appstoreconnect-api` (Apple's REST API) inside `fastlane`. Documented as a graduation target.

---

## 5. Shared layer artifacts

### 5.1 `DOMAIN.md`

Decision guide with:
- A "Which sub-domain?" flow keyed to team composition + platform targets.
- The 10-addon table grouped by category (§4.1–4.4) with one-line adopt-if statements.
- Pointers to `references.md` for the 2026 dossier and to per-sub-domain `SUBDOMAIN.md`.
- An explicit "What we deliberately don't curate" section pointing at KMP/CMP, Bitrise MCP, and MobSF MCP.

### 5.2 `domain.claude-md.md` (≤30 lines, modulo trailing newline)

Carries the rules every mobile sub-domain inherits:

```markdown
## Mobile rules

### Stack lockdown
- Pick one sub-domain (native-ios, native-android, react-native-expo, flutter-app) and hold to it.
  Do not mix paradigms (e.g. SwiftUI screens with UIKit view-controller patterns) unless the screen
  genuinely requires it.

### Verification (simulator/emulator-in-the-loop)
- After any screen change, run the `verifying-on-simulator` skill: boot device, install, screenshot,
  diff. A UI change is not verified until it has run on a device.
- TDD applies to deterministic code — view models, reducers, networking, formatting. UI verification
  is the simulator/emulator loop, not a unit test.

### Build logs
- Consume build logs as structured/categorized output, never a 3000-line raw log. iOS: XcodeBuildMCP
  parses `xcodebuild` to JSON. Android: parse `gradle --console=plain` or use Gemini Agent Mode's
  structured Logcat readback.

### Store compliance
- Apple Guideline 5.1.2(i) (Nov 13, 2025) requires explicit user consent before personal data is
  sent to any third-party AI (OpenAI, Anthropic, Google Gemini, self-hosted). A privacy-policy link
  is not enough — implement a pre-action consent UI.
- Google Play AI-Generated Content policy requires in-app reporting/flagging of generative output
  and labeling of AI-generated content.

### Credentials posture
- Prefer OAuth MCPs (Expo, Firebase, Sentry, GitHub) over PAT/API-key MCPs (Bitrise, MobSF). After
  the April 2026 Anodot/ShinyHunters breach, long-lived broker-held tokens are the new weakest link.

### Never do
- Never claim a UI change works without running it on a simulator/emulator.
- Never ship an AI-data-sharing feature without the 5.1.2(i) consent UI.
- Never paste an App Store Connect API key, Play service account JSON, EXPO_TOKEN, SENTRY_AUTH_TOKEN,
  or FIREBASE_TOKEN into a tool call. The `block-static-store-creds.sh` hook will block such commands.
```

### 5.3 `references.md` dossier (≥5 cited 2026 links)

Header `Verified: 2026-05`. Cross-cuts the four research streams:

1. Apple Developer — Guideline 5.1.2(i) (current App Review Guidelines).
2. Google Play — AI-Generated Content policy.
3. JetBrains Kotlin Blog — Compose Multiplatform 1.11.0 (May 2026).
4. React Native blog — RN 0.84 (Feb 2026).
5. Expo Changelog — SDK 54 / SDK 56 beta.
6. Sentry Blog — Sentry acquires XcodeBuildMCP (Feb 2026).
7. Firebase Blog — Firebase MCP Server GA (Oct 2025).
8. Apple Newsroom — DMA impacts on EU users (Sep 2025).
9. Android Developers — target API level 35 → 36 (Aug 31, 2026 deadline).

Each entry: one-line scope statement + URL.

### 5.4 Shared hooks

Two new hooks, registered in `.claude/settings.fragment.json`:

#### `audit-log-mobile-build.sh` (PostToolUse, exit 0 always)

Appends to `.claude/logs/agent_audit.jsonl` whenever the tool call invokes:
- `xcodebuild`, `xcrun simctl`, `xcrun devicectl`
- `gradle`, `gradlew`, `adb`
- `expo`, `eas`
- `fastlane`, `pod`, `bundle exec fastlane`
- `flutter`, `dart`

One JSON object per invocation: `{ts, tool, command_summary, cwd, exit_code}`. Used for EU AI Act Annex IV + Play console "evidence of testing" workflows. Mirrors the `audit-log-warehouse-query.sh` design from the data pack.

#### `block-static-store-creds.sh` (PreToolUse, exit 2 on hit)

Inspects the tool call for inline credentials matching:
- `APP_STORE_CONNECT_API_KEY_BASE64=…` or `ASC_API_KEY_*=…`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=…` or `*.json` paths under `~/.config/play-service-account*`
- `EXPO_TOKEN=…`
- `SENTRY_AUTH_TOKEN=…`
- `FIREBASE_TOKEN=…`
- `FASTLANE_PASSWORD=…` / `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=…`
- Inline `.p8` / `.p12` content (rough heuristic on private-key headers)

On hit: emit a stderr message naming the credential and exit 2 (PreToolUse blocking).

### 5.5 Shared agents (3)

| Agent | What it does |
|---|---|
| `app-store-compliance-auditor` | Reads the project tree for: 5.1.2(i) AI-disclosure UI, `PrivacyInfo.xcprivacy` completeness, Required Reason API coverage, `INTERNET` + ATT manifest entries, Data Safety form alignment, in-app account deletion. Produces a checklist with red/amber/green per item. Spec-only — does not modify files. |
| `mobile-release-coordinator` | Coordinates a release: version + build number bumps, changelog scaffolding, TestFlight + Internal Testing track choice, store metadata draft, screenshot-set verification. Reads `safety.two_key` from the harness config and enforces it for store-upload commands. |
| `mobile-ux-screenshot-critic` | Given a directory of simulator/emulator screenshots, performs visual review for accessibility (color contrast ≥4.5:1, touch target ≥44pt iOS / 48dp Android, Dynamic Type / large-font tolerance), layout regressions vs a baseline, and locale-bidirectional regressions. |

### 5.6 Promoted shared skill

`verifying-on-simulator` is already shipped by the v1 thin recipe. It is promoted to the new shared layer at `files/.claude/skills/verifying-on-simulator/SKILL.md` and inherited by all four sub-domains. The skill content stays identical; only its location moves.

---

## 6. Per-sub-domain artifacts

Every sub-domain ships `SUBDOMAIN.md`, `harness.config.yml`, `claude-md.md`, `references.md`, `files/.claude/settings.fragment.json`, plus agents and skills below.

### 6.1 `native-ios`

**Stack lockdown:** Swift 6.2 (Approachable Concurrency on by default), SwiftUI primary, `@Observable` + `@State` (no `@StateObject`/`@ObservedObject`), SwiftData for new projects (Core Data documented as escape valve), Swift Testing for unit tests, XCUITest for UI tests, Xcode 26+ build SDK (mandatory for App Store Connect after Apr 28, 2026).

**Default addons:** `xcodebuild-mcp`, `sentry-mcp`, `privacy-manifest-ios`, `fastlane`.

**Agents (4):**
- `ios-architect` — app-shape decisions (module layout, dependency tree, iOS minimum target).
- `swiftui-implementer` — write SwiftUI views + view models with `@Observable`.
- `swift-test-implementer` — write Swift Testing suites + XCUITest flows.
- `xcode-build-resolver` — parse `xcodebuild` errors via XcodeBuildMCP, fix dependency / signing / scheme drift.

**Skills (2):**
- `parsing-xcodebuild-errors` — read structured XcodeBuildMCP error tree, locate the failing target / file / line.
- `foundation-models-app-intent` — wire Apple Intelligence Foundation Models to an App Intent (typed guided generation, tool calls, streaming).

### 6.2 `native-android`

**Stack lockdown:** Kotlin 2.x, Jetpack Compose 1.9+, Hilt 2.56 with KSP (KAPT banned), ViewModel + StateFlow + `collectAsStateWithLifecycle`, target SDK 35 (16 after Aug 31, 2026), Android Studio Otter or newer.

**Default addons:** `firebase-mcp`, `sentry-mcp`, `fastlane`, `play-data-safety`.

**Agents (4):**
- `android-architect` — module layout, Gradle config (KSP, Compose compiler), target/min SDK, Hilt graph.
- `compose-implementer` — write Compose UI with Strong Skipping in mind.
- `android-test-implementer` — Compose UI Test + Espresso + Roborazzi snapshot tests.
- `gradle-build-resolver` — parse `gradle --console=plain` output, resolve dependency conflicts, KSP/KAPT migration nits.

**Skills (2):**
- `parsing-gradle-errors` — turn gradle output into a structured fix list.
- `foreground-service-type-author` — declare correct `foregroundServiceType` per Android 14/15/16 rules, register the matching Play Console "App content" entry.

### 6.3 `react-native-expo`

**Stack lockdown:** Expo SDK 54+ (RN 0.81+), React 19.1+, New Architecture on, Hermes V1, Expo Router v6, EAS Build / Submit / Update, Maestro for E2E.

**Default addons:** `xcodebuild-mcp`, `expo-mcp`, `sentry-mcp`, `eas-build`, `maestro-e2e`, `privacy-manifest-ios`, `play-data-safety`.

**Agents (4):**
- `expo-architect` — Expo project shape, EAS profiles, Expo Router structure (`app/` directory, `+middleware.ts` server middleware).
- `rn-screen-implementer` — write screens + components with React 19 Server Components considerations and Expo Router conventions.
- `rn-test-implementer` — Jest unit tests + Maestro YAML flows.
- `eas-release-resolver` — handle EAS Build errors, decide between EAS Update OTA and native rebuild for a given diff.

**Skills (3):**
- `expo-fast-iteration` — Expo Go vs dev client decision flow, EAS Update vs native rebuild heuristics, precompiled XCFramework cache notes.
- `react-native-new-arch-guardrails` — detect Old-Arch-only libraries, recommend New-Arch-ready replacements.
- `verifying-on-simulator` — *inherited from shared layer; sub-domain's `harness.config.yml` selects it*.

### 6.4 `flutter-app`

**Stack lockdown:** Flutter 3.27+, Dart 3.x, Impeller (iOS-only renderer; Android default API 29+), Riverpod for state (BLoC documented as escape valve for regulated enterprises), Patrol for E2E.

**Default addons:** `xcodebuild-mcp`, `firebase-mcp`, `sentry-mcp`, `patrol-flutter`, `privacy-manifest-ios`, `play-data-safety`.

**Agents (4):**
- `flutter-architect` — project shape, package layout (`features/`, `core/`), Dart linter config, target SDKs.
- `flutter-screen-implementer` — Material 3 + Cupertino widget composition, theme tokens.
- `flutter-test-implementer` — `flutter_test` + Patrol integration tests.
- `riverpod-state-modeler` — Provider/Notifier/AsyncNotifier discipline; one Riverpod scope per feature.

**Skills (2):**
- `flutter-impeller-diagnostics` — read `flutter --enable-impeller` traces, identify shader stutters, decide when to fall back to Skia (Android only).
- `verifying-on-device-flutter` — Flutter-specific simulator/emulator loop with `flutter drive` and screenshot artifact handling.

---

## 7. Default `safety.two_key` posture

All four sub-domains ship with `safety.two_key: false` by default to match the v1 thin recipe's posture and to keep onboarding low-friction for indie/solo developers.

`DOMAIN.md` carries an explicit recommendation: **set `safety.two_key: true` once you wire EAS Submit / fastlane `deliver` / fastlane `supply` / TestFlight Build Upload API into an autonomous loop.** The `mobile-release-coordinator` agent inspects `safety.two_key` and enforces the typed-token gate for store-upload commands.

Rationale: store submissions are functionally irreversible (App Store and Play Store both require new review cycles for emergency rollback), so two-key matches data's `llm-app` posture in spirit — but for mobile the trigger is the *release command*, not the existence of the sub-domain.

---

## 8. MCP credential posture (post-Anodot)

Carries forward the data pack's hard rule from cycle 1, restated for mobile:

| MCP | Posture | Action in this pack |
|---|---|---|
| XcodeBuildMCP | Local only, no remote tokens | Ship without telemetry toggle in domain `claude-md.md`; addon's `claude-md.md` shows the `XCODEBUILDMCP_SENTRY_DISABLED=true` opt-out. |
| Expo MCP | OAuth + Streamable HTTP | Ship as hosted-URL fragment; addon's `claude-md.md` documents `claude mcp add --transport http expo-mcp https://mcp.expo.dev/mcp`. |
| Firebase MCP | OAuth via CLI / ADC | Ship as `firebase-tools mcp` fragment; flag Crashlytics tools as Experimental in `claude-md.md`. |
| Sentry MCP | OAuth + Streamable HTTP, fully remote | Ship as hosted-URL fragment; mark as the reference standard. |
| Maestro MCP | Local CLI driver | No remote token; addon ships install hooks. |
| Bitrise MCP | PAT-only (gap) | **Not graduated.** Documented in `references.md` as a deferred addon awaiting OAuth. |
| MobSF MCP | API-key (gap) | **Not graduated.** Documented in `references.md` likewise. |

The `block-static-store-creds.sh` hook enforces this at the tool-call boundary: pasted Expo / Sentry / Firebase / Apple / Google credentials get blocked before they leave the agent.

---

## 9. Compliance gates encoded in the pack

The `app-store-compliance-auditor` agent runs against a project tree and reports red/amber/green on:

### iOS / App Store
1. `PrivacyInfo.xcprivacy` exists and parses; tracking flag matches `Info.plist`; tracking-domains list non-empty if tracking flag true.
2. Required Reason API entries: `UserDefaults`, `FileTimestamp`, `SystemBootTime`, `DiskSpace`, `ActiveKeyboards` each declared with an Apple-approved reason code when the corresponding API is referenced in source.
3. ATT prompt code path present if any tracking domain is listed.
4. AI-data-sharing UI: search for `URLSession` / `fetch` / known LLM hostnames (`api.openai.com`, `api.anthropic.com`, `generativelanguage.googleapis.com`); if found, expect a consent screen referenced from the call site.
5. Account-deletion path (Guideline 5.1.1(v)) — `delete account` button referenced from settings screen.
6. DSA Trader status declared in `App Store Connect` (documented; auditor can only check that the team has acknowledged the requirement in `references.md`).

### Android / Play
7. Every declared `foregroundServiceType` in manifest has a matching Play Console "App content" entry (auditor checks for a checklist marker in `play-console-checklist.md`).
8. Data safety form has all answers + deletion-request URL.
9. POST_NOTIFICATIONS runtime permission requested on Android 13+ if `notification` references exist.
10. Photo Picker used in any code path that reads media (no broad `READ_MEDIA_*` without `READ_MEDIA_VISUAL_USER_SELECTED`).
11. Generative-AI labeling + report-flag UI present if any LLM call is referenced.
12. Target SDK ≥ 35 (≥ 36 after Aug 31, 2026).

Each item produces a `[ ] / [~] / [x]` checkmark plus a one-line remediation pointer. The auditor never modifies code; remediation belongs to the implementer agent.

---

## 10. Representative assemble combinations (Phase B test targets)

Mirroring `data`'s six-combo coverage from cycle 1, the assemble-coverage test suite must cover these six assembles to prove every layer composes correctly:

| # | Sub-domain | Addons | Why this combo |
|---|---|---|---|
| 1 | `react-native-expo` | xcodebuild-mcp, expo-mcp, sentry-mcp, eas-build, maestro-e2e, privacy-manifest-ios, play-data-safety | The headline 2026 RN stack; tests seven-way fragment merge. |
| 2 | `flutter-app` | xcodebuild-mcp, firebase-mcp, sentry-mcp, patrol-flutter, privacy-manifest-ios, play-data-safety | Default Flutter stack; tests Flutter-specific addons. |
| 3 | `native-ios` | xcodebuild-mcp, sentry-mcp, privacy-manifest-ios, fastlane | iOS-only default; tests fastlane wiring. |
| 4 | `native-android` | firebase-mcp, sentry-mcp, fastlane, play-data-safety, maestro-e2e | Android-only default; tests opt-in Maestro on native Android. |
| 5 | `react-native-expo` | *(no addons)* | Base-only sub-domain; tests that an empty addons array still produces a working harness. |
| 6 | `native-ios` | xcodebuild-mcp, sentry-mcp, privacy-manifest-ios, fastlane, maestro-e2e | Max-coverage iOS: opt-in Maestro layered on top of the default native-iOS stack. |

Combo 5 stress-tests the "addons array empty" path; combo 1 stress-tests the maximum-merge path. The remaining four cover each sub-domain at its default-addon configuration.

---

## 11. Risks and open questions

### 11.1 Maestro MCP vs Maestro CLI

The maestro-e2e addon ships CLI install hooks and a `maestro-flow-author` skill. As of May 2026 there is a Maestro MCP (Feb 2026 release per the research dossier), but its install/auth shape isn't yet stable enough to enshrine in an addon fragment. The addon's `claude-md.md` documents the MCP path as the preferred surface once available, and the agent prompt for `maestro-flow-author` is written to work whether the MCP is wired or not.

### 11.2 Crashlytics MCP is Experimental

Firebase's MCP marks Crashlytics tools as Experimental "not subject to any SLA or deprecation policy." The `firebase-mcp` addon's `claude-md.md` carries a header warning and the `crashlytics-triager` agent's prompt is defensively written (handles absent tools gracefully).

### 11.3 Android first-party Gradle/Studio MCP gap

Google ships no first-party MCP for Gradle, ADB, or Android Studio operations as of May 2026. The `native-android` sub-domain compensates with Bash invocations of `gradle --console=plain` and `adb`, plus instructions that pair well with Android Studio Otter+ Gemini Agent Mode. This is a known gap; documented in `references.md`.

### 11.4 KMP / Compose Multiplatform deferral

KMP for shared business logic and Compose Multiplatform 1.11+ for shared UI both reached production-ready status in 2025–2026 but are not graduated to addons in v1. They reshape project structure (`shared/` Gradle module with KMP source sets, `commonMain` vs `iosMain` vs `androidMain`) too deeply to fit the addon shape. DOMAIN.md and references.md document them with one-line "consider in v2" notes.

### 11.5 EU DMA / Web Distribution scope

The DMA + Core Technology Commission + Web Distribution surface is documented but the pack does not enshrine a Web Distribution sub-domain or addon. Apple's Notarization process for non-App-Store iOS apps is reachable from the same `fastlane` patterns as App Store delivery; the difference is store-side and out-of-scope.

### 11.6 Two-key on release commands

The mobile-release-coordinator inspects `safety.two_key` and refuses store-upload commands without a typed token when true. This is *behavior at the agent layer*, not at the `_base` hook layer (the two-key module is opt-in via `_modules/safety/two-key/`). The pack's `DOMAIN.md` explicitly tells maintainers to opt-in once the release loop is autonomous.

### 11.7 Existing thin-recipe assets to preserve

The v1 thin recipe ships exactly one asset of substance: the `verifying-on-simulator` skill. The pack promotes it verbatim to `templates/mobile/files/.claude/skills/verifying-on-simulator/SKILL.md`; no rewrite, no behavior change. The existing `harness.config.yml` content (Linear progress backend, TDD on, eval_driven off, single-agent) maps cleanly into per-sub-domain `harness.config.yml` defaults.

---

## 12. Out of scope (deliberate)

- **Wearables / watchOS / Wear OS** — no separate sub-domain; users with a watch target should pick `native-ios` or `native-android` and document the watch app in `references.md`.
- **tvOS / Android TV / Google TV** — same logic; no sub-domain.
- **CarPlay / Android Auto** — out of scope.
- **VisionOS** — out of scope; the `xcodebuild-mcp` addon's tool surface mentions visionOS support but the pack does not graduate a sub-domain for it.
- **Web Distribution / alternative marketplaces** — documented, not codified.
- **Bitrise MCP, MobSF MCP, AppSweep, DexGuard, Detekt, SwiftLint addons** — documented in `references.md`, not graduated.
- **KMP / Compose Multiplatform sub-domain** — see §11.4.

---

## 13. Acceptance criteria

The cycle is complete when all of:

- `templates/mobile/DOMAIN.md`, `domain.claude-md.md`, `references.md`, the three shared agents, the promoted `verifying-on-simulator` skill, and the two shared hooks are committed.
- All four sub-domain trees (`native-ios/`, `native-android/`, `react-native-expo/`, `flutter-app/`) exist with `SUBDOMAIN.md`, `harness.config.yml`, `claude-md.md`, `references.md`, `files/.claude/settings.fragment.json`, agents, and skills as specified in §6.
- All ten addons exist under `templates/mobile/_addons/` with the `MODULE.md`/`claude-md.md`/`files/` shape; mandatory fragment files (`.mcp.json.fragment` where applicable) present.
- `templates/tests/checks/assemble-coverage.sh` discovers the four `mobile/<sub-domain>/harness.config.yml` configs and all ten addons via the existing auto-discovery loop; the six representative combos from §10 pass.
- `templates/tests/checks/structure-lint.sh`, `hook-lint.sh`, and the existing `assemble-coverage.sh` all run green (counts strictly higher than the post-cycle-1 baseline of 215 / 102 / 77).
- `docs/reference/domains.md` lists mobile as a curated three-layer pack (not a v1 thin recipe).
- `docs/how-to/pick-a-recipe.md` has a "Question — which mobile sub-domain?" section.
- `docs/HARNESS_ENGINEERING.md` carries the new sub-section for mobile mirroring the §2.10 pattern used for data's analytics-engineering.
- `templates/README.md` quickstart references one of the new mobile sub-domains.
- `templates/mobile/harness.config.yml`, `templates/mobile/claude-md.md`, and `templates/mobile/README.md` (the v1 thin recipe) are deleted.
- The `for d in …` thin-recipe loop in `templates/tests/checks/assemble-coverage.sh` no longer lists `mobile`.

---

## 14. Dossier model (references.md content shape)

Five-plus 2026-cited links, one-line scope each, grouped:

**Stack settled in 2026**
- React Native blog: RN 0.84 Hermes V1 default, precompiled iOS XCFrameworks (Feb 2026).
- Expo Changelog: SDK 54 stable + SDK 56 beta.
- JetBrains Kotlin Blog: Compose Multiplatform 1.11.0 (May 2026).
- Flutter blog: 2026 roadmap (Impeller-only iOS, decoupling Material).
- Apple Newsroom: Xcode 26.3 agentic coding (Feb 2026).
- Android Developers Blog: Otter 3 Feature Drop (Jan 2026).

**Compliance gates**
- Apple Developer: App Review Guideline 5.1.2(i) text (Nov 2025).
- Apple Developer: Privacy manifest files + Required Reason API reference.
- Google Play Help: AI-Generated Content policy + April 15, 2026 update.
- Apple Developer: DMA / Core Technology Commission (Jan 1, 2026).
- European Commission: European Accessibility Act (in force Jun 28, 2025).
- California Legislature: SB 942 (effective Aug 2, 2026 per AB 853).

**MCPs and AI tooling**
- Sentry Blog: XcodeBuildMCP acquisition (Feb 2026).
- Expo Docs: Expo MCP (mcp.expo.dev) OAuth Streamable HTTP.
- Firebase Blog: Firebase MCP Server GA (Oct 2025).
- Sentry Docs: Sentry MCP (mcp.sentry.dev).
- Maestro Insights: best mobile testing frameworks 2026.

**Anodot context**
- Rescana / RH-ISAC / Mitiga writeups on the April 2026 ShinyHunters/Anodot/Snowflake supply-chain breach — pointing to the same broker-token failure mode that mandates OAuth-first MCP posture across mobile too.

---

## 15. Phase B summary (forward look)

Phase B (the writing-plans pass that follows this design) will produce a ~20-task plan covering:

1. Shared layer (DOMAIN.md, domain.claude-md.md, MCP fragments, references.md, two hooks, three agents, promoted skill) — ~6 commits.
2. Four sub-domain trees (one commit per sub-domain typically) — ~4 commits.
3. Ten addons (grouped by category, often two addons per commit) — ~5 commits.
4. `templates/tests/checks/assemble-coverage.sh` extension to discover mobile — 1 commit.
5. Public-doc flip (`docs/reference/domains.md`, `docs/how-to/pick-a-recipe.md`, `docs/HARNESS_ENGINEERING.md`) — 1 commit.
6. `templates/README.md` quickstart + glossary touches — 1 commit.
7. Thin-recipe retirement (delete `templates/mobile/harness.config.yml`, `templates/mobile/claude-md.md`, `templates/mobile/README.md`; remove `mobile` from the assemble-coverage thin-recipe loop) — 1 commit.

Same shape as cycle 1; Phase B plan will mechanize this list into bite-sized TDD-style steps.
