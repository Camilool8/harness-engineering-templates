# Module: web/addon/drizzle

> Config: `domain.addons` · Depends on: none (pairs with `nextjs`, `fullstack-app`)

**What it does.** Installs the `using-drizzle` skill that teaches the agent
Drizzle ORM conventions: TypeScript-first schema definition, the
expand-contract migration pattern, `drizzle-kit generate` vs `push` workflows,
and the hard rule against destructive DDL without a tracked migration.

## Adopt if
- You are storing relational data in PostgreSQL, MySQL, or SQLite and want
  TypeScript-type-safe queries without a heavy ORM (sub-domain: `fullstack-app`).
- You want zero-cost abstractions — Drizzle compiles to near-raw SQL; no runtime
  magic, no proxy objects.
- You work in a serverless or edge environment — Drizzle has no connection-pool
  overhead and works with neon-serverless, Turso, and Cloudflare D1 drivers.

## Skip if
- You need a full-featured ORM with relations, lazy loading, and entity lifecycle
  hooks — Prisma or TypeORM are better fits.
- Your project has no persistent relational database (e.g., a pure API proxy or
  in-memory service).

## Dependencies
- `drizzle-orm` and a driver package (`postgres`, `@neondatabase/serverless`,
  `better-sqlite3`, `mysql2`, etc.).
- `drizzle-kit` (dev dependency) for schema introspection, migration generation,
  and the `studio` UI.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.

## Install (assemble.sh)
Add `drizzle` to `domain.addons` in `harness.config.yml` and run `./assemble.sh`.

## Remove
- Delete `.claude/skills/using-drizzle/`.
- Remove the `## Addon — Drizzle ORM` section from `CLAUDE.md`.

## Files
- `files/.claude/skills/using-drizzle/SKILL.md` — schema definition patterns,
  migration workflow, query API, expand-contract discipline, and safety rules.
