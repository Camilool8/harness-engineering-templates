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
