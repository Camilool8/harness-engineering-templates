---
name: using-vite-spa
description: Applies Vite SPA project conventions — env vars, routing, proxy config, and build output. Use whenever writing or reviewing Vite-based client-only SPA code.
---

# Using Vite SPA

Vite is a build tool and dev server for client-side SPAs and library packages. This
skill covers the conventions specific to a React + Vite SPA where the backend is
an external API boundary.

## Project structure

```
my-spa/
├── index.html          # Vite entry point (not src/index.html)
├── vite.config.ts
├── src/
│   ├── main.tsx        # React DOM root
│   ├── App.tsx
│   ├── routes/         # Route-level components
│   ├── components/     # Shared UI components
│   ├── hooks/          # Custom hooks (data fetching, etc.)
│   ├── lib/            # Non-React utilities, API clients
│   └── assets/         # Static assets (imported, not public/)
└── public/             # Files copied verbatim to dist/ (favicons, robots.txt)
```

## vite.config.ts conventions

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'
import path from 'node:path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
  server: {
    port: 5173,
    proxy: {
      // Avoid CORS in dev by proxying API calls
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  },
})
```

## Environment variables

Only `VITE_`-prefixed variables reach the browser:

```
# .env.local (git-ignored)
VITE_API_URL=http://localhost:3001

# .env.production (committed; must not contain secrets)
VITE_API_URL=https://api.example.com
```

Access in code:
```ts
const apiBase = import.meta.env.VITE_API_URL   // string
const isDev   = import.meta.env.DEV             // boolean
```

**Never** put API keys, tokens, or passwords in `VITE_` variables — they are
embedded verbatim in the browser bundle.

## Routing with React Router v7

```tsx
// src/main.tsx
import { createBrowserRouter, RouterProvider } from 'react-router'
import { createRoot } from 'react-dom/client'

const router = createBrowserRouter([
  { path: '/', element: <HomePage /> },
  { path: '/posts/:slug', element: <PostPage />, loader: postLoader },
  { path: '*', element: <NotFoundPage /> },
])

createRoot(document.getElementById('root')!).render(
  <RouterProvider router={router} />
)
```

For client-side routing to work on a static host, configure a fallback to
`index.html` for all 404s (nginx `try_files $uri /index.html`, S3 error
document, Netlify `_redirects: /* /index.html 200`).

## Data fetching with TanStack Query

Prefer TanStack Query over bare `useEffect` for all server state:

```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

function usePosts() {
  return useQuery({
    queryKey: ['posts'],
    queryFn: () => fetch(`${import.meta.env.VITE_API_URL}/posts`).then(r => r.json()),
  })
}
```

Bare `useEffect` for data is an anti-pattern: no deduplication, no cache, no
loading/error management, and no background refetch.

## Build and deploy

```bash
npm run build        # emits to dist/
npm run preview      # serves dist/ locally to verify the production bundle
```

The `dist/` output is fully static — serve it from any CDN. There is no Node.js
process at runtime.

## Hard rules

- Do not hardcode `localhost` URLs in `src/`. All API base URLs must come from
  `import.meta.env.VITE_API_URL`.
- Do not use `window.location.href =` for in-app navigation. Use `<Link to>` or
  the `useNavigate` hook.
- Do not put secrets in `VITE_`-prefixed env vars. If a secret is needed at
  build time (e.g., a public Sentry DSN), document it explicitly.
- Keep `index.html` at the project root, not inside `src/`.
