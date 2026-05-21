# Curated Domain Packs Implementation Plan

> **✓ Completed 2026-05-15.** All 18 tasks were implemented, reviewed, and
> merged. This file is kept as a historical record — the `- [ ]` checkboxes are
> not open work.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure `templates/` from flat domain recipes into curated three-layer domain packs (domain → sub-domain → addons), and fully build the web domain pack as the worked reference.

**Architecture:** `_base/` and `_modules/` are unchanged. `assemble.sh` gains v2 capabilities: an extended config schema (`domain`/`agents`/`docs` blocks), domain+sub-domain+addon layering, agent-team resolution, and `.mcp.json` deep-merge — all backward compatible with the 12 existing thin recipes. The web recipe becomes a domain pack with 5 sub-domains, 7 addons, curated agent teams, and dated reference dossiers.

**Tech Stack:** Bash (assemble.sh), `jq` (JSON merge + validation), Markdown (CLAUDE.md/skills/agents/dossiers), JSON (settings/MCP fragments). No build system; verification is a bash test harness.

**Source spec:** `docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md`

---

## File Structure

**Modified:**
- `templates/assemble.sh` — v2: extended parsing, layering, agent resolution, MCP merge
- `templates/harness.config.yml` — extended schema (`domain`, `agents`, `docs` blocks)
- `templates/README.md` — document the three-layer model + new schema
- `templates/web/` — restructured into a domain pack (assets redistributed)
- `templates/{data,devops,finance,mobile,game,embedded,scientific,security,content,ops}/README.md` — add "v1 thin recipe" marker

**Created — test harness:**
- `templates/tests/run.sh` — assertion-based test runner for `assemble.sh`
- `templates/tests/fixtures/` — minimal configs exercising v2 paths

**Created — web domain pack:**
- `templates/web/DOMAIN.md`, `references.md`, `domain.claude-md.md`
- `templates/web/files/.claude/` — shared agents, skills, hooks, `settings.fragment.json`, `web.mcp.json.fragment`, `context7.mcp.json.fragment`
- `templates/web/files/lighthouse-budget.json`
- `templates/web/<sub-domain>/` ×5 — `SUBDOMAIN.md`, `harness.config.yml`, `references.md`, `claude-md.md`, `files/.claude/{agents,skills,hooks,settings.fragment.json}`
- `templates/web/_addons/<addon>/` ×7 — `MODULE.md`, `claude-md.md`, `files/`

Each file has one responsibility; the `files/` convention (verbatim copy target) is identical to `_modules/`, so no new copy logic is needed beyond layering.

---

## Phase 1 — Test harness (lock the backward-compat baseline)

### Task 1: Create the assemble.sh test runner

**Files:**
- Create: `templates/tests/run.sh`

- [ ] **Step 1: Write the test runner**

```bash
#!/usr/bin/env bash
# tests/run.sh — assertion harness for assemble.sh. Run from templates/.
set -uo pipefail
cd "$(dirname "$0")/.."
PASS=0; FAIL=0
fail() { echo "  ✗ $1"; FAIL=$((FAIL+1)); }
ok()   { echo "  ✓ $1"; PASS=$((PASS+1)); }

# assemble <config> -> sets $OUT to a fresh temp dir, returns assemble exit code
assemble() {
  OUT="$(mktemp -d)"; ./assemble.sh "$1" "$OUT" >/dev/null 2>&1
}

# assert_assembles <config> <label>
assert_assembles() {
  assemble "$1"
  [ $? -eq 0 ] || { fail "$2: assemble exited non-zero"; return; }
  jq -e . "$OUT/.claude/settings.json" >/dev/null 2>&1 \
    || { fail "$2: settings.json invalid"; return; }
  [ -f "$OUT/CLAUDE.md" ] || { fail "$2: no CLAUDE.md"; return; }
  if find "$OUT" -name 'settings.fragment.json' | grep -q .; then
    fail "$2: leftover settings.fragment.json"; return
  fi
  for h in "$OUT"/.claude/hooks/*.sh; do
    [ -x "$h" ] || { fail "$2: hook not executable: $h"; return; }
    bash -n "$h" 2>/dev/null || { fail "$2: hook syntax error: $h"; return; }
  done
  ok "$2"
  rm -rf "$OUT"
}

echo "== backward-compat: every thin recipe assembles =="
for d in generic web data devops finance mobile game embedded \
         scientific security content ops; do
  assert_assembles "$d/harness.config.yml" "recipe:$d"
done
assert_assembles "harness.config.yml" "root-manifest"

echo ""
echo "Passed: $PASS  Failed: $FAIL"
[ "$FAIL" -eq 0 ]
```

- [ ] **Step 2: Make it executable and run it**

Run: `chmod +x templates/tests/run.sh && cd templates && ./tests/run.sh`
Expected: PASS for all 13 configs, `Failed: 0`, exit 0. (This proves the v1 baseline before any v2 change.)

- [ ] **Step 3: Commit**

```bash
git add templates/tests/run.sh
git commit -m "test: add assemble.sh assertion harness"
```

---

## Phase 2 — assemble.sh v2

> Each task adds one capability and keeps `tests/run.sh` green. New capabilities get new fixture-based assertions added to `run.sh`.

### Task 2: Generalize fragment merging to cover .mcp.json

**Files:**
- Modify: `templates/assemble.sh` (the `merge_settings` function)

- [ ] **Step 1: Replace `merge_settings` with a generic `merge_json` + `merge_fragments`**

Find the existing `merge_settings()` function and replace it with:

