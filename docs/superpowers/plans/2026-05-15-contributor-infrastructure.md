# Contributor Infrastructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add CI, contribution documentation, and a deletion-governance gate so external contributors can open issues and PRs against the repo with every contribution automatically verified.

**Architecture:** `templates/tests/` is restructured into an orchestrator (`run.sh`) plus auto-discovery check scripts (`checks/`) that verify every module/addon/sub-domain found on disk — so a new unit is covered the instant its folder exists. GitHub Actions (`ci.yml`) runs that engine on every PR and merge as a `verify` job, plus a PR-only `governance` job that runs a deletion-policy check. Contribution docs and `.github/` templates make the process self-service.

**Tech Stack:** Bash (test engine, governance scripts), `jq` (JSON), `shellcheck` (hook linting), GitHub Actions YAML, GitHub issue forms, Markdown.

**Source spec:** `docs/superpowers/specs/2026-05-15-contributor-infrastructure-design.md`

---

## File Structure

**Verification engine (`templates/tests/`):**
- Create `templates/tests/lib/common.sh` — shared `ok`/`fail`/`note`/`summary` helpers
- Create `templates/tests/checks/hook-lint.sh` — `bash -n` + `shellcheck` on every `*.sh`
- Create `templates/tests/checks/structure-lint.sh` — convention checks
- Create `templates/tests/checks/assemble-coverage.sh` — auto-discovery assembly
- Rewrite `templates/tests/run.sh` — orchestrator over `checks/*.sh`
- Keep `templates/tests/fixtures/mcp-merge/.mcp.json.fragment`

**CI & governance:**
- Create `.github/workflows/ci.yml`
- Create `scripts/check-deletions.sh`
- Create `scripts/setup-branch-protection.sh`

**Contribution docs & templates:**
- Create `.github/PULL_REQUEST_TEMPLATE.md`, `.github/CODEOWNERS`
- Create `.github/ISSUE_TEMPLATE/{bug_report,propose-content,enhancement}.yml` + `config.yml`
- Create `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`
- Modify `README.md`, `.gitignore` (create if absent)

**Hygiene:**
- Modify `docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md`
- Modify `docs/superpowers/plans/2026-05-15-curated-domain-packs.md`
- Modify `templates/README.md`

All paths are relative to the repo root `/Users/cjoga/web-development/harness-engineering-templates`. Each check script resolves the repo root itself, so it runs from anywhere.

---

## Phase 1 — Verification engine

### Task 1: Shared test helpers

**Files:**
- Create: `templates/tests/lib/common.sh`

- [ ] **Step 1: Write `common.sh`**

```bash
# tests/lib/common.sh — shared helpers. Source this from a checks/*.sh script.
# Provides: ok / fail / note / summary, and $REPO (repo root) + $TPL (templates dir).
_PASS=0; _FAIL=0
ok()   { echo "  ✓ $1"; _PASS=$((_PASS + 1)); }
fail() { echo "  ✗ $1"; _FAIL=$((_FAIL + 1)); }
note() { echo "  · $1"; }
summary() {
  echo ""
  echo "  ${0##*/}: ${_PASS} passed, ${_FAIL} failed"
  [ "$_FAIL" -eq 0 ]
}
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TPL="$REPO/templates"
```

- [ ] **Step 2: Verify it sources cleanly**

Run: `bash -n templates/tests/lib/common.sh && echo "syntax OK"`
Expected: `syntax OK`.

- [ ] **Step 3: Commit**

```bash
git add templates/tests/lib/common.sh
git commit -m "test: add shared test helpers (common.sh)"
```

### Task 2: Hook lint check

**Files:**
- Create: `templates/tests/checks/hook-lint.sh`

- [ ] **Step 1: Write `hook-lint.sh`**

```bash
#!/usr/bin/env bash
# checks/hook-lint.sh — every shell script must pass `bash -n`; and `shellcheck`
# at error severity when shellcheck is installed. Both are hard gates.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"
cd "$REPO"

echo "== hook-lint: bash -n on every *.sh =="
while IFS= read -r sh; do
  if bash -n "$sh" 2>/dev/null; then ok "bash -n  $sh"; else fail "bash -n  $sh"; fi
done < <(find . -name '*.sh' -not -path './.git/*' | sort)

echo "== hook-lint: shellcheck (error severity) =="
if command -v shellcheck >/dev/null 2>&1; then
  while IFS= read -r sh; do
    if shellcheck -S error "$sh" >/dev/null 2>&1; then
      ok "shellcheck  $sh"
    else
      fail "shellcheck  $sh"
      shellcheck -S error "$sh" 2>&1 | sed 's/^/      /' || true
    fi
  done < <(find . -name '*.sh' -not -path './.git/*' | sort)
else
  note "shellcheck not installed — skipped (CI installs it)"
fi

summary
```

- [ ] **Step 2: Make executable and run against the repo**

Run: `chmod +x templates/tests/checks/hook-lint.sh && templates/tests/checks/hook-lint.sh`
Expected: every `*.sh` passes `bash -n`. For `shellcheck`: if any script fails at **error** severity, STOP and fix the genuine error in that script (the hooks are small; an error-severity shellcheck finding is a real bug). Re-run until `0 failed`. If shellcheck is not installed locally, install it (`brew install shellcheck`) so this is actually verified.

