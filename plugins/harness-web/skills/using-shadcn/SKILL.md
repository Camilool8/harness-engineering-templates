---
name: using-shadcn
description: Installs and uses shadcn/ui components via the MCP or CLI, and applies Tailwind utility-class conventions. Use whenever adding UI components or applying styles in a Tailwind + shadcn project.
---

# Using shadcn/ui

shadcn/ui is a collection of copy-paste-ready UI components built on Radix UI
primitives and styled with Tailwind CSS. Components are installed into your source
tree — they are not a locked package dependency; you own the code.

## The MCP workflow (preferred)

The shadcn MCP server is wired in `.mcp.json`. Ask the AI assistant to install
a component by describing what you need:

```
Install the shadcn Button and Dialog components.
```

The MCP server connects to the shadcn registry, resolves the component definition,
and runs `npx shadcn@latest add` on your behalf.

## CLI workflow

```bash
# First-time project setup (Next.js or Vite)
npx shadcn@latest init

# Add individual components
npx shadcn@latest add button
npx shadcn@latest add dialog form input label select textarea

# Add multiple at once
npx shadcn@latest add button card dialog form input label
```

Components are written to:
- **Next.js**: `components/ui/<component>.tsx`
- **Vite**: `src/components/ui/<component>.tsx`

## Using components

Import from the `@/components/ui/` alias (configured by shadcn init):

```tsx
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'

export function ConfirmDialog() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="destructive">Delete</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Are you sure?</DialogTitle>
        </DialogHeader>
        <p>This action cannot be undone.</p>
      </DialogContent>
    </Dialog>
  )
}
```

## Tailwind CSS conventions

1. **Use semantic color tokens, not palette values.**
   - Correct: `bg-primary text-primary-foreground`
   - Wrong: `bg-blue-500 text-white` — breaks dark mode and theming.

2. **Class order** (enforced by `prettier-plugin-tailwindcss`):
   `layout → flex/grid → spacing → sizing → typography → color → border → shadow → transition → state`
   ```tsx
   <div className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-foreground bg-card border rounded-md shadow-sm transition-colors hover:bg-accent" />
   ```

3. **Responsive modifiers**: mobile-first — `sm:`, `md:`, `lg:`, `xl:`.

4. **Dark mode**: use `dark:` variant; the `dark` class is toggled on `<html>`.

5. **Do not** write raw CSS unless Tailwind has no utility for the property.
   If a one-off value is needed, use an arbitrary value: `w-[42px]`.

## Theming and CSS variables

shadcn/ui uses CSS custom properties defined in `globals.css`:

```css
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    /* … */
  }
  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    /* … */
  }
}
```

Do not override these variables inline. Edit them in `globals.css` to change the
theme across the whole app.

## Hard rules

- Never hand-roll a Radix UI primitive. Use the shadcn equivalent.
- Never import Radix UI directly (`@radix-ui/react-dialog`) in application code —
  import from `@/components/ui/dialog` (the shadcn wrapper).
- Do not hardcode hex colors or Tailwind palette shades (`blue-500`). Use semantic
  token classes (`primary`, `muted`, `accent`, etc.).
- Run `npx shadcn@latest diff` periodically to check if upstream registry
  components have been updated with fixes.