```bash
# Deep-merge $1 (fragment) into $2 (base): objects recurse, arrays concatenate.
merge_json() {
  local frag="$1" base="$2"
  [ -f "$frag" ] || return 0
  if [ "$JQ_OK" -eq 1 ] && [ -f "$base" ]; then
    jq -s '
      def deepmerge($a; $b):
        reduce ($b|keys_unsorted[]) as $k ($a;
          if   (($a[$k]|type)=="object") and (($b[$k]|type)=="object")
            then .[$k] = deepmerge($a[$k]; $b[$k])
          elif (($a[$k]|type)=="array")  and (($b[$k]|type)=="array")
            then .[$k] = ($a[$k] + $b[$k])
          else .[$k] = $b[$k] end);
      deepmerge(.[0]; .[1])' "$base" "$frag" > "$base.tmp" \
      && mv "$base.tmp" "$base" && rm -f "$frag" \
      && echo "  · merged $(basename "$frag")"
  else
    echo "  ! jq not found — $(basename "$frag") left for manual merge" >&2
  fi
}

# Merge any settings + mcp fragments the last copy step dropped into the target.
merge_fragments() {
  merge_json "$TARGET/.claude/settings.fragment.json" "$TARGET/.claude/settings.json"
  merge_json "$TARGET/.mcp.json.fragment"             "$TARGET/.mcp.json"
}
```

- [ ] **Step 2: Replace every `merge_settings` call site with `merge_fragments`**

In `install_module()` change `cp -R "$dir/files/." "$TARGET/"; merge_settings;` to `cp -R "$dir/files/." "$TARGET/"; merge_fragments;`. In the recipe-extras block change `merge_settings` to `merge_fragments`.

- [ ] **Step 3: Add an MCP-merge fixture and assertion to tests/run.sh**

Create `templates/tests/fixtures/mcp-merge/.mcp.json.fragment`:

```json
{ "mcpServers": { "context7": { "command": "npx", "args": ["-y", "@context7/mcp"] } } }
```

In `tests/run.sh`, after the backward-compat block, add:

```bash
echo "== .mcp.json fragments deep-merge =="
assemble "generic/harness.config.yml"
cp tests/fixtures/mcp-merge/.mcp.json.fragment "$OUT/.mcp.json.fragment"
merged="$(jq -s 'def dm($a;$b): reduce ($b|keys_unsorted[]) as $k ($a;
  if (($a[$k]|type)=="object") and (($b[$k]|type)=="object") then .[$k]=dm($a[$k];$b[$k])
  elif (($a[$k]|type)=="array") and (($b[$k]|type)=="array") then .[$k]=($a[$k]+$b[$k])
  else .[$k]=$b[$k] end); dm(.[0];.[1])' "$OUT/.mcp.json" "$OUT/.mcp.json.fragment")"
echo "$merged" | jq -e '.mcpServers.context7' >/dev/null 2>&1 \
  && ok "mcp deep-merge keeps server" || fail "mcp deep-merge lost server"
rm -rf "$OUT"
```

- [ ] **Step 4: Run the harness**

Run: `cd templates && ./tests/run.sh`
Expected: all backward-compat tests still PASS, mcp-merge test PASS, `Failed: 0`.

- [ ] **Step 5: Commit**

```bash
git add templates/assemble.sh templates/tests/
git commit -m "feat: assemble.sh deep-merges .mcp.json fragments"
```

### Task 3: Parse list-valued config keys

**Files:**
- Modify: `templates/assemble.sh` (after the `cfg()` definition)

- [ ] **Step 1: Add a `cfg_list` helper**

The flattener already turns `addons: [a, b, c]` into `domain.addons=[a, b, c]`. Add, right after `cfg()`:

```bash
# cfg_list <dotted.key> -> prints one list item per line (handles [a, b] or empty)
cfg_list() {
  local raw; raw="$(cfg "$1")"
  raw="${raw#[}"; raw="${raw%]}"
  [ -z "$raw" ] && return 0
  printf '%s\n' "$raw" | tr ',' '\n' | sed 's/^[ \t]*//; s/[ \t]*$//' | grep -v '^$'
}
```

- [ ] **Step 2: Verify the flattener emits bracketed lists**

The `flatten()` awk already captures everything after `key:` as the value, so `domain.addons=[nextjs, drizzle]` is produced as-is. No flattener change needed. Confirm by reading `flatten()` — its value capture (`sub(/^[^:]*:[ \t]*/,"",v)`) keeps brackets.

- [ ] **Step 3: Smoke-test the helper**

Run:
```bash
cd templates && printf 'domain:\n  addons: [nextjs, drizzle-orm, authjs]\n' > /tmp/t.yml
bash -c 'source <(sed -n "/^flatten()/,/^cfg_list/p" assemble.sh); CONFIG=/tmp/t.yml; CFG=$(flatten); cfg() { printf "%s\n" "$CFG"|grep "^$1="|head -1|cut -d= -f2-; }; cfg_list domain.addons'
```
Expected: three lines — `nextjs`, `drizzle-orm`, `authjs`.

- [ ] **Step 4: Commit**

```bash
git add templates/assemble.sh
git commit -m "feat: assemble.sh parses list-valued config keys"
```

### Task 4: Domain + sub-domain layering

**Files:**
- Modify: `templates/assemble.sh` (the recipe-extras block)

- [ ] **Step 1: Replace the recipe-extras block with domain-pack-aware layering**

Find the block beginning `# --- domain recipe extras` and replace it with:

```bash
# --- domain pack / sub-domain / thin-recipe layering ------------------------
apply_layer() {           # apply_layer <dir> <claude-md-filename> <label>
  local dir="$1" cmd="$2" label="$3"
  [ -d "$dir/files" ] && { echo "→ $label"; cp -R "$dir/files/." "$TARGET/"; merge_fragments; }
  if [ -f "$dir/$cmd" ]; then
    printf '\n' >> "$TARGET/CLAUDE.md"; cat "$dir/$cmd" >> "$TARGET/CLAUDE.md"
  fi
}

CONFIG_DIR="$(cd "$(dirname "$CONFIG")" && pwd)"
DOMAIN_DIR=""
if [ "$CONFIG_DIR" != "$HERE" ]; then
  if [ -f "$CONFIG_DIR/../DOMAIN.md" ]; then
    # domain pack: config lives in a sub-domain folder
    DOMAIN_DIR="$(cd "$CONFIG_DIR/.." && pwd)"
    apply_layer "$DOMAIN_DIR" "domain.claude-md.md" "domain: $(basename "$DOMAIN_DIR")"
    apply_layer "$CONFIG_DIR" "claude-md.md" "sub-domain: $(basename "$CONFIG_DIR")"
    PICKED+=("domain/$(basename "$DOMAIN_DIR")/$(basename "$CONFIG_DIR")")
  else
    # v1 thin recipe
    apply_layer "$CONFIG_DIR" "claude-md.md" "recipe: $(basename "$CONFIG_DIR")"
    PICKED+=("recipe/$(basename "$CONFIG_DIR")")
  fi
fi
```

