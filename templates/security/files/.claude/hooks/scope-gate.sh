#!/usr/bin/env bash
# PreToolUse hook — matcher: Bash
# The defining security-harness gate. Before any scanning / network tool runs,
# extract the target host/IP/domain and check it against the engagement
# allowlist. Out-of-scope target => block. Exit 2 = block.
set -euo pipefail

SCOPE_FILE=".claude/engagement-scope.txt"

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -z "$cmd" ] && exit 0

# Only gate commands that reach out over the network / scan a target.
tools='nmap|masscan|nikto|sqlmap|gobuster|ffuf|dirb|wfuzz|hydra|metasploit'
tools="$tools|msfconsole|nuclei|amass|subfinder|httpx|wpscan|nc |ncat|netcat"
tools="$tools|curl|wget|ping|hping3|dig|host |nslookup|openssl s_client"
printf '%s' "$cmd" | grep -Eq "$tools" || exit 0

if [ ! -f "$SCOPE_FILE" ]; then
  echo "BLOCKED: no engagement scope file at $SCOPE_FILE." >&2
  echo "Authorized testing requires a written scope. Create it first." >&2
  exit 2
fi

# Pull candidate targets out of the command: hostnames, domains, IPv4, URLs.
targets="$(printf '%s' "$cmd" \
  | grep -Eo '(https?://)?([a-zA-Z0-9_-]+\.)+[a-zA-Z]{2,}|([0-9]{1,3}\.){3}[0-9]{1,3}|localhost' \
  | sed -E 's#^https?://##; s#/.*$##' \
  | sort -u || true)"

[ -z "$targets" ] && exit 0   # no resolvable target — let the base guards handle it.

# In-scope entries (strip comments/blanks).
allow="$(grep -Ev '^[[:space:]]*(#|$)' "$SCOPE_FILE" 2>/dev/null || true)"

bad=""
while IFS= read -r t; do
  [ -z "$t" ] && continue
  ok=0
  while IFS= read -r a; do
    [ -z "$a" ] && continue
    case "$t" in *"$a"*) ok=1; break;; esac
  done <<< "$allow"
  [ "$ok" -eq 0 ] && bad="$bad $t"
done <<< "$targets"

if [ -n "${bad// }" ]; then
  echo "BLOCKED: out-of-scope target(s) for this engagement:" >&2
  printf '  %s\n' $bad >&2
  echo "Only targets listed in $SCOPE_FILE are authorized." >&2
  echo "Testing anything else is unauthorized — do not proceed." >&2
  exit 2
fi
exit 0
