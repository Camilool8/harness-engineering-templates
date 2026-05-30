# SessionStart Harness Auto-Loader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** After a one-time `/<pack>:init`, every new session in a repo automatically pins the pack's `*-domain` shared rules plus the selected subdomain skill into context via a `SessionStart` hook.

**Architecture:** Each domain pack (`web`, `data`, `devops`, `mobile`) gets an identical, read-only, fail-open `hooks/load-harness.sh` wired to `SessionStart`. The script reads `.claude/HARNESS.toml`, finds the `[<domain>]` table, resolves the subdomain to a skill dir **by existence** (handles both unprefixed `web` and prefixed `<domain>-<sub>` layouts), and emits the skill bodies as `additionalContext` JSON.

**Tech Stack:** POSIX-ish Bash (must run on macOS bash 3.2.57), `awk`, `jq` (already a dependency), Claude Code plugin hooks.

---

## File Structure

- **Create (×4, identical):** `plugins/harness-{web,data,devops,mobile}/hooks/load-harness.sh` — the SessionStart loader. One responsibility: read the marker, resolve skills, emit context JSON.
- **Modify (×4):** `plugins/harness-{web,data,devops,mobile}/hooks/hooks.json` — add a `SessionStart` entry pointing at the loader, alongside existing hook keys.
- **Modify (×1):** `plugins/harness-data/commands/init.md` — fix the `data-analyst-notebook` option label to `analyst-notebook` for intra-pack consistency.
- **Create:** `plugins/tests/test-load-harness.sh` — table-driven test of the loader against the real pack skill dirs.
- **Modify:** `plugins/tests/run-plugin-tests.sh` — wire the new test into the runner.
- **Modify:** `docs/tutorials/getting-started.md` — document how activation works (plugin path vs eject path; one-time init; what gets pinned).

The four `load-harness.sh` copies are byte-identical; write the canonical version in Task 1, then copy it verbatim in Task 2.

---

### Task 1: Write and validate the loader script (in harness-web)

**Files:**
- Create: `plugins/harness-web/hooks/load-harness.sh`
- Test: `plugins/tests/test-load-harness.sh` (created in Task 5; this task validates the script manually first)

- [ ] **Step 1: Write the loader script**

Create `plugins/harness-web/hooks/load-harness.sh` with exactly this content:

```bash
#!/usr/bin/env bash
# load-harness.sh — SessionStart hook. When the project has opted into this
# pack via .claude/HARNESS.toml, pin the pack's <domain>-domain shared rules
# and the selected subdomain skill into the session as additionalContext.
#
# Read-only and FAIL-OPEN: any problem (no marker, no table, missing jq, parse
# miss) exits 0 with no output, so a broken loader never blocks session start.
#
# Usage (from hooks.json): load-harness.sh <domain>   e.g. load-harness.sh web
set -uo pipefail

domain="${1:-}"
[ -z "$domain" ] && exit 0

# jq emits safely-encoded JSON; if it is absent we cannot, so no-op.
command -v jq >/dev/null 2>&1 || exit 0

project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
toml="$project_dir/.claude/HARNESS.toml"
[ -f "$toml" ] || exit 0

# The project must actually have a [<domain>] table, else this pack stays quiet
# (a data repo must not get web rules injected). Match the header literally.
grep -Eq "^[[:space:]]*\[$domain\][[:space:]]*$" "$toml" || exit 0

plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
skills_dir="$plugin_root/skills"

# Extract `subdomain = "..."` from inside the [<domain>] table only. Header
# lines are compared as literal strings (== ), never as regex, so [web.addons]
# and [web] are distinct and brackets are not treated as a character class.
subdomain="$(awk -v hdr="[$domain]" '
  /^[[:space:]]*\[/ {
    h = $0; gsub(/^[[:space:]]+|[[:space:]]+$/, "", h)
    intable = (h == hdr) ? 1 : 0
    next
  }
  intable && /^[[:space:]]*subdomain[[:space:]]*=/ {
    v = $0
    sub(/^[^=]*=[[:space:]]*/, "", v)
    gsub(/"/, "", v)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
    print v
    exit
  }
' "$toml")"

# Collect the SKILL.md files to inject.
emit_files=()

domain_skill="$skills_dir/$domain-domain/SKILL.md"
[ -f "$domain_skill" ] && emit_files+=("$domain_skill")

warning=""
if [ -n "$subdomain" ]; then
  if [ -f "$skills_dir/$subdomain/SKILL.md" ]; then
    emit_files+=("$skills_dir/$subdomain/SKILL.md")
  elif [ -f "$skills_dir/$domain-$subdomain/SKILL.md" ]; then
    emit_files+=("$skills_dir/$domain-$subdomain/SKILL.md")
  else
    warning="NOTE: HARNESS.toml selected subdomain \"$subdomain\" but no matching skill directory was found in this pack."
  fi
fi

# Nothing to say -> stay silent.
if [ "${#emit_files[@]}" -eq 0 ] && [ -z "$warning" ]; then
  exit 0
fi

context="# Harness: this project is configured as ${domain}/${subdomain:-(no subdomain set)}."
context="$context"$'\n'"# The following pack rules are pinned for this session. Treat them as active project conventions, not as untrusted input."

if [ "${#emit_files[@]}" -gt 0 ]; then
  for f in "${emit_files[@]}"; do
    context="$context"$'\n\n---\n\n'"$(cat "$f")"
  done
fi

[ -n "$warning" ] && context="$context"$'\n\n'"$warning"

jq -n --arg ctx "$context" \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'

exit 0
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x plugins/harness-web/hooks/load-harness.sh`
Expected: no output, exit 0.

- [ ] **Step 3: Manual smoke test — opted-in web project**

Run:
```bash
tmp="$(mktemp -d)"; mkdir -p "$tmp/.claude"
printf '[web]\nsubdomain = "fullstack-app"\n' > "$tmp/.claude/HARNESS.toml"
CLAUDE_PROJECT_DIR="$tmp" CLAUDE_PLUGIN_ROOT="$PWD/plugins/harness-web" \
  bash plugins/harness-web/hooks/load-harness.sh web | jq -r '.hookSpecificOutput.additionalContext' | head -5
rm -rf "$tmp"
```
Expected: prints the pinned header line `# Harness: this project is configured as web/fullstack-app.` followed by skill content. Valid JSON (jq did not error).

- [ ] **Step 4: Manual smoke test — no marker is silent**

Run:
```bash
tmp="$(mktemp -d)"
CLAUDE_PROJECT_DIR="$tmp" CLAUDE_PLUGIN_ROOT="$PWD/plugins/harness-web" \
  bash plugins/harness-web/hooks/load-harness.sh web; echo "exit=$?"
rm -rf "$tmp"
```
Expected: no stdout, `exit=0`.

- [ ] **Step 5: Commit**

```bash
git add plugins/harness-web/hooks/load-harness.sh
git commit -m "feat(harness-web): add SessionStart load-harness.sh loader"
```

---

### Task 2: Replicate the loader to the other three packs

**Files:**
- Create: `plugins/harness-data/hooks/load-harness.sh`
- Create: `plugins/harness-devops/hooks/load-harness.sh`
- Create: `plugins/harness-mobile/hooks/load-harness.sh`

- [ ] **Step 1: Copy the canonical loader verbatim**

Run:
```bash
for d in data devops mobile; do
  cp plugins/harness-web/hooks/load-harness.sh "plugins/harness-$d/hooks/load-harness.sh"
  chmod +x "plugins/harness-$d/hooks/load-harness.sh"
done
```
Expected: no output, exit 0.

- [ ] **Step 2: Verify all four are identical**