- [ ] **Step 2: Run the harness to confirm thin recipes still work**

Run: `cd templates && ./tests/run.sh`
Expected: all backward-compat tests still PASS (the thin-recipe branch is unchanged behavior), `Failed: 0`.

- [ ] **Step 3: Commit**

```bash
git add templates/assemble.sh
git commit -m "feat: assemble.sh layers domain pack + sub-domain"
```

### Task 5: Addon installation

**Files:**
- Modify: `templates/assemble.sh` (after the layering block)

- [ ] **Step 1: Add the addon loop**

Immediately after the layering block from Task 4, add:

```bash
# --- addons (domain-scoped, _modules-shaped) --------------------------------
if [ -n "$DOMAIN_DIR" ]; then
  while IFS= read -r addon; do
    [ -z "$addon" ] && continue
    adir="$DOMAIN_DIR/_addons/$addon"
    if [ -d "$adir" ]; then
      echo "→ addon: $addon"
      [ -d "$adir/files" ] && { cp -R "$adir/files/." "$TARGET/"; merge_fragments; }
      [ -f "$adir/claude-md.md" ] && {
        printf '\n' >> "$TARGET/CLAUDE.md"; cat "$adir/claude-md.md" >> "$TARGET/CLAUDE.md"; }
      PICKED+=("addon/$addon")
    else
      echo "  ! addon not found: $addon (skipped)" >&2
    fi
  done <<EOF
$(cfg_list domain.addons)
EOF
fi
```

- [ ] **Step 2: Run the harness**

Run: `cd templates && ./tests/run.sh`
Expected: `Failed: 0` (no domain has `_addons/` yet, so the loop is inert; backward-compat holds).

- [ ] **Step 3: Commit**

```bash
git add templates/assemble.sh
git commit -m "feat: assemble.sh installs domain addons"
```

### Task 6: Agent-team resolution

**Files:**
- Modify: `templates/assemble.sh` (after the addon loop)

- [ ] **Step 1: Add agent-team resolution**

After the addon loop, add:

```bash
# --- agent team: curated minus exclude plus include ------------------------
AGENTS_DIR="$TARGET/.claude/agents"
if [ "$(cfg agents.team)" = "none" ] && [ -d "$AGENTS_DIR" ]; then
  find "$AGENTS_DIR" -name '*.md' ! -name 'README.md' -delete
  echo "→ agents: team=none (specialist agents removed)"
fi
while IFS= read -r ex; do
  [ -z "$ex" ] && continue
  rm -f "$AGENTS_DIR/$ex.md" && echo "  · agent excluded: $ex"
done <<EOF
$(cfg_list agents.exclude)
EOF
while IFS= read -r inc; do
  [ -z "$inc" ] && continue
  # inc form: <domain>/<sub-domain>/<agent>  -> templates/.../files/.claude/agents/<agent>.md
  src="$HERE/${inc%/*}/files/.claude/agents/${inc##*/}.md"
  if [ -f "$src" ]; then
    mkdir -p "$AGENTS_DIR"; cp "$src" "$AGENTS_DIR/"; echo "  · agent included: $inc"
  else
    echo "  ! agent not found: $inc (skipped)" >&2
  fi
done <<EOF
$(cfg_list agents.include)
EOF
```

- [ ] **Step 2: Run the harness**

Run: `cd templates && ./tests/run.sh`
Expected: `Failed: 0` (no agents config in thin recipes; blocks are inert).

- [ ] **Step 3: Commit**

```bash
git add templates/assemble.sh
git commit -m "feat: assemble.sh resolves agent teams (exclude/include)"
```

### Task 7: Conditional Context7 wiring

**Files:**
- Modify: `templates/assemble.sh` (before the project-name substitution)

- [ ] **Step 1: Add Context7 opt-out**

The domain ships `context7.mcp.json.fragment` separately from `web.mcp.json.fragment`. `apply_layer` copies whatever is in `files/`; Context7 must only be merged when `docs.context7_mcp` is true. Add, before the project-name substitution:

```bash
# --- docs: Context7 live-docs MCP (opt-in) ----------------------------------
if [ "$(cfg docs.context7_mcp)" = "true" ] && [ -n "$DOMAIN_DIR" ] \
   && [ -f "$DOMAIN_DIR/files/.claude/context7.mcp.json.fragment" ]; then
  cp "$DOMAIN_DIR/files/.claude/context7.mcp.json.fragment" "$TARGET/.mcp.json.fragment"
  merge_fragments
  echo "→ docs: Context7 MCP wired"
fi
rm -f "$TARGET/.claude/context7.mcp.json.fragment"   # never ship the raw fragment
```

Note: place `context7.mcp.json.fragment` at `web/files/.claude/` so it is NOT auto-merged by `apply_layer` (only files literally named `*.fragment.json` / `.mcp.json.fragment` at the merge paths are merged; this one has a distinct name and is handled here explicitly, then removed).

- [ ] **Step 2: Run the harness**

Run: `cd templates && ./tests/run.sh`
Expected: `Failed: 0`.

- [ ] **Step 3: Commit**

```bash
git add templates/assemble.sh
git commit -m "feat: assemble.sh wires Context7 MCP when docs.context7_mcp=true"
```

---

## Phase 3 — Extended config schema & docs

### Task 8: Extend harness.config.yml and document the schema

**Files:**
- Modify: `templates/harness.config.yml`
- Modify: `templates/README.md`

- [ ] **Step 1: Add the three new blocks to harness.config.yml**

Remove the `domain:` line from the `project:` block. Append these blocks (keep the existing heavily-commented style):

