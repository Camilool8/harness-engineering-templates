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
