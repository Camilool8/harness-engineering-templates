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