```yaml
# ── DOMAIN PACK ─────────────────────────────────────────────────────────────
# Curated, three-layer domain content. Leave pack empty for a base-only harness.
domain:
  pack: ""            # web | data | devops | ... | "" (base only)
  subdomain: ""       # the assemble unit, e.g. frontend-app — see <pack>/DOMAIN.md
  addons: []          # domain-scoped extras, e.g. [nextjs, tailwind-shadcn]

# ── AGENTS ──────────────────────────────────────────────────────────────────
agents:
  team: curated       # curated = install the sub-domain's team | none
  exclude: []         # drop named agents from the curated team
  include: []         # add agents à-la-carte, by path: <pack>/<subdomain>/<agent>

# ── DOCS ────────────────────────────────────────────────────────────────────
docs:
  context7_mcp: true  # wire the Context7 live-docs MCP (false = dossier only)
```

- [ ] **Step 2: Document the three-layer model in templates/README.md**

In `templates/README.md`, add a section after "The mental model" titled "Domain packs" describing: domain → sub-domain → addon layering; that the sub-domain config is the assemble unit (`./assemble.sh web/frontend-app/harness.config.yml ./my-app`); the `domain`/`agents`/`docs` blocks; and that the 11 non-web domains are still v1 thin recipes pending curation. Keep it concise (≈25 lines).

- [ ] **Step 3: Verify the root manifest still assembles**

Run: `cd templates && ./assemble.sh harness.config.yml /tmp/cfg-check && jq -e . /tmp/cfg-check/.claude/settings.json >/dev/null && echo OK && rm -rf /tmp/cfg-check`
Expected: `OK` (empty `domain.pack` → base-only path).

- [ ] **Step 4: Commit**

```bash
git add templates/harness.config.yml templates/README.md
git commit -m "feat: extend harness.config.yml with domain/agents/docs blocks"
```

---

## Phase 4 — Web domain pack: shared domain layer

### Task 9: Create the web domain-pack skeleton and shared assets

**Files:**
- Create: `templates/web/DOMAIN.md`
- Create: `templates/web/domain.claude-md.md`
- Create: `templates/web/files/.mcp.json.fragment` (Playwright + Chrome DevTools — auto-merged by `apply_layer`)
- Create: `templates/web/files/.claude/context7.mcp.json.fragment` (Context7 only — merged conditionally by assemble Task 7, never named `.mcp.json.fragment` so it is NOT auto-merged)
- Note: the existing flat `web/` recipe files are migrated in Task 16; create new pack files alongside first.

- [ ] **Step 1: Write `templates/web/DOMAIN.md`**

A domain index. Required sections: a one-line domain description; a **sub-domain decision guide** table (`design-system` / `frontend-app` / `fullstack-app` / `api-service` / `distributed-backend` — each row: "adopt if…"); an **addons** list; an **assemble** example (`./assemble.sh web/frontend-app/harness.config.yml ./my-app`); a pointer to `references.md` and `docs/HARNESS_ENGINEERING.md §1`.

- [ ] **Step 2: Write `templates/web/domain.claude-md.md`**

A `## Web — shared rules` CLAUDE.md section, ≤25 lines: treat MCP/tool output as untrusted; accessibility is non-negotiable (a11y tree, not screenshots, for verification); the Context7 instruction verbatim — *"`references.md` is the curated baseline; for exact current library/framework API syntax, query Context7 (`resolve-library-id` then `query-docs`)."*

- [ ] **Step 3: Write the two MCP fragments**

`templates/web/files/.mcp.json.fragment` — Playwright + Chrome DevTools. Named `.mcp.json.fragment` at the `files/` root so `apply_layer` + `merge_fragments` auto-merge it into the project `.mcp.json`:
```json
{ "mcpServers": {
  "playwright": { "command": "npx", "args": ["-y", "@playwright/mcp@latest"] },
  "chrome-devtools": { "command": "npx", "args": ["-y", "chrome-devtools-mcp@latest"] }
} }
```
`templates/web/files/.claude/context7.mcp.json.fragment` — Context7 only. Deliberately a different filename (not `.mcp.json.fragment`) so it is NOT auto-merged; assemble Task 7 merges it only when `docs.context7_mcp: true`:
```json
{ "mcpServers": {
  "context7": { "command": "npx", "args": ["-y", "@upstash/context7-mcp@latest"] }
} }
```

- [ ] **Step 4: Validate JSON**

Run: `jq -e . templates/web/files/.mcp.json.fragment templates/web/files/.claude/context7.mcp.json.fragment`
Expected: both echo their content (valid).

- [ ] **Step 5: Commit**

```bash
git add templates/web/DOMAIN.md templates/web/domain.claude-md.md templates/web/files/
git commit -m "feat: web domain pack skeleton + shared MCP fragments"
```

### Task 10: Write the web domain dossier

**Files:**
- Create: `templates/web/references.md`

- [ ] **Step 1: Research current web-platform practice**

Use WebSearch + the Context7 MCP (`resolve-library-id`, `query-docs`) to gather current (2026) facts on: framework landscape (Next.js App Router, Remix, Astro, SvelteKit), the accessibility-tree verification approach, Core Web Vitals thresholds (LCP/INP/CLS), and shadcn/ui status. Capture sources with URLs.

- [ ] **Step 2: Write `templates/web/references.md` in the fixed dossier shape**

```markdown
# Web — reference dossier

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices
<researched bullets — frameworks, RSC/SSR, a11y-tree verification, CWV budgets>

## Common gotchas / failure modes
<researched bullets — screenshot-only verification, useEffect-for-data, etc.>

## Version-sensitive notes
<dated, version-pinned notes>

## Cited links
- <url> — <what it is good for>
```

Acceptance: has the `Verified:` header, all four sections non-empty, ≥5 cited links each annotated.

- [ ] **Step 3: Commit**

```bash
git add templates/web/references.md
git commit -m "docs: web domain reference dossier"
```

### Task 11: Build the 3 shared web agents