- [ ] **Step 3: Verify it catches a bad script**

Run:
```bash
printf '#!/usr/bin/env bash\nif [ -z "$x" ; then echo bad; fi\n' > /tmp/bad.sh
mkdir -p templates/tests/.tmpcheck && cp /tmp/bad.sh templates/tests/.tmpcheck/bad.sh
templates/tests/checks/hook-lint.sh; echo "exit=$?"
rm -rf templates/tests/.tmpcheck
```
Expected: a `✗ bash -n` line for the bad script and `exit=1`. (The malformed `if` has no `]`.) After removing `.tmpcheck`, re-run and confirm `0 failed`.

- [ ] **Step 4: Commit**

```bash
git add templates/tests/checks/hook-lint.sh
git commit -m "test: add hook-lint check (bash -n + shellcheck)"
```

### Task 3: Structure lint check

**Files:**
- Create: `templates/tests/checks/structure-lint.sh`

- [ ] **Step 1: Write `structure-lint.sh`**

```bash
#!/usr/bin/env bash
# checks/structure-lint.sh — convention checks across the harness templates.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"
cd "$TPL"

echo "== structure-lint: MODULE.md standard sections =="
MODULE_SECTIONS=("## Adopt if" "## Skip if" "## Dependencies"
  "## Install (manual)" "## Install (assemble.sh)" "## Remove" "## Files")
while IFS= read -r m; do
  miss=""
  grep -q '^# Module:' "$m"  || miss="$miss [# Module: title]"
  grep -q '^> Config:' "$m"  || miss="$miss [> Config: line]"
  grep -q '\*\*What it does\.\*\*' "$m" || miss="$miss [What it does]"
  for s in "${MODULE_SECTIONS[@]}"; do
    grep -qF "$s" "$m" || miss="$miss [$s]"
  done
  if [ -z "$miss" ]; then ok "MODULE.md  $m"; else fail "MODULE.md  $m —$miss"; fi
done < <(find _modules web -name 'MODULE.md' 2>/dev/null | sort)

echo "== structure-lint: agent frontmatter + least-privilege =="
while IFS= read -r a; do
  case "$a" in */README.md) continue;; esac
  miss=""
  head -1 "$a" | grep -qx -- '---' || miss="$miss [no frontmatter]"
  for k in name description tools model; do
    grep -q "^$k:" "$a" || miss="$miss [$k]"
  done
  # least-privilege: architects/auditors/reviewers/critics must be read-only
  name_line="$(grep -m1 '^name:' "$a" | sed 's/^name:[[:space:]]*//')"
  case "$name_line" in
    *-architect|*-auditor|*-reviewer|*-critic)
      tools_line="$(grep -m1 '^tools:' "$a")"
      case "$tools_line" in
        *Edit*|*Write*) miss="$miss [least-privilege: $name_line has Edit/Write]";;
      esac;;
  esac
  if [ -z "$miss" ]; then ok "agent  $a"; else fail "agent  $a —$miss"; fi
done < <(find _modules web -path '*/agents/*.md' 2>/dev/null | sort)

echo "== structure-lint: SKILL.md frontmatter =="
while IFS= read -r s; do
  miss=""
  head -1 "$s" | grep -qx -- '---' || miss="$miss [no frontmatter]"
  grep -q '^name:' "$s"        || miss="$miss [name]"
  grep -q '^description:' "$s" || miss="$miss [description]"
  if [ -z "$miss" ]; then ok "SKILL.md  $s"; else fail "SKILL.md  $s —$miss"; fi
done < <(find . -name 'SKILL.md' 2>/dev/null | sort)

echo "== structure-lint: references.md Verified header =="
while IFS= read -r r; do
  if grep -q '^> Verified:' "$r"; then ok "dossier  $r"
  else fail "dossier  $r — missing '> Verified:' header"; fi
done < <(find web -name 'references.md' 2>/dev/null | sort)

echo "== structure-lint: JSON validity =="
while IFS= read -r j; do
  if jq -e . "$j" >/dev/null 2>&1; then ok "json  $j"
  else fail "json  $j — invalid JSON"; fi
done < <(find . \( -name '*.json' -o -name '*.fragment.json' -o -name '.mcp.json.fragment' \) \
           -not -path './tests/*' 2>/dev/null | sort)

summary
```

- [ ] **Step 2: Make executable and run against the repo**

Run: `chmod +x templates/tests/checks/structure-lint.sh && templates/tests/checks/structure-lint.sh`
Expected: `0 failed`. If anything fails, it is a real convention violation in the current repo — STOP and report it (do not silence the check).

- [ ] **Step 3: Verify it catches violations**

Run (introduces three deliberate violations, then reverts):
```bash
cd templates
cp web/_addons/nextjs/MODULE.md /tmp/m.bak && sed -i.x '/## Skip if/d' web/_addons/nextjs/MODULE.md && rm -f web/_addons/nextjs/MODULE.md.x
echo '{bad json' > web/_addons/nextjs/files/.bad.json
./tests/checks/structure-lint.sh; echo "exit=$?"
cp /tmp/m.bak web/_addons/nextjs/MODULE.md && rm web/_addons/nextjs/files/.bad.json /tmp/m.bak
cd ..
```
Expected: a `✗ MODULE.md` line (missing `## Skip if`), a `✗ json` line, `exit=1`. After revert, re-run: `0 failed`.

