## Addon — Next.js App Router

All code targets the `app/` directory (App Router). The `pages/` directory is
legacy — do not create new files there.

**Component model:**
- Every component is a Server Component by default. Add `'use client'` only when
  you need browser APIs (`window`, `document`), event handlers, or React state/effects.
- Keep `'use client'` boundaries as leaf nodes — move data-fetching ancestors to
  the server side.

**Data fetching:**
- Fetch data in async Server Components using the native `fetch` API or ORM calls.
  Do **not** use `useEffect` to load data — it runs on the client after hydration
  and defeats server rendering.
- Cache control: `{ cache: 'force-cache' }` for static, `{ cache: 'no-store' }` for
  dynamic, `{ next: { revalidate: N } }` for ISR.

**Mutations:**
- Use Server Actions (`'use server'` functions, or files with `'use server'` at top)
  for all data writes. Invoke them from `<form action={action}>` or `startTransition`.
- Revalidate with `revalidatePath` / `revalidateTag` after a successful mutation.

**Routing:**
- File-system routing: `app/page.tsx` → `/`, `app/blog/[slug]/page.tsx` → `/blog/:slug`.
- Layouts in `layout.tsx` persist across child routes; use `template.tsx` when
  layout state must reset on navigation.
- Loading UI: `loading.tsx` wraps the route segment in `<Suspense>` automatically.

**Do not:**
- Do not call Server Actions inside `useEffect` for side-effects — use event handlers
  or form actions.
- Do not import server-only modules (database clients, secrets) into Client Components.
  Use `server-only` package to enforce this boundary at build time.
