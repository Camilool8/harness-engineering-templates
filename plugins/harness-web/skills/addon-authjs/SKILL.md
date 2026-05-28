---
name: web-addon-authjs
description: Auth.js v5 authentication conventions — encrypted sessions, env-var-only secrets, server vs client session access, edge middleware route protection, and provider credential inference. Use when adding or reviewing a login flow, OAuth, or session handling.
---

## Addon — Auth.js

Auth.js v5 handles authentication. Sessions are encrypted with `AUTH_SECRET`.
Provider credentials are read from environment variables — never from source code.

**Security invariants (non-negotiable):**
- Never log `session.user`, `token`, or any object that may contain credentials,
  email, or session identifiers. Tokens in logs are a breach.
- All secrets (`AUTH_SECRET`, `AUTH_GITHUB_SECRET`, etc.) must be environment
  variables. They must not appear in source files, `.env.example` with real values,
  or commit history.
- `AUTH_SECRET` must be generated with `npx auth secret` — do not hand-write it.

**Session access:**
- In Server Components: `const session = await auth()` — returns the session or
  `null`; access is server-side only and safe.
- In Client Components: wrap the app in `<SessionProvider>` and call `useSession()`.
  The client session exposes only what you explicitly include in the JWT/session
  callback — no raw tokens.

**Route protection:**
- Use Auth.js middleware (`middleware.ts` at the project root) to protect routes
  at the edge. Do not add manual `if (!session) redirect()` checks in every page.
- Configure `authorized` callback in `auth.config.ts` to declare which paths
  require authentication.

**Environment variable naming (provider inference):**
Auth.js automatically infers provider credentials if named `AUTH_<PROVIDER>_ID`
and `AUTH_<PROVIDER>_SECRET`. This means no manual `clientId`/`clientSecret`
in the provider array for official providers.
```
AUTH_GITHUB_ID=...
AUTH_GITHUB_SECRET=...
AUTH_GOOGLE_ID=...
AUTH_GOOGLE_SECRET=...
```