**Files:**
- Create: `templates/web/files/.claude/agents/design-critic.md`
- Create: `templates/web/files/.claude/agents/accessibility-auditor.md`
- Create: `templates/web/files/.claude/agents/web-perf-auditor.md`

- [ ] **Step 1: Write `design-critic.md`** (exemplar — the other two follow the same shape)

```markdown
---
name: design-critic
description: Reviews rendered UI for visual hierarchy, spacing, consistency, and UX quality. Use after a UI change is rendered.
tools: ["Read", "Grep", "Glob", "mcp__playwright__browser_snapshot", "mcp__playwright__browser_take_screenshot"]
model: opus
---

You are a senior product designer reviewing a rendered interface. You are
READ-ONLY — you never edit code; you return a critique.

Evaluate: visual hierarchy, spacing rhythm, alignment, typographic scale,
color/contrast, component consistency, empty/error/loading states, responsive
behavior. Use the Playwright accessibility-tree snapshot as the primary source;
take a screenshot only to confirm a flagged visual issue.

Return STRICTLY this shape:

## Verdict
PASS | CHANGES-REQUESTED

## Findings
- [severity: high|med|low] <file:line or selector> — <issue> — <fix>

## What works
- <brief positives>
```

- [ ] **Step 2: Write `accessibility-auditor.md`**

Same frontmatter shape. `tools: ["Read","Grep","Glob","Bash"]` (runs `axe`), `model: sonnet`. System prompt: read-only WCAG 2.2 AA auditor; run `@axe-core` against the rendered page; return a findings list keyed to WCAG success criteria with file/line and remediation; same `## Verdict / ## Findings` return shape.

- [ ] **Step 3: Write `web-perf-auditor.md`**

`tools: ["Read","Grep","Glob","Bash","mcp__chrome-devtools__performance_start_trace","mcp__chrome-devtools__performance_stop_trace"]`, `model: sonnet`. System prompt: read-only performance auditor; run Lighthouse / Chrome DevTools trace; compare LCP/INP/CLS against `lighthouse-budget.json`; return PASS/CHANGES-REQUESTED with per-metric measured-vs-budget.

- [ ] **Step 4: Validate frontmatter**

Run:
```bash
for a in templates/web/files/.claude/agents/*.md; do
  head -1 "$a" | grep -qx -- '---' && grep -q '^name:' "$a" \
    && grep -q '^tools:' "$a" && echo "OK $a" || echo "BAD $a"; done
```
Expected: `OK` for all three. Manually confirm no agent lists `Edit`, `Write`, or unrestricted `Bash` write access beyond what its role needs.

- [ ] **Step 5: Commit**

```bash
git add templates/web/files/.claude/agents/
git commit -m "feat: shared web agents (design-critic, a11y, perf)"
```

---

## Phase 5 — Web sub-domains & their agent teams

> Each sub-domain folder has the same structure. Task 12 builds `frontend-app` in full as the exemplar; Task 13 builds the other four from a complete spec table.

### Task 12: Build the `frontend-app` sub-domain (exemplar)

**Files:**
- Create: `templates/web/frontend-app/SUBDOMAIN.md`
- Create: `templates/web/frontend-app/harness.config.yml`
- Create: `templates/web/frontend-app/references.md`
- Create: `templates/web/frontend-app/claude-md.md`
- Create: `templates/web/frontend-app/files/.claude/agents/{frontend-architect,frontend-implementer}.md`
- Create: `templates/web/frontend-app/files/.claude/skills/verifying-web-ui/SKILL.md`
- Create: `templates/web/frontend-app/files/.claude/settings.fragment.json`

- [ ] **Step 1: Write `harness.config.yml`**

A full manifest in the schema from Task 8: `domain: {pack: web, subdomain: frontend-app, addons: [vite-spa, tailwind-shadcn]}`, `agents: {team: curated, exclude: [], include: []}`, `docs: {context7_mcp: true}`, plus sensible cross-cutting defaults (`memory: md-files`, `progress: filesystem`, `methodology: {tdd: true, spec_driven: true, eval_driven: false, bdd: true}`, `orchestration: single-agent`, `safety` all false, `hitl` both true). Comment every non-default choice.

- [ ] **Step 2: Write `SUBDOMAIN.md`**

Sections: one-line description; **Adopt if** (building a client app that consumes APIs it does not own); **Skip if** (you own the backend → `fullstack-app`; you ship a library → `design-system`); **Addons that pair well** (`vite-spa`/`nextjs`, `tailwind-shadcn`, `authjs`); **Agent team** (lists `frontend-architect`, `frontend-implementer` + the 3 shared).

- [ ] **Step 3: Write `claude-md.md`**

A `## Web — frontend-app` section, ≤20 lines: backend is mocked at a typed boundary; data fetching/state/routing rules; the verification loop (a11y tree + Lighthouse budget + component tests); never claim a UI change done without a render check.

- [ ] **Step 4: Write `references.md`**

The fixed dossier shape (Task 10 template), researched for client-app concerns: state management, data fetching, routing, client performance, forms. `Verified: 2026-05` header, ≥5 cited links.

- [ ] **Step 5: Write the 2 specialist agents**

`frontend-architect.md` — `tools: ["Read","Grep","Glob","WebFetch","mcp__context7__*"]`, `model: opus`, read-only; returns a typed plan (routing map, state strategy, data-fetch boundaries, component breakdown, acceptance criteria). `frontend-implementer.md` — `tools: ["Read","Edit","Write","Bash","Grep","Glob"]`, `model: sonnet`; bounded to the components/files named in the architect's plan; returns a diff + summary. Both use the `## Verdict`/typed-return discipline from Task 11.

- [ ] **Step 6: Write `verifying-web-ui/SKILL.md`**

Migrate the existing `web/files/.claude/skills/verifying-web-ui/SKILL.md` content; SKILL.md frontmatter `name: verifying-web-ui`, description "what + when". Body: the accessibility-tree verification loop (edit → render → a11y snapshot → axe → Lighthouse budget → screenshot only on flagged diff).

- [ ] **Step 7: Write `settings.fragment.json`**