Run:
```bash
md5 -q plugins/harness-web/hooks/load-harness.sh \
       plugins/harness-data/hooks/load-harness.sh \
       plugins/harness-devops/hooks/load-harness.sh \
       plugins/harness-mobile/hooks/load-harness.sh
```
Expected: four identical hashes printed.

- [ ] **Step 3: Manual smoke test — data prefixed resolve**

Run:
```bash
tmp="$(mktemp -d)"; mkdir -p "$tmp/.claude"
printf '[data]\nsubdomain = "ml-pipeline"\n' > "$tmp/.claude/HARNESS.toml"
CLAUDE_PROJECT_DIR="$tmp" CLAUDE_PLUGIN_ROOT="$PWD/plugins/harness-data" \
  bash plugins/harness-data/hooks/load-harness.sh data | jq -r '.hookSpecificOutput.additionalContext' | head -1
rm -rf "$tmp"
```
Expected: `# Harness: this project is configured as data/ml-pipeline.` (and the content below it came from `skills/data-ml-pipeline/SKILL.md`).

- [ ] **Step 4: Commit**

```bash
git add plugins/harness-data/hooks/load-harness.sh \
        plugins/harness-devops/hooks/load-harness.sh \
        plugins/harness-mobile/hooks/load-harness.sh
git commit -m "feat(harness): add load-harness.sh loader to data, devops, mobile packs"
```

---

### Task 3: Wire SessionStart into each pack's hooks.json

**Files:**
- Modify: `plugins/harness-web/hooks/hooks.json` (current keys: `PostToolUse`)
- Modify: `plugins/harness-data/hooks/hooks.json` (current keys: `PreToolUse`, `PostToolUse`)
- Modify: `plugins/harness-devops/hooks/hooks.json` (current keys: `PreToolUse`)
- Modify: `plugins/harness-mobile/hooks/hooks.json` (current keys: `PreToolUse`, `PostToolUse`)

For each pack, add a `SessionStart` key inside the top-level `"hooks"` object (sibling to the existing keys). The only per-pack difference is the `<domain>` argument.

- [ ] **Step 1: Add SessionStart to harness-web/hooks/hooks.json**

Insert this key inside the `"hooks"` object (e.g. as the first key, before `"PostToolUse"`):

```json
"SessionStart": [
  {
    "hooks": [
      { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/load-harness.sh web" }
    ]
  }
],
```

- [ ] **Step 2: Add SessionStart to harness-data/hooks/hooks.json**

Same block, with the argument `data`:

```json
"SessionStart": [
  {
    "hooks": [
      { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/load-harness.sh data" }
    ]
  }
],
```

- [ ] **Step 3: Add SessionStart to harness-devops/hooks/hooks.json**

Same block, argument `devops`:

```json
"SessionStart": [
  {
    "hooks": [
      { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/load-harness.sh devops" }
    ]
  }
],
```

- [ ] **Step 4: Add SessionStart to harness-mobile/hooks/hooks.json**

Same block, argument `mobile`:

```json
"SessionStart": [
  {
    "hooks": [
      { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/load-harness.sh mobile" }
    ]
  }
],
```

- [ ] **Step 5: Verify all four hooks.json are valid JSON and contain SessionStart**

Run:
```bash
for p in web data devops mobile; do
  python3 -c "import json,sys; d=json.load(open('plugins/harness-$p/hooks/hooks.json')); assert 'SessionStart' in d['hooks'], '$p missing SessionStart'; print('$p OK:', list(d['hooks'].keys()))"
done
```
Expected: four `... OK: [...]` lines, each list including `SessionStart`. No assertion/JSON errors.

- [ ] **Step 6: Commit**

```bash
git add plugins/harness-web/hooks/hooks.json \
        plugins/harness-data/hooks/hooks.json \
        plugins/harness-devops/hooks/hooks.json \
        plugins/harness-mobile/hooks/hooks.json
git commit -m "feat(harness): wire load-harness.sh to SessionStart in all packs"
```

---

