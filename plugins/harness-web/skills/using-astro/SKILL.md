---
name: using-astro
description: Applies Astro islands architecture — static-first rendering, client:* hydration directives, server islands, and content collections. Use whenever writing or reviewing .astro files or astro.config.
---

# Using Astro

Astro renders to HTML on the server and ships **zero JavaScript by default**.
Interactivity is opt-in, per component, via "islands". That is the whole model.

## The island decision

```
Is this component interactive (state, events, browser APIs)?
  NO  → write it as a .astro component (or an unhydrated framework
        component). It renders to static HTML and ships no JS.
  YES → write it in React/Vue/Svelte/Solid and add a client:* directive.
```

## Hydration directives

| Directive | Hydrates | Use for |
|---|---|---|
| `client:load` | immediately on load | above-the-fold interactive UI |
| `client:idle` | when the main thread is idle | lower-priority widgets |
| `client:visible` | when scrolled into viewport | below-the-fold islands (default choice) |
| `client:media={query}` | when a media query matches | viewport-conditional UI |
| `client:only="react"` | never SSR'd, client-rendered only | components that break during SSR |

No directive → rendered to static HTML at build/request time, ships no JS.
Most of a page should be directive-free.

```astro
---
import Header from '../components/Header.astro'
import Counter from '../components/Counter.tsx'   // a React component
---
<Header />                      {/* static HTML, 0 JS */}
<Counter client:visible />      {/* hydrates when scrolled into view */}
```

## Server islands

`server:defer` defers a component's server rendering so the rest of the page
streams immediately — use it for slow or per-user fragments.

```astro
<Avatar server:defer>
  <GenericAvatar slot="fallback" />
</Avatar>
```

## Content collections

Manage structured content with a schema in `src/content.config.ts`. The schema
gives type-safety and editor IntelliSense; the `loader` defines the source.

```ts
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const blog = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/blog' }),
  schema: z.object({
    title: z.string(),
    publishedAt: z.date(),
    draft: z.boolean().default(false),
  }),
});

export const collections = { blog };
```

Query with `getCollection('blog')` and `getEntry('blog', id)` — both fully
typed. A `loader` can also pull from a remote API or a CMS.

## Rendering mode

| `output` | Behavior | Needs an adapter? |
|---|---|---|
| `'static'` (default) | every route prerendered to HTML at build | no |
| `'server'` | request-time rendering + endpoints | yes (`@astrojs/node`/`vercel`/`cloudflare`) |

In `server` mode, opt an individual route back into prerendering with
`export const prerender = true`.

```js
// astro.config.mjs
import { defineConfig } from 'astro/config';
import node from '@astrojs/node';

export default defineConfig({
  output: 'server',
  adapter: node({ mode: 'standalone' }),
});
```

## Hard rules

- Do not add a `client:*` directive to a non-interactive component — it ships
  JS for nothing and defeats Astro's purpose.
- Prefer `client:visible` over `client:load` for anything below the fold.
- A framework integration (`@astrojs/react`, etc.) is required even to render a
  framework component statically — install it, then hydrate only when needed.
- Secrets stay server-side; only `PUBLIC_`-prefixed env vars reach the client.
- Verify rendered output via the accessibility tree (see `verifying-web-ui`),
  not by assuming the static HTML is correct.
