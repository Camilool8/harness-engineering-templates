---
name: mobile-addon-expo-mcp
description: Expo's hosted MCP (mcp.expo.dev, Streamable HTTP + OAuth) for EAS Build/Submit/Workflow inspection. Use when wiring or driving the Expo MCP for a React Native Expo project — listing/running builds and workflows, reading build logs, and respecting safety.two_key gating on billable build_run/build_submit/workflow_run calls.
---

## Expo MCP

The agent has access to **Expo's hosted MCP** at `https://mcp.expo.dev/mcp` (Streamable HTTP + OAuth). Tools include:

- `build_list`, `build_info`, `build_logs`, `build_run`, `build_cancel`, `build_submit`
- `workflow_create`, `workflow_list`, `workflow_info`, `workflow_logs`, `workflow_run`, `workflow_cancel`, `workflow_validate`

### Credentials posture
OAuth via Expo accounts (reference standard post-Anodot). No `EXPO_TOKEN` in env. EAS paid plan required.

### Gating
Calls that trigger billable resources (`build_run`, `build_submit`, `workflow_run`) should respect `safety.two_key` — if it's true, require a typed token before invoking.