Register any sub-domain hook. `frontend-app` reuses the shared `web-verify.sh` (registered by the domain layer in Task 16), so this fragment is `{ "hooks": {} }` unless a sub-domain-specific hook is added — keep it minimal/valid.

- [ ] **Step 8: Assemble and verify**

Run: `cd templates && ./assemble.sh web/frontend-app/harness.config.yml /tmp/fa && jq -e . /tmp/fa/.claude/settings.json /tmp/fa/.mcp.json >/dev/null && ls /tmp/fa/.claude/agents && echo OK && rm -rf /tmp/fa`
Expected: `OK`; agents dir lists `design-critic`, `accessibility-auditor`, `web-perf-auditor`, `frontend-architect`, `frontend-implementer`; `.mcp.json` contains `playwright`, `chrome-devtools`, `context7`.

- [ ] **Step 9: Commit**

```bash
git add templates/web/frontend-app/
git commit -m "feat: web frontend-app sub-domain + agent team"
```

### Task 13: Build the other 4 sub-domains

**Files:** for each of `design-system`, `fullstack-app`, `api-service`, `distributed-backend` — the same 7 files as Task 12 under `templates/web/<sub-domain>/`.

Build each exactly like Task 12 (same file set, same dossier shape, same agent-frontmatter discipline: architects/auditors read-only with `model: opus`; implementers `model: sonnet` with bounded `Edit/Write/Bash`; reviewers a different model than the implementer). Per-sub-domain specifics:

| Sub-domain | config `subdomain` / default `addons` | Specialist agents (frontmatter `model`, read/write) | Sub-domain hook | claude-md.md focus |
|---|---|---|---|---|
| `design-system` | `design-system` / `[tailwind-shadcn]` | `component-architect` (opus, RO), `component-implementer` (sonnet, RW bounded), `visual-regression-tester` (haiku, Bash+screenshot RO) | `visual-regression-check.sh` (PostToolUse `Write\|Edit` — advisory: reminds to update visual snapshots) | published component-API stability; semver; Storybook; tokens; no app shell |
| `fullstack-app` | `fullstack-app` / `[nextjs, tailwind-shadcn, drizzle, authjs]` | `fullstack-architect` (opus, RO), `fullstack-implementer` (sonnet, RW bounded), `data-layer-implementer` (sonnet, RW — **must not run destructive SQL**), `security-auditor` (opus, RO) | none (reuses shared `web-verify.sh`) | no network boundary — Server Actions/templates; the loop spans client+server; auth + data access in one deployable |
| `api-service` | `api-service` / `[openapi-rest]` (addon built in Phase 6 only if in initial set; otherwise `[]`) | `api-architect` (opus, RO — schema-first), `api-implementer` (sonnet, RW bounded), `contract-reviewer` (sonnet, RO — **different model than implementer**), `api-security-auditor` (opus, RO — OWASP API Top 10) | `contract-drift-check.sh` (PostToolUse `Write\|Edit` — advisory: flags handler edits without a matching schema/spec change) | schema-first; one service, no UI; contract tests; auth/z; input validation |
| `distributed-backend` | `distributed-backend` / `[]` | `service-architect` (opus, RO — boundaries/contracts/messaging), `service-implementer` (sonnet, RW — **bounded to ONE service per invocation**), `contract-reviewer` (sonnet, RO — consumer-driven contracts), `integration-tester` (sonnet, Bash + Edit on test files only), `security-auditor` (opus, RO) | `contract-drift-check.sh` (as above) | service boundaries; consumer-driven contracts; messaging/events; eventual consistency; one service per change |

Each `harness.config.yml` uses the Task 12 cross-cutting defaults except: `api-service` and `distributed-backend` set `methodology.bdd: false`; `distributed-backend` may set `orchestration: pipeline`. Each `SUBDOMAIN.md` has Adopt-if / Skip-if / pairing addons / agent team. Each `references.md` is researched (WebSearch + Context7) with the `Verified: 2026-05` header and ≥5 cited links.

- [ ] **Step 1: Build `design-system/`** (7 files per the table row)
- [ ] **Step 2: Assemble & verify** — `./assemble.sh web/design-system/harness.config.yml /tmp/ds`; assert valid `settings.json`/`.mcp.json`, agents dir holds the 3 specialists + 2 shared (`web-perf-auditor` excluded if not in roster — confirm against the table), then `rm -rf /tmp/ds`
- [ ] **Step 3: Build `fullstack-app/`** (7 files)
- [ ] **Step 4: Assemble & verify `fullstack-app`**
- [ ] **Step 5: Build `api-service/`** (7 files)
- [ ] **Step 6: Assemble & verify `api-service`**
- [ ] **Step 7: Build `distributed-backend/`** (7 files)
- [ ] **Step 8: Assemble & verify `distributed-backend`**
- [ ] **Step 9: Validate every new agent's frontmatter**

Run:
```bash
for a in templates/web/*/files/.claude/agents/*.md; do
  grep -q '^name:' "$a" && grep -q '^tools:' "$a" && grep -q '^model:' "$a" \
    && echo "OK $a" || echo "BAD $a"; done
```
Expected: `OK` for all. Manually confirm no architect/auditor/reviewer lists `Edit` or `Write`.

- [ ] **Step 10: Commit**

```bash
git add templates/web/design-system/ templates/web/fullstack-app/ \
        templates/web/api-service/ templates/web/distributed-backend/
git commit -m "feat: web design-system/fullstack-app/api-service/distributed-backend sub-domains"
```

### Task 14: Add sub-domain test coverage

**Files:**
- Modify: `templates/tests/run.sh`

- [ ] **Step 1: Add a domain-pack test block**

After the mcp-merge block in `tests/run.sh`, add:

```bash
echo "== web domain pack: every sub-domain assembles =="
for sd in design-system frontend-app fullstack-app api-service distributed-backend; do
  assemble "web/$sd/harness.config.yml"
  if [ $? -eq 0 ] \
     && jq -e . "$OUT/.claude/settings.json" >/dev/null 2>&1 \
     && jq -e . "$OUT/.mcp.json" >/dev/null 2>&1 \
     && [ -n "$(ls -A "$OUT/.claude/agents" 2>/dev/null)" ]; then
    ok "web/$sd"
  else
    fail "web/$sd"
  fi
  rm -rf "$OUT"
done
```