- [ ] **Step 4: Commit**

```bash
git add templates/tests/checks/structure-lint.sh
git commit -m "test: add structure-lint check (MODULE.md, agents, skills, JSON)"
```

### Task 4: Assemble-coverage check

**Files:**
- Create: `templates/tests/checks/assemble-coverage.sh`

- [ ] **Step 1: Write `assemble-coverage.sh`**

```bash
#!/usr/bin/env bash
# checks/assemble-coverage.sh — discover every assemblable unit and assemble it.
# A new module/addon/sub-domain is covered the moment its folder exists.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"
cd "$TPL"

# assert_assembled <output-dir> <label>
assert_assembled() {
  local out="$1" label="$2"
  jq -e . "$out/.claude/settings.json" >/dev/null 2>&1 || { fail "$label — settings.json invalid"; return; }
  jq -e . "$out/.mcp.json"            >/dev/null 2>&1 || { fail "$label — .mcp.json invalid"; return; }
  if [ -f "$out/.claude/settings.fragment.json" ] || [ -f "$out/.mcp.json.fragment" ]; then
    fail "$label — leftover fragment at an auto-merge path"; return
  fi
  for h in "$out"/.claude/hooks/*.sh; do
    [ -e "$h" ] || continue
    [ -x "$h" ] || { fail "$label — hook not executable: ${h##*/}"; return; }
  done
  ok "$label"
}

echo "== coverage: thin recipes + root manifest =="
for d in generic data devops finance mobile game embedded scientific security content ops; do
  out="$(mktemp -d)"
  if ./assemble.sh "$d/harness.config.yml" "$out" >/dev/null 2>&1; then
    assert_assembled "$out" "recipe:$d"
  else fail "recipe:$d — assemble exited non-zero"; fi
  rm -rf "$out"
done
out="$(mktemp -d)"
./assemble.sh harness.config.yml "$out" >/dev/null 2>&1 && assert_assembled "$out" "root-manifest" \
  || fail "root-manifest — assemble exited non-zero"
rm -rf "$out"

echo "== coverage: web sub-domains =="
while IFS= read -r sd; do
  name="$(basename "$(dirname "$sd")")"
  out="$(mktemp -d)"
  if ./assemble.sh "$sd" "$out" >/dev/null 2>&1; then assert_assembled "$out" "subdomain:$name"
  else fail "subdomain:$name — assemble exited non-zero"; fi
  rm -rf "$out"
done < <(find web -mindepth 2 -maxdepth 2 -name 'harness.config.yml' | sort)

echo "== coverage: cross-cutting modules =="
# probe: copy the root manifest, flip the one key that selects this module.
probe_for_module() {            # probe_for_module <category> <option> <tmpfile>
  local cat="$1" opt="$2" f="$3"
  cp harness.config.yml "$f"
  case "$cat" in
    memory)          sed -i.x "s/^  backend: .*/  backend: $opt/" "$f" ;;  # first 'backend:' is memory
    progress-tracking)
      # second 'backend:' is progress — rewrite via awk
      awk -v o="$opt" 'BEGIN{n=0} /^  backend:/{n++; if(n==2){print "  backend: " o; next}} {print}' "$f" > "$f.a" && mv "$f.a" "$f" ;;
    methodology)
      key="$opt"; [ "$opt" = "spec-driven" ] && key="spec_driven"
      [ "$opt" = "eval-driven" ] && key="eval_driven"
      sed -i.x "s/^  $key: .*/  $key: true/" "$f" ;;
    orchestration)   sed -i.x "s/^  topology: .*/  topology: $opt/" "$f" ;;
    safety)
      key="$opt"; [ "$opt" = "two-key" ] && key="two_key"
      [ "$opt" = "kill-switch" ] && key="kill_switch"
      sed -i.x "s/^  $key: .*/  $key: true/" "$f" ;;
  esac
  rm -f "$f.x"
}
while IFS= read -r moddir; do
  opt="$(basename "$moddir")"; cat="$(basename "$(dirname "$moddir")")"
  [ "$cat" = "memory" ] && [ "$opt" = "md-files" ] && { :; }   # md-files is the default; still probe
  f="$(mktemp)"; probe_for_module "$cat" "$opt" "$f"
  out="$(mktemp -d)"
  if ./assemble.sh "$f" "$out" >/dev/null 2>&1; then assert_assembled "$out" "module:$cat/$opt"
  else fail "module:$cat/$opt — assemble exited non-zero"; fi
  rm -rf "$out" "$f"
done < <(find _modules -mindepth 2 -maxdepth 2 -type d | sort)

echo "== coverage: web addons =="
# probe: a real web sub-domain config with domain.addons set to just this addon.
# The probe must live inside a sub-domain dir so assemble.sh detects the pack.
PROBE_HOST="web/frontend-app"
while IFS= read -r addondir; do
  addon="$(basename "$addondir")"
  f="$PROBE_HOST/.probe-${addon}.harness.config.yml"
  sed "s/^\(  addons:\).*/\1 [$addon]/" "$PROBE_HOST/harness.config.yml" > "$f"
  out="$(mktemp -d)"
  if ./assemble.sh "$f" "$out" >/dev/null 2>&1 \
     && ! ./assemble.sh "$f" "$out" 2>&1 >/dev/null | grep -q "addon not found"; then
    assert_assembled "$out" "addon:$addon"
  else
    fail "addon:$addon — assemble failed or addon not found"
  fi
  rm -rf "$out" "$f"
done < <(find web/_addons -mindepth 1 -maxdepth 1 -type d | sort)

echo "== coverage: .mcp.json deep-merge fixture =="
out="$(mktemp -d)"
./assemble.sh generic/harness.config.yml "$out" >/dev/null 2>&1
cp tests/fixtures/mcp-merge/.mcp.json.fragment "$out/.mcp.json.fragment"
merged="$(jq -s '
  def dm($a;$b): reduce ($b|keys_unsorted[]) as $k ($a;
    if (($a[$k]|type)=="object") and (($b[$k]|type)=="object") then .[$k]=dm($a[$k];$b[$k])
    elif (($a[$k]|type)=="array") and (($b[$k]|type)=="array") then .[$k]=($a[$k]+$b[$k])
    else .[$k]=$b[$k] end); dm(.[0];.[1])' "$out/.mcp.json" "$out/.mcp.json.fragment")"
echo "$merged" | jq -e '.mcpServers.context7' >/dev/null 2>&1 \
  && ok "mcp deep-merge keeps server" || fail "mcp deep-merge lost server"
rm -rf "$out"

summary
```

