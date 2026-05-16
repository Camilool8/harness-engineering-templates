## Addon — Drizzle ORM

Drizzle is the database layer. Schema is the source of truth — the database
schema must match `db/schema.ts` at all times, and changes must go through
the migration workflow.

**Schema is the source of truth.**
- Define all tables in `db/schema.ts` using Drizzle's TypeScript DSL.
- Never alter a table directly in the database; always change the schema file
  first, then generate a migration.

**Migration workflow:**
- Development: `npx drizzle-kit generate` to produce a SQL migration file, then
  `npx drizzle-kit migrate` to apply it.
- Rapid prototyping only: `npx drizzle-kit push` syncs the schema to a local DB
  without generating a migration file. **Do not use `push` against a production
  or shared database.**

**Expand-contract for safe production migrations:**
1. **Expand** — add the new column as nullable (never rename or drop yet). Deploy.
2. **Backfill** — write a one-off script to fill the new column. Deploy.
3. **Contract** — make the column NOT NULL, remove the old column. Deploy.
Never drop or rename a column in a single migration that also runs in production
without the expand-contract sequence.

**No destructive DDL without a migration PR:**
- `DROP TABLE`, `DROP COLUMN`, and `ALTER COLUMN … NOT NULL` on an existing
  nullable column are destructive. Require a reviewed migration PR before applying.
- The `data-layer-implementer` agent must not run destructive SQL directly.

**Query API:**
- Prefer the fluent query builder (`db.select().from(users).where(...)`) for
  simple queries.
- Use the relational API (`db.query.users.findMany({ with: { posts: true } })`)
  for joined reads — it avoids N+1 without an ORM-level lazy-load footgun.
