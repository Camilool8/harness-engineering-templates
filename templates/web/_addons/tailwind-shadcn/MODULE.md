# Module: web/addon/tailwind-shadcn

> Config: `domain.addons` · Depends on: none (pairs with `nextjs`, `vite-spa`, `design-system`)

**What it does.** Installs the `using-shadcn` skill and wires the shadcn MCP
server. The skill teaches the agent to install shadcn/ui components via the
shadcn CLI (or MCP), never hand-roll Radix primitives, and apply Tailwind
utility classes in a consistent token-driven order. The MCP server lets the
agent browse and install components from any shadcn registry with natural language.

## Adopt if
- You want Tailwind CSS with a component library based on Radix UI primitives
  (sub-domains: `frontend-app`, `fullstack-app`, `design-system`).
- You want the agent to install components automatically via the shadcn MCP.

## Skip if
- You are using a different component library (MUI, Ant Design, Chakra) — this
  skill teaches shadcn/ui-specific patterns that do not apply.
- The project has no UI layer (e.g., `api-service`, `distributed-backend`).

## Dependencies
- Tailwind CSS 4+ (configured in `app/globals.css` for Next.js or `src/index.css`
  for Vite; no separate `tailwind.config` file required in Tailwind 4).
- `shadcn@latest` CLI (`npx shadcn@latest init` to scaffold).
- Node.js 18+.

## Install (manual)
1. Copy `files/` into your project root.
2. Append `claude-md.md` to your `CLAUDE.md`.
3. Add the `.mcp.json.fragment` content to your project's `.mcp.json` manually,
   or let `assemble.sh` deep-merge it automatically.

## Install (assemble.sh)
Add `tailwind-shadcn` to `domain.addons` in `harness.config.yml` and run
`./assemble.sh`. The MCP fragment is deep-merged into `.mcp.json` automatically.

## Remove
- Delete `.claude/skills/using-shadcn/`.
- Remove `mcpServers.shadcn` from `.mcp.json`.
- Remove the `## Addon — Tailwind + shadcn/ui` section from `CLAUDE.md`.

## Files
- `files/.mcp.json.fragment` — registers the shadcn MCP server so the agent can
  browse and install components from any registry without leaving the session.
- `files/.claude/skills/using-shadcn/SKILL.md` — shadcn installation workflow,
  MCP usage, Tailwind utility-class conventions, and the no-hand-rolling rule.
