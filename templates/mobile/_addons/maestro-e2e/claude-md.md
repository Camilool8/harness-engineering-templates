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