- [ ] **Step 2: Make executable and run against the repo**

Run: `chmod +x templates/tests/checks/assemble-coverage.sh && templates/tests/checks/assemble-coverage.sh`
Expected: every recipe, sub-domain, module, and addon assembles — `0 failed`. If a module probe fails because the probe's `sed`/`awk` did not flip the right key, fix `probe_for_module` until each module assembles. (The `memory` first-`backend:` / `progress` second-`backend:` ordering depends on `harness.config.yml` block order — verify against the actual file.)

- [ ] **Step 3: Verify a new unit is auto-covered**

Run:
```bash
cd templates
cp -r _modules/methodology/bdd _modules/methodology/zzprobe
./tests/checks/assemble-coverage.sh | grep -E 'module:methodology/zzprobe'
rm -rf _modules/methodology/zzprobe
cd ..
```
Expected: a line `✓ module:methodology/zzprobe` — proof a brand-new module folder is covered with no test edit. (The probe sets `methodology.zzprobe: true`; assemble.sh installs `methodology/zzprobe`. After removal, re-run the full check: `0 failed`.)

- [ ] **Step 4: Commit**

```bash
git add templates/tests/checks/assemble-coverage.sh
git commit -m "test: add assemble-coverage check (auto-discovery)"
```

### Task 5: Orchestrator + .gitignore

**Files:**
- Modify: `templates/tests/run.sh` (full rewrite)
- Create: `.gitignore` (repo root, if absent — otherwise append)

- [ ] **Step 1: Rewrite `templates/tests/run.sh` as the orchestrator**

```bash
#!/usr/bin/env bash
# tests/run.sh — runs every check in checks/ and prints one summary.
# Invoke from anywhere: ./templates/tests/run.sh
set -uo pipefail
CHECKS_DIR="$(cd "$(dirname "$0")/checks" && pwd)"
fails=0
for chk in "$CHECKS_DIR"/*.sh; do
  echo ""
  echo "### ${chk##*/}"
  bash "$chk" || fails=$((fails + 1))
done
echo ""
echo "================================"
if [ "$fails" -eq 0 ]; then
  echo "ALL CHECKS PASSED"
else
  echo "$fails CHECK(S) FAILED"
fi
exit "$fails"
```

- [ ] **Step 2: Create/append `.gitignore`**

If `.gitignore` does not exist at the repo root, create it with:

```
# transient probe configs written by tests/checks/assemble-coverage.sh
.probe-*.harness.config.yml
templates/web/*/.probe-*.harness.config.yml
```

If `.gitignore` already exists, append those three lines.

- [ ] **Step 3: Run the full suite**

Run: `chmod +x templates/tests/run.sh && ./templates/tests/run.sh; echo "exit=$?"`
Expected: each of `assemble-coverage.sh`, `hook-lint.sh`, `structure-lint.sh` runs and reports `0 failed`; final line `ALL CHECKS PASSED`; `exit=0`.

- [ ] **Step 4: Commit**

```bash
git add templates/tests/run.sh .gitignore
git commit -m "test: make run.sh an orchestrator over checks/"
```

---

## Phase 2 — CI workflows & governance

### Task 6: Deletion-policy check script

**Files:**
- Create: `scripts/check-deletions.sh`

- [ ] **Step 1: Write `scripts/check-deletions.sh`**

