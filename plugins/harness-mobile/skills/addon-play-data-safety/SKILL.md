---
name: mobile-addon-play-data-safety
description: Google Play Data safety form walkthrough — data collected/shared per category, collection purposes, encryption-in-transit attestation, deletion-request URL, in-app and out-of-app deletion paths, and generative-AI labeling plus report/flag UI. Use when filling or auditing the Play Console Data safety form so it matches actual app and SDK behavior.
---

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