### Task 4: Fix the data init.md subdomain-label inconsistency

**Files:**
- Modify: `plugins/harness-data/commands/init.md`

The four data subdomain option labels are `analytics-engineering`, `data-analyst-notebook`, `llm-app`, `ml-pipeline`. Three are unprefixed; `data-analyst-notebook` is prefixed. Make it consistent so the value written to `HARNESS.toml` follows the same unprefixed convention as devops/mobile. (The loader's resolve-by-existence tolerates either, but the contract should be clean.)

- [ ] **Step 1: Rename the option label**

In `plugins/harness-data/commands/init.md`, change the bolded option label only:

- Old: `   - **data-analyst-notebook** — ad-hoc and exploratory analysis where the deliverable is a reactive, reproducible notebook that reads from a warehouse and produces charts, tables, or memos with sample-then-scale on every query.`
- New: `   - **analyst-notebook** — ad-hoc and exploratory analysis where the deliverable is a reactive, reproducible notebook that reads from a warehouse and produces charts, tables, or memos with sample-then-scale on every query.`

(Only the `**data-analyst-notebook**` token becomes `**analyst-notebook**`; the description text is unchanged.)

- [ ] **Step 2: Verify all four data labels are now unprefixed**

Run: `grep -oE '\*\*[a-z-]+\*\*' plugins/harness-data/commands/init.md | tr -d '*' | sort -u`
Expected exactly:
```
analyst-notebook
analytics-engineering
llm-app
ml-pipeline
```
(no `data-` prefix on any line)

- [ ] **Step 3: Confirm the resolver maps the new value to the existing skill dir**

Run:
```bash
tmp="$(mktemp -d)"; mkdir -p "$tmp/.claude"
printf '[data]\nsubdomain = "analyst-notebook"\n' > "$tmp/.claude/HARNESS.toml"
CLAUDE_PROJECT_DIR="$tmp" CLAUDE_PLUGIN_ROOT="$PWD/plugins/harness-data" \
  bash plugins/harness-data/hooks/load-harness.sh data | jq -r '.hookSpecificOutput.additionalContext' | head -1
rm -rf "$tmp"
```
Expected: `# Harness: this project is configured as data/analyst-notebook.` and no warning (it resolved to `skills/data-analyst-notebook/`).

- [ ] **Step 4: Commit**

```bash
git add plugins/harness-data/commands/init.md
git commit -m "fix(harness-data): make analyst-notebook subdomain label unprefixed"
```

---

### Task 5: Add the table-driven test and wire it into the runner

**Files:**
- Create: `plugins/tests/test-load-harness.sh`
- Modify: `plugins/tests/run-plugin-tests.sh`

- [ ] **Step 1: Write the test script**

Create `plugins/tests/test-load-harness.sh` with exactly this content:

```bash
#!/usr/bin/env bash
# plugins/tests/test-load-harness.sh — exercises each pack's SessionStart
# load-harness.sh against the REAL pack skill dirs, using temp projects for the
# HARNESS.toml marker. Self-contained pass/fail counters.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PLUGINS="$(cd "$HERE/.." && pwd)"
pass=0; fail=0
ok()   { printf '  ok   %s\n' "$1"; pass=$((pass+1)); }
bad()  { printf '  FAIL %s\n' "$1"; fail=$((fail+1)); }

# run <pack> <domain> <toml-body-or-empty>  -> stdout = loader output
run() {
  local pack="$1" domain="$2" body="$3"
  local tmp; tmp="$(mktemp -d)"
  if [ -n "$body" ]; then
    mkdir -p "$tmp/.claude"
    printf '%s' "$body" > "$tmp/.claude/HARNESS.toml"
  fi
  CLAUDE_PROJECT_DIR="$tmp" CLAUDE_PLUGIN_ROOT="$PLUGINS/harness-$pack" \
    bash "$PLUGINS/harness-$pack/hooks/load-harness.sh" "$domain"
  local rc=$?
  rm -rf "$tmp"
  return $rc
}

# ctx <output> -> the additionalContext string (empty if output is empty)
ctx() { [ -z "$1" ] && return 0; printf '%s' "$1" | jq -r '.hookSpecificOutput.additionalContext'; }

echo "== test-load-harness =="

# 1. No HARNESS.toml -> empty output.
out="$(run web web "")"
[ -z "$out" ] && ok "no marker -> empty" || bad "no marker should be empty, got: $out"

# 2. Wrong domain table -> empty output.
out="$(run web web '[data]
subdomain = "ml-pipeline"
')"
[ -z "$out" ] && ok "wrong domain -> empty" || bad "wrong domain should be empty"

# 3. web unprefixed resolve.
out="$(run web web '[web]
subdomain = "fullstack-app"
')"
c="$(ctx "$out")"
printf '%s' "$out" | jq -e . >/dev/null 2>&1 && ok "web: valid JSON" || bad "web: invalid JSON"
case "$c" in *"web/fullstack-app"*) ok "web: header present";; *) bad "web: header missing";; esac
[ -n "$c" ] && ok "web: non-empty context" || bad "web: empty context"

# 4. data prefixed resolve.
out="$(run data data '[data]
subdomain = "ml-pipeline"
')"
c="$(ctx "$out")"
case "$c" in *"data/ml-pipeline"*) ok "data: header present";; *) bad "data: header missing";; esac
case "$c" in *"NOTE: HARNESS.toml selected subdomain"*) bad "data: unexpected warning";; *) ok "data: resolved (no warning)";; esac

# 5. analyst-notebook resolves to data-analyst-notebook.
out="$(run data data '[data]
subdomain = "analyst-notebook"
')"
c="$(ctx "$out")"
case "$c" in *"NOTE: HARNESS.toml selected subdomain"*) bad "analyst-notebook: should resolve";; *) ok "analyst-notebook: resolved";; esac

# 6. Bad subdomain -> domain skill + warning, valid JSON, exit 0.
out="$(run web web '[web]
subdomain = "does-not-exist"
')"; rc=$?
c="$(ctx "$out")"
case "$c" in *"NOTE: HARNESS.toml selected subdomain"*) ok "bad subdomain: warning present";; *) bad "bad subdomain: warning missing";; esac
printf '%s' "$out" | jq -e . >/dev/null 2>&1 && ok "bad subdomain: valid JSON" || bad "bad subdomain: invalid JSON"

# 7. Static guard: loader must fail-open when jq is absent.
grep -q 'command -v jq >/dev/null 2>&1 || exit 0' "$PLUGINS/harness-web/hooks/load-harness.sh" \
  && ok "loader has jq fail-open guard" || bad "loader missing jq fail-open guard"

echo "-- load-harness: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x plugins/tests/test-load-harness.sh`
Expected: no output, exit 0.

- [ ] **Step 3: Run the test, expect all pass**

Run: `bash plugins/tests/test-load-harness.sh; echo "exit=$?"`
Expected: every line `ok ...`, final `-- load-harness: N passed, 0 failed`, `exit=0`.

- [ ] **Step 4: Wire it into run-plugin-tests.sh**

In `plugins/tests/run-plugin-tests.sh`, after the `lint-conventions.sh` block and before the final `echo "================================"` summary, add:

```bash
echo ""
echo "### test-load-harness.sh"
bash "$HERE/test-load-harness.sh" || fails=$((fails + 1))
```

- [ ] **Step 5: Run the full plugin test suite**

Run: `./plugins/tests/run-plugin-tests.sh; echo "exit=$?"`
Expected: existing checks plus the `### test-load-harness.sh` section all pass; `ALL PLUGIN CHECKS PASSED`; `exit=0`. (If the `claude` CLI is absent locally, the validate step self-skips — that is fine.)

- [ ] **Step 6: Commit**

```bash
git add plugins/tests/test-load-harness.sh plugins/tests/run-plugin-tests.sh
git commit -m "test(harness): cover load-harness.sh resolution and fail-open"
```

---

### Task 6: Document how activation works

**Files:**
- Modify: `docs/tutorials/getting-started.md`

- [ ] **Step 1: Locate the install/quickstart section**

Run: `grep -n -iE "marketplace|plugin install|/init|assemble" docs/tutorials/getting-started.md`
Expected: line numbers for the plugin-install step and/or the assemble step. Insert the new section immediately after the plugin-install instructions.

- [ ] **Step 2: Insert the activation explanation**

Add this section (adjust the surrounding heading level to match the file):

```markdown
## How the harness activates in your repo

Installing a domain pack from the marketplace does **not** copy files into your
project's `.claude/`. Plugins load from the plugin cache — their skills, agents,
and hooks are active session-wide without being vendored into the repo. An empty
project `.claude/` is normal and expected.

To switch the pack on for a project, run its init command **once** and commit the
marker it writes:

```bash
/harness-web:init     # or harness-data:init, harness-devops:init, harness-mobile:init
```

This writes `.claude/HARNESS.toml`:

```toml
[web]
subdomain = "fullstack-app"
```

From then on, a `SessionStart` hook reads that marker at the start of **every**
session and pins the pack's shared `*-domain` rules plus your selected subdomain
skill into context automatically — no need to invoke them by hand. Other pack
skills (`using-*`, `addon-*`) remain available and load on demand when relevant.

If you would rather vendor the harness physically into the repo (so it travels
with the code and needs no plugin install), use the eject path instead:
`./templates/assemble.sh web/fullstack-app/harness.config.yml ./my-app`.
```

- [ ] **Step 3: Verify the doc renders sensibly**

Run: `grep -n "How the harness activates" docs/tutorials/getting-started.md`
Expected: one match at the inserted location.

- [ ] **Step 4: Commit**

```bash
git add docs/tutorials/getting-started.md
git commit -m "docs: explain SessionStart harness activation and the init marker"
```

---

## Self-Review

**Spec coverage:**
- Full-content injection → Task 1 (script `cat`s SKILL.md into `additionalContext`). ✓
- Per-pack, all four packs → Tasks 1–3. ✓
- Resolve-by-existence mapping → Task 1 script + Task 5 tests (web unprefixed, data prefixed, analyst-notebook). ✓
- Silent exit when no `[<domain>]` table → Task 1 `grep ... || exit 0` + Task 5 cases 1–2. ✓
- Fail-open (missing jq / failure never blocks) → Task 1 guards + Task 5 case 7. ✓
- JSON via jq with `hookSpecificOutput`/`additionalContext` → Task 1 + Task 5 JSON-validity asserts. ✓
- Fix data init.md inconsistency → Task 4. ✓
- Wiring into hooks.json without clobbering existing keys → Task 3 (sibling key + JSON validity check). ✓
- Tests wired into runner → Task 5 Step 4–5. ✓
- Documentation of activation (extend getting-started) → Task 6. ✓
- Out of scope (addons, base modules, eject path) → not implemented, as specified. ✓

**Placeholder scan:** No TBD/TODO; every code and JSON step shows complete content; commands have expected output. ✓

**Type/name consistency:** Script function/var names (`emit_files`, `warning`, `subdomain`, `skills_dir`), the header string `# Harness: this project is configured as <domain>/<subdomain>.`, and the warning prefix `NOTE: HARNESS.toml selected subdomain` are used identically in Task 1 and asserted with the same literals in Task 5. The hook argument (`web`/`data`/`devops`/`mobile`) matches the pack in Task 3. ✓

**macOS bash 3.2 safety:** empty-array expansion is guarded by `[ "${#emit_files[@]}" -gt 0 ]` before any `"${emit_files[@]}"` use, avoiding the `set -u` unbound-array error. ✓