```bash
#!/usr/bin/env bash
# scripts/check-deletions.sh — fail a PR that deletes files without justification.
# Renames (git R) are allowed silently. A pure deletion (git D) must either be
# named in the PR body, or the PR must carry the `override-deletion` label.
#
# Env: PR_BODY (PR description), PR_LABELS (newline- or comma-separated label
#      names), BASE_REF (default: origin/main).
set -uo pipefail
BASE_REF="${BASE_REF:-origin/main}"
PR_BODY="${PR_BODY:-}"
PR_LABELS="${PR_LABELS:-}"

deleted="$(git diff --diff-filter=D --name-only "${BASE_REF}...HEAD")"
if [ -z "$deleted" ]; then
  echo "✓ No files deleted in this PR."
  exit 0
fi

if printf '%s' "$PR_LABELS" | tr ',' '\n' | grep -qx 'override-deletion'; then
  echo "✓ 'override-deletion' label present — owner override applied."
  echo "  Deleted files (justification waived):"
  printf '%s\n' "$deleted" | sed 's/^/    /'
  exit 0
fi

missing=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if printf '%s' "$PR_BODY" | grep -qF "$f"; then
    echo "  ✓ justified: $f"
  else
    echo "  ✗ unjustified: $f"
    missing="$missing $f"
  fi
done <<EOF
$deleted
EOF

if [ -n "$missing" ]; then
  echo ""
  echo "This PR deletes files without justification:"
  for f in $missing; do echo "  - $f"; done
  echo ""
  echo "Fix it one of these ways:"
  echo "  1. If you RENAMED the file, ensure git records it as a rename"
  echo "     (keep the change in one commit) — renames are allowed automatically."
  echo "  2. Otherwise, fill the '## Deletions' section of the PR description:"
  echo "     list each deleted path with a reason and its replacement."
  echo "  3. A maintainer may add the 'override-deletion' label to waive this."
  exit 1
fi

echo "✓ All deletions are justified in the PR description."
exit 0
```

- [ ] **Step 2: Make executable and verify the three paths**

Run:
```bash
chmod +x scripts/check-deletions.sh
bash -n scripts/check-deletions.sh && echo "syntax OK"
# no deletions:
BASE_REF=HEAD scripts/check-deletions.sh; echo "exit=$? (expect 0)"
```
Expected: `syntax OK`; "No files deleted"; `exit=0`. (Full diff-based behavior is exercised in CI; this confirms the no-deletion and syntax paths.)

- [ ] **Step 3: Verify the label and justification logic**

Run:
```bash
# simulate: pretend a file is deleted by feeding a fake list through the body/label logic
PR_LABELS="bug,override-deletion" bash -c '
  printf "%s" "bug,override-deletion" | tr "," "\n" | grep -qx "override-deletion" \
    && echo "label-match OK"'
```
Expected: `label-match OK` — confirms the label parser matches a comma-separated list.

- [ ] **Step 4: Commit**

```bash
git add scripts/check-deletions.sh
git commit -m "feat: add deletion-policy check script"
```

### Task 7: CI workflow

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Write `.github/workflows/ci.yml`**

```yaml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  verify:
    name: Verify (tests)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install tools
        run: sudo apt-get update && sudo apt-get install -y jq shellcheck
      - name: Run the harness test suite
        run: ./templates/tests/run.sh

  governance:
    name: Governance (deletion policy)
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Check deletions
        env:
          PR_BODY: ${{ github.event.pull_request.body }}
          PR_LABELS: ${{ join(github.event.pull_request.labels.*.name, ',') }}
          BASE_REF: origin/${{ github.event.pull_request.base.ref }}
        run: |
          git fetch origin "${{ github.event.pull_request.base.ref }}"
          ./scripts/check-deletions.sh
```

- [ ] **Step 2: Validate the workflow YAML**

Run: `jq -e . < /dev/null >/dev/null; python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml')); print('YAML OK')"`
Expected: `YAML OK`. If `actionlint` is installed, also run `actionlint .github/workflows/ci.yml` and expect no errors.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add verify + governance workflow"
```

### Task 8: Branch-protection setup script

**Files:**
- Create: `scripts/setup-branch-protection.sh`

- [ ] **Step 1: Write `scripts/setup-branch-protection.sh`**

```bash
#!/usr/bin/env bash
# scripts/setup-branch-protection.sh — apply branch protection to main.
# Run once by the repo owner: `gh auth login` first, then `./scripts/setup-branch-protection.sh`.
# Requires the GitHub CLI (`gh`) with admin rights on the repo.
set -euo pipefail

REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
echo "Applying branch protection to main on ${REPO}…"

gh api -X PUT "repos/${REPO}/branches/main/protection" \
  --input - <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Verify (tests)", "Governance (deletion policy)"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "require_code_owner_reviews": true
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON

echo "Done. main now requires: PR + the Verify and Governance checks + 1 CODEOWNERS review."
echo "enforce_admins is false — you (owner) keep an emergency admin-merge path;"
echo "the documented override for the deletion gate is the 'override-deletion' label."
```

- [ ] **Step 2: Verify syntax**

Run: `chmod +x scripts/setup-branch-protection.sh && bash -n scripts/setup-branch-protection.sh && echo "syntax OK"`
Expected: `syntax OK`. (Do NOT run the script — it mutates live repo settings; the owner runs it deliberately.)

- [ ] **Step 3: Commit**

```bash
git add scripts/setup-branch-protection.sh
git commit -m "ci: add branch-protection setup script"
```

---

## Phase 3 — Contribution docs & templates

### Task 9: PR template + CODEOWNERS

**Files:**
- Create: `.github/PULL_REQUEST_TEMPLATE.md`
- Create: `.github/CODEOWNERS`

- [ ] **Step 1: Write `.github/PULL_REQUEST_TEMPLATE.md`**

```markdown
## Summary

