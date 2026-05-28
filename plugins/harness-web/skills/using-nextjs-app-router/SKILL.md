---
name: using-nextjs-app-router
description: Applies Next.js App Router conventions — Server Components, Server Actions, and fetch-based caching. Use whenever writing or reviewing Next.js code in the app/ directory.
---

# Using Next.js App Router

Next.js 15 App Router uses React Server Components (RSC) as the default. Understanding
the server/client boundary is the single most important mental model.

## Component decision tree

```
Does the component need: useState, useReducer, useEffect,
event listeners, browser APIs (window/document), or 3rd-party
client-only libraries?
  YES → add 'use client' at top of file
  NO  → leave it as a Server Component (no directive needed)
```

Keep `'use client'` at the **leaf** of the component tree. Pass server-fetched
data down as props; do not re-fetch on the client.

## Data fetching

Fetch inside async Server Components. Do not use `useEffect` for loading data.

```tsx
// app/posts/page.tsx — Server Component, no 'use client'
export default async function PostsPage() {
  // Runs on the server; credentials never reach the browser
  const posts = await db.select().from(postsTable).orderBy(desc(postsTable.createdAt))
  return <PostList posts={posts} />
}
```

Cache semantics via `fetch` options:
- `{ cache: 'force-cache' }` — static (default when no option is set in Next.js 15).
- `{ cache: 'no-store' }` — dynamic; re-fetched on every request.
- `{ next: { revalidate: 60 } }` — ISR; stale-while-revalidate every 60 s.
- `{ next: { tags: ['posts'] } }` — tag for on-demand invalidation via `revalidateTag`.

## Mutations via Server Actions

Define actions in a `actions.ts` file marked `'use server'` at the top, or inline
with the `'use server'` directive inside the function.

```ts
// app/posts/actions.ts
'use server'
import { revalidatePath } from 'next/cache'
import { db } from '@/db'
import { postsTable } from '@/db/schema'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  await db.insert(postsTable).values({ title })
  revalidatePath('/posts')
}
```

Wire to a form — no JS required for the happy path:

```tsx
<form action={createPost}>
  <input name="title" required />
  <button type="submit">Create</button>
</form>
```

For programmatic invocation, wrap in `startTransition`:

```tsx
'use client'
import { useTransition } from 'react'
import { createPost } from './actions'

export function CreateButton() {
  const [isPending, startTransition] = useTransition()
  return (
    <button
      disabled={isPending}
      onClick={() => startTransition(() => createPost(new FormData()))}
    >
      {isPending ? 'Saving…' : 'Create'}
    </button>
  )
}
```

## Routing conventions

| File | Purpose |
|---|---|
| `app/layout.tsx` | Root layout — wraps all routes, persists across navigation |
| `app/page.tsx` | Route segment UI |
| `app/loading.tsx` | Suspense fallback for the segment |
| `app/error.tsx` | Error boundary for the segment (`'use client'` required) |
| `app/not-found.tsx` | 404 within the segment |
| `app/[slug]/page.tsx` | Dynamic segment; `params.slug` in `Props` |
| `app/(group)/` | Route group — organizes without affecting URL |

## Hard rules

- Do **not** import server-only modules (database, env secrets) into Client Components.
  Add `import 'server-only'` at the top of server utility files to enforce this at
  build time.
- Do **not** call Server Actions inside `useEffect` for data fetching — that pattern
  defeats the purpose of RSC. Fetch in the server component instead.
- Validate and sanitize all `FormData` inputs inside Server Actions before
  database writes. Never trust client-provided types.
- Secret environment variables must be accessed server-side only. Client-safe vars
  are prefixed `NEXT_PUBLIC_`.
