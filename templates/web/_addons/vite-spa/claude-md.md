## Addon — Vite SPA

This project is a **client-only SPA** built with Vite. There is no server-side
rendering; the backend is a separate API.

**Environment variables:**
- Only variables prefixed `VITE_` are exposed to client code via `import.meta.env`.
  Never put secrets in `VITE_`-prefixed variables — they ship in the browser bundle.
- Access: `import.meta.env.VITE_API_URL` (string, always defined after Vite
  processes the build).

**Dev server:**
- Default port: 5173. Run `npm run dev` (or `vite`).
- HMR is instant; if a module does not hot-reload cleanly, a full reload fires
  automatically — do not fight it.
- Proxy API calls through `vite.config.ts` `server.proxy` to avoid CORS in dev:
  `/api → http://localhost:3001`.

**Build:**
- `npm run build` emits to `dist/`. The output is a static bundle — deploy to any
  CDN or static host.
- All client-side routes must be configured as index.html fallbacks on the server
  (the `try_files $uri /index.html` pattern for nginx, `rewrite` rules for S3/CF).

**Routing:**
- Use React Router v7+ (or TanStack Router) for client-side routing. Do not use
  `window.location.href` for in-app navigation — always use `<Link>` or `navigate()`.

**Data fetching:**
- Fetch data in React Query / SWR / TanStack Query hooks, not bare `useEffect`.
  Bare `useEffect` for data is an anti-pattern: no deduplication, no cache, no
  loading/error state management.
- The API base URL must come from `import.meta.env.VITE_API_URL`; never hardcode
  localhost URLs in src files.