<!-- What does this PR change, and why? -->

## Type of change

- [ ] New module (`templates/_modules/<category>/<option>/`)
- [ ] New addon (`templates/web/_addons/<addon>/`)
- [ ] New sub-domain (`templates/web/<sub-domain>/`)
- [ ] New domain
- [ ] Core enhancement (`_base/`, `assemble.sh`, config schema, test engine)
- [ ] Bug fix
- [ ] Documentation

## Checklist

- [ ] I ran `./templates/tests/run.sh` locally and it printed `ALL CHECKS PASSED`.
- [ ] New `MODULE.md` files follow the standard sections (see `CONTRIBUTING.md`).
- [ ] New agents are least-privilege (architects/auditors/reviewers are read-only).
- [ ] New dossiers (`references.md`) carry a `> Verified: YYYY-MM` header.

## Deletions

<!--
Renaming a file is fine — no entry needed (git records it as a rename).
For each file this PR DELETES, add a line:
  `path/to/file` — reason — replaced by `path/to/new` (or "no replacement: why")
If this PR deletes nothing, leave the word None below.
-->

None.
```

- [ ] **Step 2: Write `.github/CODEOWNERS`**

```
# Every change requests a review from the repo owner.
* @Camilool8
```

- [ ] **Step 3: Verify**

Run: `test -f .github/PULL_REQUEST_TEMPLATE.md && test -f .github/CODEOWNERS && echo "files present"`
Expected: `files present`.

- [ ] **Step 4: Commit**

```bash
git add .github/PULL_REQUEST_TEMPLATE.md .github/CODEOWNERS
git commit -m "docs: add PR template and CODEOWNERS"
```

### Task 10: Issue templates

**Files:**
- Create: `.github/ISSUE_TEMPLATE/bug_report.yml`
- Create: `.github/ISSUE_TEMPLATE/propose-content.yml`
- Create: `.github/ISSUE_TEMPLATE/enhancement.yml`
- Create: `.github/ISSUE_TEMPLATE/config.yml`

- [ ] **Step 1: Write `bug_report.yml`**

```yaml
name: Bug report
description: Something in the templates or the harness is broken or wrong.
labels: ["bug"]
body:
  - type: input
    id: unit
    attributes:
      label: Affected unit
      description: Which module / addon / sub-domain / recipe, or "assemble.sh / core".
      placeholder: templates/web/_addons/drizzle
    validations:
      required: true
  - type: textarea
    id: expected
    attributes:
      label: Expected vs actual
      description: What did you expect, and what happened instead?
    validations:
      required: true
  - type: textarea
    id: repro
    attributes:
      label: Steps to reproduce
      description: Include the exact `assemble.sh` command or test command you ran.
    validations:
      required: true
```

- [ ] **Step 2: Write `propose-content.yml`**

```yaml
name: Propose new content
description: Propose a new module, addon, sub-domain, or domain.
labels: ["proposal"]
body:
  - type: dropdown
    id: kind
    attributes:
      label: Kind of content
      options:
        - Module (cross-cutting — memory, progress, methodology, orchestration, safety)
        - Addon (domain-scoped extra)
        - Sub-domain (a deliverable shape within a domain)
        - Domain (a whole new domain pack)
    validations:
      required: true
  - type: textarea
    id: what
    attributes:
      label: What it does
      description: One or two sentences — the capability this adds.
    validations:
      required: true
  - type: textarea
    id: adopt-skip
    attributes:
      label: Adopt if / Skip if
      description: When should a harness pick this up, and when should it not?
    validations:
      required: true
  - type: textarea
    id: prior-art
    attributes:
      label: Prior art / references
      description: Links to the tools, docs, or practice this is grounded in.
    validations:
      required: false
```

- [ ] **Step 3: Write `enhancement.yml`**

```yaml
name: Enhancement
description: Improve the core, the test engine, or an existing module/addon/sub-domain.
labels: ["enhancement"]
body:
  - type: input
    id: target
    attributes:
      label: What should change
      description: The file or unit you want improved.
    validations:
      required: true
  - type: textarea
    id: motivation
    attributes:
      label: Motivation
      description: What problem does this solve? Why now?
    validations:
      required: true
  - type: textarea
    id: proposal
    attributes:
      label: Proposed change
    validations:
      required: true
```

- [ ] **Step 4: Write `config.yml`**

```yaml
blank_issues_enabled: false
contact_links:
  - name: Contribution guide
    url: https://github.com/Camilool8/harness-engineering-templates/blob/main/CONTRIBUTING.md
    about: How to add a module, addon, or sub-domain, and how the PR process works.
