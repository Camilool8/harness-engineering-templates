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