- [ ] **Step 2: Run the harness**

Run: `cd templates && ./tests/run.sh`
Expected: backward-compat + mcp-merge + 5 web sub-domain tests all PASS, `Failed: 0`.

- [ ] **Step 3: Commit**

```bash
git add templates/tests/run.sh
git commit -m "test: cover web domain-pack assembly"
```

---

## Phase 6 — Web addons (initial set)

### Task 15: Build the 7 initial web addons

**Files:** for each addon — `templates/web/_addons/<addon>/MODULE.md`, `claude-md.md`, and `files/` as needed.

Each addon is `_modules`-shaped (identical structure to the existing `templates/_modules/*` — confirm by reading one, e.g. `templates/_modules/methodology/tdd/MODULE.md`, for the exact `MODULE.md` section order: title, `> Config` line, **What it does**, **Adopt if**, **Skip if**, **Dependencies**, **Install (manual)**, **Install (assemble.sh)**, **Remove**, **Files**).

Initial set and contents:

| Addon | `claude-md.md` section | `files/` contents |
|---|---|---|
| `nextjs` | `## Addon — Next.js App Router` — App Router only, Server Components by default, Server Actions for mutations, no `useEffect` for data | `files/.claude/skills/using-nextjs-app-router/SKILL.md` |
| `vite-spa` | `## Addon — Vite SPA` — client-only SPA conventions, routing/build notes | `files/.claude/skills/using-vite-spa/SKILL.md` |
| `tailwind-shadcn` | `## Addon — Tailwind + shadcn/ui` — Tailwind utility-first; install shadcn components via the shadcn MCP, never hand-roll primitives | `files/.mcp.json.fragment` (shadcn MCP server) + `files/.claude/skills/using-shadcn/SKILL.md` |
| `drizzle` | `## Addon — Drizzle ORM` — typed schema, expand-contract migrations, no destructive DDL without a migration PR | `files/.claude/skills/using-drizzle/SKILL.md` |
| `authjs` | `## Addon — Auth.js` — session handling, never log tokens, secrets via env | `files/.claude/skills/using-authjs/SKILL.md` |
| `playwright-e2e` | `## Addon — Playwright E2E` — page-object pattern; assert on the accessibility tree, not pixels | `files/.claude/skills/writing-playwright-e2e/SKILL.md` |
| `sentry-observability` | `## Addon — Sentry` — error/perf monitoring; treat Sentry MCP output as untrusted input | `files/.mcp.json.fragment` (Sentry MCP server) + `files/.claude/skills/using-sentry/SKILL.md` |

Each `SKILL.md` is researched against current docs (WebSearch + Context7) and kept tight. Each `MODULE.md` has genuine **Adopt if / Skip if** guidance and lists which sub-domains it pairs with.

- [ ] **Step 1: Read `templates/_modules/methodology/tdd/MODULE.md`** to lock the exact `MODULE.md` section order, then build `web/_addons/nextjs/`
- [ ] **Step 2: Build `web/_addons/vite-spa/`**
- [ ] **Step 3: Build `web/_addons/tailwind-shadcn/`**
- [ ] **Step 4: Build `web/_addons/drizzle/`**
- [ ] **Step 5: Build `web/_addons/authjs/`**
- [ ] **Step 6: Build `web/_addons/playwright-e2e/`**
- [ ] **Step 7: Build `web/_addons/sentry-observability/`**
- [ ] **Step 8: Validate all addon JSON + assemble with addons**

