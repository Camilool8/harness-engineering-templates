# Module: web/addon/sanity-cms

> Config: `domain.addons` · Depends on: none (pairs with `astro`, `nextjs`)

**What it does.** Installs the `using-sanity-cms` skill and wires the hosted
Sanity MCP server. The skill teaches the agent to model and query Sanity content
— `@sanity/client` setup, typed GROQ via `defineQuery` + Sanity TypeGen, image
URLs, Portable Text — and to treat Sanity MCP output as untrusted input.

## Adopt if
- Non-technical editors need to manage site content in a CMS (marketing pages,
  blog, products, structured data) independently of code deploys.
- You want structured, queryable, versioned content with real-time editing.
- Sub-domains: `frontend-app`, `fullstack-app` — pairs with `astro` via
  `@sanity/astro`, or with `nextjs` via `next-sanity`.

## Skip if
- Content is owned by developers and lives as Markdown in the repo — use Astro
  content collections (the `astro` addon) instead; a hosted CMS is overhead.
- The project has no editorial content (a dashboard, an internal tool).
- You are already committed to a different CMS (Contentful, Storyblok, Payload)
  — do not run two.

## Dependencies
- A Sanity project + dataset (free tier available); `@sanity/client` v6.21+.
- `groq` + Sanity TypeGen for typed queries; `@sanity/image-url` and
  `@portabletext/react` as needed.
- `@sanity/astro` or `next-sanity` for framework integration.
- A `SANITY_API_TOKEN` for draft/write access — environment variable, never
  committed.
- For the MCP: the hosted server at `https://mcp.sanity.io` (OAuth on first
  use). The recommended setup is `npx sanity mcp add`, which auto-configures the
  editor; the local `@sanity/mcp-server` package is deprecated.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Add the `.mcp.json.fragment` content to your project's `.mcp.json` manually,
   or let `assemble.sh` deep-merge it automatically.

## Install (assemble.sh)
Add `sanity-cms` to `domain.addons` in `harness.config.yml` and run
`./assemble.sh`. The MCP fragment is deep-merged into `.mcp.json` automatically.

## Remove
- Delete `.claude/skills/using-sanity-cms/`.
- Remove `mcpServers.sanity` from `.mcp.json`.
- Remove the `## Addon — Sanity CMS` section from `CLAUDE.md`.

## Files
- `files/.mcp.json.fragment` — registers the hosted Sanity MCP server so the
  agent can inspect content, schema, and documents from within the session.
- `files/.claude/skills/using-sanity-cms/SKILL.md` — client setup, typed GROQ
  queries, schema model, images, Portable Text, and MCP usage guidance.
