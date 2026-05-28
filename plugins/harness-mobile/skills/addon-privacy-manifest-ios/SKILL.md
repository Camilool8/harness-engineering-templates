---
name: mobile-addon-privacy-manifest-ios
description: iOS PrivacyInfo.xcprivacy authoring — Required Reason API categories with Apple-approved reason codes, NSPrivacyTracking / NSPrivacyTrackingDomains / NSPrivacyCollectedDataTypes keys, and signed third-party SDK manifests. Use when creating or gap-checking an iOS privacy manifest against the Required Reason APIs the project actually references.
---

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