```

- [ ] **Step 5: Validate all four YAML files**

Run:
```bash
python3 -c "import yaml; [yaml.safe_load(open('.github/ISSUE_TEMPLATE/'+f)) for f in ['bug_report.yml','propose-content.yml','enhancement.yml','config.yml']]; print('YAML OK')"
```
Expected: `YAML OK`.

- [ ] **Step 6: Commit**

```bash
git add .github/ISSUE_TEMPLATE/
git commit -m "docs: add issue templates (bug, proposal, enhancement)"
```

### Task 11: CONTRIBUTING.md

**Files:**
- Create: `CONTRIBUTING.md`

- [ ] **Step 1: Write `CONTRIBUTING.md`**

Write the file with these sections, in order, with complete prose (not an outline):

1. **Intro** — one paragraph: what the repo is, and that contributions of modules / addons / sub-domains / domains are welcome.
2. **How it fits together** — the base / `_modules/` / domain-pack / `_addons/` model in ~6 lines, linking to `docs/HARNESS_ENGINEERING.md`, `docs/METHODOLOGIES.md`, `docs/AGENT_ROLES.md`, and `templates/README.md`.
3. **Before you start** — open an issue first using the *Propose new content* template; wait for a maintainer 👍 before a large PR.
4. **Adding a module** — exact steps: create `templates/_modules/<category>/<option>/` with `MODULE.md` (list the standard sections: `# Module:` title, `> Config:` line, **What it does**, Adopt if, Skip if, Dependencies, Install (manual), Install (assemble.sh), Remove, Files), `claude-md.md` (a `## Heading` section), and a `files/` tree copied verbatim into a project. Point at an existing module (`templates/_modules/methodology/tdd/`) as the worked example.
5. **Adding an addon** — `templates/web/_addons/<addon>/`, same shape; reference `templates/web/_addons/nextjs/`.
6. **Adding a sub-domain** — `templates/web/<sub-domain>/` with `SUBDOMAIN.md`, `harness.config.yml`, `references.md` (must carry a `> Verified: YYYY-MM` header), `claude-md.md`, and `files/.claude/{agents,skills,hooks}/`. Note the agent rule: architects/auditors/reviewers are read-only; only implementers/testers get `Edit`/`Write`. Reference `templates/web/frontend-app/`.
7. **Enhancing the core** — `_base/`, `assemble.sh`, the config schema, or `templates/tests/`. Note these get extra review scrutiny; keep changes backward-compatible with existing recipes.
8. **Running the checks locally** — `./templates/tests/run.sh` runs everything; individual checks live in `templates/tests/checks/` and run standalone. Requires `jq` and (recommended) `shellcheck`.
9. **The deletion policy** — renaming a file is always fine. Deleting a file requires either a replacement or a documented reason in the PR's `## Deletions` section; CI's `governance` check enforces this. A maintainer can apply the `override-deletion` label to waive it — but the `verify` (tests) check always still has to pass.
10. **PR lifecycle** — fork/branch → fill the PR template → CI runs `verify` + `governance` → a CODEOWNERS review → squash-merge. Both checks must be green (or `governance` waived by label).
11. **Code of Conduct** — one line linking `CODE_OF_CONDUCT.md`.

- [ ] **Step 2: Verify cross-references resolve**

Run:
```bash
for p in docs/HARNESS_ENGINEERING.md docs/METHODOLOGIES.md docs/AGENT_ROLES.md \
         templates/README.md CODE_OF_CONDUCT.md templates/_modules/methodology/tdd \
         templates/web/_addons/nextjs templates/web/frontend-app; do
  test -e "$p" || echo "BROKEN REF: $p"
done
echo "ref check done"
```
Expected: `ref check done` with no `BROKEN REF` lines. (`CODE_OF_CONDUCT.md` is created in Task 12 — if this runs before Task 12, that one line is expected; otherwise all resolve.)

- [ ] **Step 3: Commit**

```bash
git add CONTRIBUTING.md
git commit -m "docs: add CONTRIBUTING guide"
```

### Task 12: Code of Conduct, Security policy, README update

**Files:**
- Create: `CODE_OF_CONDUCT.md`
- Create: `SECURITY.md`
- Modify: `README.md`

- [ ] **Step 1: Write `CODE_OF_CONDUCT.md`**

Use the standard **Contributor Covenant v2.1** text. Set the enforcement contact to: "Report conduct concerns by opening a private security advisory or contacting the repo owner (@Camilool8)." Keep the standard sections (Our Pledge, Our Standards, Enforcement Responsibilities, Scope, Enforcement, Enforcement Guidelines, Attribution).

- [ ] **Step 2: Write `SECURITY.md`**

```markdown
# Security Policy

## Reporting a vulnerability

This repository ships shell hooks and harness configuration that other projects
copy into their own tooling. If you find a security issue — an unsafe hook, a
command-injection vector in `assemble.sh`, a template that leaks secrets — please
report it privately:

- Open a [private security advisory](https://github.com/Camilool8/harness-engineering-templates/security/advisories/new), or
- Contact the repo owner (@Camilool8) directly.

Please do **not** open a public issue for a security vulnerability.

## Scope

In scope: `assemble.sh`, all hook scripts under `templates/**/hooks/`, the test
engine, and any template that could cause a consuming project to execute unsafe
code or expose credentials.

Out of scope: third-party MCP servers or tools that templates merely reference.

## Response

We aim to acknowledge a report within 7 days and to ship a fix or mitigation
before any public disclosure.
```

