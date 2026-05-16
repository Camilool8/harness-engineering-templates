---
name: using-drizzle
description: Defines schemas, generates migrations, and writes type-safe queries with Drizzle ORM. Use whenever reading or writing database schema files, migration files, or Drizzle query code.
---

# Using Drizzle ORM

Drizzle ORM is a TypeScript-first, lightweight SQL query builder and schema
manager. It compiles to raw SQL with full type inference from your schema.

## Schema definition

Define all tables in `db/schema.ts` (or `src/db/schema.ts`):

```ts
// db/schema.ts
import {
  pgTable, serial, text, integer, boolean, timestamp, index
} from 'drizzle-orm/pg-core'

export const users = pgTable('users', {
  id:        serial('id').primaryKey(),
  email:     text('email').notNull().unique(),
  name:      text('name'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
})

export const posts = pgTable('posts', {
  id:        serial('id').primaryKey(),
  title:     text('title').notNull(),
  body:      text('body').notNull(),
  published: boolean('published').default(false).notNull(),
  authorId:  integer('author_id').references(() => users.id).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (t) => [
  index('posts_author_idx').on(t.authorId),
])
```

Infer TypeScript types from the schema:
```ts
import type { InferSelectModel, InferInsertModel } from 'drizzle-orm'
export type User   = InferSelectModel<typeof users>
export type NewUser = InferInsertModel<typeof users>
```

## drizzle.config.ts

```ts
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  schema:    './db/schema.ts',
  out:       './db/migrations',
  dialect:   'postgresql',
  dbCredentials: { url: process.env.DATABASE_URL! },
})
```

## Migration workflow

```bash
# 1. Generate a SQL migration from schema changes
npx drizzle-kit generate

# 2. Review the generated SQL in db/migrations/ — always read it before applying
npx drizzle-kit migrate         # apply pending migrations

# Introspect an existing database (pull its schema into drizzle format)
npx drizzle-kit pull

# Dev-only shortcut — syncs schema without a migration file (NOT for production)
npx drizzle-kit push
```

**Never use `push` against a production or shared staging database.**

## Query API

### Fluent builder (simple queries)

```ts
import { db } from '@/db'
import { users, posts } from '@/db/schema'
import { eq, desc, and } from 'drizzle-orm'

// Select all published posts by a user
const result = await db
  .select()
  .from(posts)
  .where(and(eq(posts.authorId, userId), eq(posts.published, true)))
  .orderBy(desc(posts.createdAt))
  .limit(10)

// Insert and return the new row
const [newUser] = await db
  .insert(users)
  .values({ email: 'alice@example.com', name: 'Alice' })
  .returning()

// Update
await db
  .update(posts)
  .set({ published: true })
  .where(eq(posts.id, postId))

// Delete
await db.delete(posts).where(eq(posts.id, postId))
```

### Relational API (joined reads without N+1)

Configure relations first:

```ts
// db/relations.ts
import { relations } from 'drizzle-orm'
import { users, posts } from './schema'

export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}))
export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, { fields: [posts.authorId], references: [users.id] }),
}))
```

Then query:

```ts
const usersWithPosts = await db.query.users.findMany({
  with: { posts: { where: eq(posts.published, true) } },
})
```

## Expand-contract migration pattern

For production-safe schema changes that rename or remove columns:

**Step 1 — Expand (additive, backward-compatible):**
```ts
// Add new column as nullable — old code ignores it; new code writes to it
export const users = pgTable('users', {
  ...existingColumns,
  displayName: text('display_name'),  // nullable, no default
})
```
Generate migration, deploy, wait until all instances are on the new code.

**Step 2 — Backfill:**
Write a one-off script (not a migration) to copy/transform data from the old
column to the new column. Run it against production.

**Step 3 — Contract (make NOT NULL, drop old column):**
```ts
// Now safe to enforce constraint and remove the old column
displayName: text('display_name').notNull(),
// Remove the old 'name' column definition
```
Generate migration, review the `ALTER TABLE … SET NOT NULL` and `DROP COLUMN`
SQL, then deploy in a separate PR.

## Hard rules

- Schema file is the source of truth. Never alter the database schema directly
  without a matching schema file change and migration.
- Always read the generated SQL migration before running `drizzle-kit migrate`.
  Check for unexpected `DROP` statements.
- `DROP COLUMN` and `ALTER COLUMN … NOT NULL` on existing data require the
  expand-contract sequence — never in a single rushed migration.
- `DATABASE_URL` must be an environment variable. Never hardcode connection
  strings in source files.
- Do not run `drizzle-kit push` against a database you cannot afford to lose.
