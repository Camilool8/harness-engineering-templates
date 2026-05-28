---
name: web-addon-tailwind-shadcn
description: Tailwind CSS + shadcn/ui conventions — utility classes as the sole styling mechanism, shadcn primitives over hand-rolled Radix, installing via the MCP or CLI, class-order convention, and semantic theme tokens over hardcoded palette colors. Use when styling components or adding UI primitives. The shadcn MCP server ships with this plugin.
---

## Addon — Tailwind + shadcn/ui

**Tailwind CSS** is the sole styling mechanism. Do not write raw CSS unless
Tailwind has no utility for the property. Utility classes are applied directly
in JSX; no CSS modules, no styled-components, no emotion.

**shadcn/ui** components are the primitive building blocks. The rule is:
- Never hand-roll a Radix UI primitive (Dialog, Popover, Select, Tooltip, etc.).
  Use the shadcn equivalent, which wraps Radix with accessible defaults.
- Install components via the shadcn MCP or CLI — do not copy-paste component
  code from the internet without going through the official registry.

**Installing a component:**

Via MCP (preferred — the agent can do this directly):
```
Use the shadcn MCP to install the <component-name> component.
```

Via CLI:
```bash
npx shadcn@latest add button
npx shadcn@latest add dialog form input label
```

Components are written to `src/components/ui/` (Vite) or
`components/ui/` (Next.js). They are yours to edit — the registry
version is a starting point, not a lock-in.

**Tailwind class order convention** (enforce with `prettier-plugin-tailwindcss`):
layout → flex/grid → spacing → sizing → typography → color → border →
shadow/ring → transition → state variants.

**Theming:**
- CSS custom properties in `globals.css` (or `app/globals.css`) define the color
  tokens: `--background`, `--foreground`, `--primary`, `--primary-foreground`, etc.
- Dark mode uses the `dark` class on `<html>`; controlled by `next-themes` or a
  custom ThemeProvider.
- Do not hardcode colors with Tailwind's palette (`bg-blue-500`). Use semantic
  tokens (`bg-primary`, `text-muted-foreground`) so the theme can switch.