- [ ] **Step 3: Update `README.md`**

Add a CI badge directly under the repo title (line 1):

```markdown
![CI](https://github.com/Camilool8/harness-engineering-templates/actions/workflows/ci.yml/badge.svg)
```

Add a `## Contributing` section near the end of `README.md` (before any final references section):

```markdown
## Contributing

Contributions — new modules, addons, sub-domains, or whole domains — are welcome.
Start with the [Propose new content](https://github.com/Camilool8/harness-engineering-templates/issues/new/choose)
issue template, then read **[CONTRIBUTING.md](CONTRIBUTING.md)** for the step-by-step
guide and **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)**.

Every PR is automatically verified: `./templates/tests/run.sh` runs in CI and
must pass before merge.
```

- [ ] **Step 4: Verify**

Run: `test -f CODE_OF_CONDUCT.md && test -f SECURITY.md && grep -q 'Contributing' README.md && grep -q 'badge.svg' README.md && echo OK`
Expected: `OK`.

- [ ] **Step 5: Commit**

```bash
git add CODE_OF_CONDUCT.md SECURITY.md README.md
git commit -m "docs: add Code of Conduct, Security policy, README contributing section"
```

---

## Phase 4 — Repo hygiene

### Task 13: Hygiene fixes

**Files:**
- Modify: `docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md`
- Modify: `docs/superpowers/plans/2026-05-15-curated-domain-packs.md`
- Modify: `templates/README.md`

- [ ] **Step 1: Mark the curated-domain-packs spec as completed**

In `docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md`, change the first `> Status:` line to:

```markdown
> Status: ✓ Completed 2026-05-15 — implemented and merged. This document is a
> historical design record; the `- [ ]` checkboxes below were the design's
> task list and are all done.
```

- [ ] **Step 2: Mark the curated-domain-packs plan as completed**

In `docs/superpowers/plans/2026-05-15-curated-domain-packs.md`, insert a line
immediately below the `# Curated Domain Packs Implementation Plan` title:

```markdown
> **✓ Completed 2026-05-15.** All 18 tasks were implemented, reviewed, and
> merged. This file is kept as a historical record — the `- [ ]` checkboxes are
> not open work.
```

- [ ] **Step 3: Clarify the domain-pack scope note in `templates/README.md`**

Find the "Domain packs" section. After the directory-layout block, ensure this
sentence is present (add it if missing, or replace any ambiguous equivalent):

```markdown
> **Scope:** only the `web/` domain currently uses this three-layer structure
> (`DOMAIN.md`, sub-domains, `_addons/`). The other 11 domains are v1 thin
> recipes — a single `harness.config.yml` + `files/` — pending curation.
```

- [ ] **Step 4: Verify the test suite still passes**

Run: `./templates/tests/run.sh; echo "exit=$?"`
Expected: `ALL CHECKS PASSED`, `exit=0` (these are doc-only edits — `structure-lint` does not gate `docs/`, and `templates/README.md` is not a checked artifact).

- [ ] **Step 5: Commit**

```bash
git add docs/superpowers/ templates/README.md
git commit -m "docs: mark curated-domain-packs spec/plan completed; clarify pack scope"
```

---

## Self-Review

- **Spec coverage:** §3.1 `common.sh` → Task 1. §3.3 hook-lint → Task 2. §3.2 structure-lint → Task 3. §3.1 assemble-coverage → Task 4. §3.4 orchestrator → Task 5. §4.2 check-deletions → Task 6. §4.1 `ci.yml` → Task 7. §4.3 setup-branch-protection → Task 8. §5.1 PR template + CODEOWNERS → Task 9; issue forms → Task 10. §5.2 CONTRIBUTING → Task 11; CoC + SECURITY + README → Task 12. §6 hygiene → Task 13. All spec sections map to tasks.
- **Placeholder scan:** all scripts and YAML are given in full. CONTRIBUTING.md (Task 11) and CODE_OF_CONDUCT.md (Task 12) are specified as a complete, ordered section list with the content of each section stated — a content contract, not a "TODO"; both are prose documents whose exact wording is the implementer's to render from the stated content. No "TBD" / "handle edge cases" / bare "write tests" steps.
- **Type/name consistency:** `ok`/`fail`/`note`/`summary` + `$REPO`/`$TPL` from Task 1 are used consistently in Tasks 2–4. Check filenames (`hook-lint.sh`, `structure-lint.sh`, `assemble-coverage.sh`) are consistent between Task 5's orchestrator and their defining tasks. Job names `Verify (tests)` / `Governance (deletion policy)` in `ci.yml` (Task 7) match the `required_status_checks.contexts` in `setup-branch-protection.sh` (Task 8). The `override-deletion` label and `## Deletions` section name are consistent across Tasks 6, 9, 11. `check-deletions.sh` env vars (`PR_BODY`/`PR_LABELS`/`BASE_REF`) match what `ci.yml` sets.
- **Known caveat:** Task 4's `probe_for_module` depends on the block order of `templates/harness.config.yml` (memory's `backend:` before progress's). Task 4 Step 2 instructs verifying this against the actual file and fixing the probe if needed — called out, not silent.
```
