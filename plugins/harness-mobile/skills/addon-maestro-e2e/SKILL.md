---
name: mobile-addon-maestro-e2e
description: Maestro cross-platform mobile E2E conventions — one declarative YAML flow per user journey under .maestro/, stable testID/accessibility-label selectors over coordinates, local/Studio/Cloud run modes, and the Feb 2026 Maestro MCP. Use when authoring or running Maestro end-to-end flows for any iOS, Android, React Native, or Flutter target.
---

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
