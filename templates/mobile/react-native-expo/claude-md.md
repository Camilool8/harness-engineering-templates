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