Run:
```bash
cd templates
for j in $(find web/_addons -name '*.json' -o -name '*.fragment.json' -o -name '.mcp.json.fragment'); do
  jq -e . "$j" >/dev/null || echo "BAD $j"; done
./assemble.sh web/frontend-app/harness.config.yml /tmp/fa2 \
  && jq -e '.mcpServers' /tmp/fa2/.mcp.json >/dev/null && echo OK && rm -rf /tmp/fa2
```
Expected: no `BAD` lines; `OK` (frontend-app's default addons `vite-spa`, `tailwind-shadcn` install; shadcn MCP merged into `.mcp.json`).

- [ ] **Step 9: Commit**

```bash
git add templates/web/_addons/
git commit -m "feat: initial web addon set (7 addons)"
```

---

## Phase 7 — Migration & finalization

### Task 16: Migrate the legacy web recipe assets

**Files:**
- Modify: move/redistribute existing `templates/web/` flat-recipe files
- Create: `templates/web/files/.claude/hooks/web-verify.sh`, `templates/web/files/.claude/settings.fragment.json`, `templates/web/files/lighthouse-budget.json`, `templates/web/files/.claude/skills/verifying-web-ui/SKILL.md`
- Delete: `templates/web/harness.config.yml`, `templates/web/claude-md.md`, `templates/web/README.md`, and the old `templates/web/files/.claude/...` recipe locations once moved

- [ ] **Step 1: Inventory the legacy web recipe**

Run: `find templates/web -maxdepth 3 -type f | sort` and identify the legacy flat-recipe files (`web/harness.config.yml`, `web/claude-md.md`, `web/README.md`, `web/files/.claude/hooks/web-verify.sh`, `web/files/.claude/skills/verifying-web-ui/`, `web/files/lighthouse-budget.json`, `web/files/.claude/settings.fragment.json`) versus the new pack files created in Phases 4–6.

- [ ] **Step 2: Move shared assets to the domain `files/` layer**

`web-verify.sh`, `lighthouse-budget.json`, and the shared `settings.fragment.json` (registering `web-verify.sh` as a PostToolUse hook) belong at `templates/web/files/.claude/...` and `templates/web/files/lighthouse-budget.json` — already the correct domain-shared path. Confirm they sit there; the `verifying-web-ui` skill now lives per sub-domain (created in Task 12) — delete the legacy domain-level copy if duplicated.

- [ ] **Step 3: Fold legacy `claude-md.md` into `domain.claude-md.md`**

Merge any still-relevant rules from the legacy `web/claude-md.md` into `web/domain.claude-md.md` (Task 9). Delete `web/claude-md.md`.

- [ ] **Step 4: Replace `web/README.md` with `DOMAIN.md`**

`DOMAIN.md` (Task 9) supersedes the recipe `README.md`. Delete `web/README.md`. Delete `web/harness.config.yml` (each sub-domain now has its own).

- [ ] **Step 5: Verify the legacy thin-recipe path no longer resolves for web, and the pack does**

Run: `cd templates && ls web/harness.config.yml 2>/dev/null; ./assemble.sh web/frontend-app/harness.config.yml /tmp/wm && grep -q 'Web — shared rules' /tmp/wm/CLAUDE.md && echo OK && rm -rf /tmp/wm`
Expected: `web/harness.config.yml` not found; `OK` (domain layer applied).

- [ ] **Step 6: Commit**

```bash
git add -A templates/web/
git commit -m "refactor: migrate legacy web recipe into the web domain pack"
```

### Task 17: Mark the 11 other recipes as v1 thin

**Files:**
- Modify: `templates/{data,devops,finance,mobile,game,embedded,scientific,security,content,ops}/README.md`
- Modify: `templates/generic/README.md`

- [ ] **Step 1: Add a status banner to each of the 11 recipe READMEs**

At the top of each `README.md` (just under the title), insert:

```markdown
> **Status: v1 thin recipe** — pending deep curation into a three-layer domain
> pack (see `web/` for the curated reference and
> `docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md`).
> It assembles and works today; sub-domains and curated agent teams are coming.
```

For `generic/README.md` use instead: a one-line note that `generic` is intentionally base-only and not a domain pack.

- [ ] **Step 2: Verify all 11 still assemble**

Run: `cd templates && ./tests/run.sh`
Expected: all backward-compat recipe tests still PASS (web is no longer a thin recipe — see next step).

- [ ] **Step 3: Update tests/run.sh — web is now a pack, not a thin recipe**

In `tests/run.sh`, remove `web` from the backward-compat `for d in …` recipe list (web is covered by the domain-pack block from Task 14). Re-run `./tests/run.sh`; expected `Failed: 0`.

- [ ] **Step 4: Commit**

```bash
git add templates/*/README.md templates/tests/run.sh
git commit -m "docs: mark 11 non-web recipes as v1 thin pending curation"
```

### Task 18: End-to-end verification

**Files:** none (verification only)

- [ ] **Step 1: Full harness run**

Run: `cd templates && ./tests/run.sh`
Expected: every block PASS — 12 backward-compat (11 recipes + root), mcp-merge, 5 web sub-domains — `Failed: 0`, exit 0.

- [ ] **Step 2: Addon + à-la-carte agent smoke test**

Run:
```bash
cd templates
cp web/fullstack-app/harness.config.yml /tmp/fs.yml
# exercise exclude + include + an addon set via a hand-edited config
./assemble.sh /tmp/fs.yml /tmp/fs && \
  jq -e . /tmp/fs/.claude/settings.json /tmp/fs/.mcp.json >/dev/null && \
  ls /tmp/fs/.claude/agents && cat /tmp/fs/.claude/HARNESS.lock && rm -rf /tmp/fs /tmp/fs.yml
```
Expected: valid JSON; agents dir reflects the fullstack-app team; `HARNESS.lock` lists base + modules + `domain/web/fullstack-app` + addons.

- [ ] **Step 3: Validate all JSON + hook syntax repo-wide**

Run:
```bash
cd templates
bad=0
for j in $(find . -name '*.json' -o -name '*.fragment.json' -o -name '.mcp.json.fragment'); do
  jq -e . "$j" >/dev/null 2>&1 || { echo "INVALID $j"; bad=1; }; done
for h in $(find . -name '*.sh'); do bash -n "$h" || { echo "SYNTAX $h"; bad=1; }; done
[ $bad -eq 0 ] && echo "ALL VALID"
```
Expected: `ALL VALID`.

- [ ] **Step 4: Confirm dossiers carry the Verified header**

Run: `cd templates && for r in web/references.md web/*/references.md; do grep -q '^> Verified:' "$r" && echo "OK $r" || echo "MISSING $r"; done`
Expected: `OK` for the domain dossier and all 5 sub-domain dossiers.

- [ ] **Step 5: Commit (if any verification fix was needed; otherwise skip)**

```bash
git add -A templates/
git commit -m "test: end-to-end verification of the web domain pack"
```

---

## Self-Review

- **Spec coverage:** §3.1 extended schema → Task 8. §3.2 assemble.sh v2 (layering, MCP merge, agent resolution, backward-compat) → Tasks 2–7. §4.1 sub-domains → Tasks 12–13. §4.2 addons (initial set) → Task 15. §4.3 agent teams → Tasks 11–13. §5 dossier + Context7 → Tasks 7, 9, 10, 12, 13. §6 migration → Tasks 16–17. §9 success criteria → Tasks 1, 14, 18. All spec sections map to tasks.
- **Placeholder scan:** content-heavy artifacts (dossiers, skills, agent prompts) have explicit structure, frontmatter, acceptance criteria, and a research step with concrete targets — these are content contracts, not placeholders. assemble.sh tasks contain complete bash.
- **Type consistency:** `merge_json`/`merge_fragments` (Task 2) used consistently in Tasks 4–7. `cfg`/`cfg_list` (Task 3) used in Tasks 5–7. `apply_layer` (Task 4) used in Tasks 4, 7. `DOMAIN_DIR`/`CONFIG_DIR`/`PICKED`/`TARGET`/`HERE`/`JQ_OK` are the existing assemble.sh variables. Agent `tools`/`model` frontmatter keys consistent across Tasks 11–13.
- **Known caveat carried from spec §10:** stacked `CLAUDE.md` length is an accepted tradeoff; no task forces a hard cap.
```
