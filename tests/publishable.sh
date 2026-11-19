#!/usr/bin/env bash
# Lists where tracked files match generic secret and identifier patterns.
# Prints path:line and the pattern's name only, never the matched text, so a
# hit is safe to show; each hit is then judged by hand against the publication
# rule in openspec/config.yaml. Holds no denylist: a pattern naming the secret
# would itself be a leak. Exits 1 if anything matched.
set -u
cd "$(dirname "$0")/.." || exit 2

hits=0
scan() {
  local name=$1 pattern=$2 out status
  # The matched lines stay in the variable; only path:line reaches the terminal.
  out=$(git grep -nIP -e "$pattern" -- . ':!config/nvim/lazy-lock.json' ':!tests/publishable.sh')
  status=$?
  # git grep exits 1 for no match; anything above that is an error, which must
  # not read as a clean result.
  [ "$status" -le 1 ] || { echo "git grep failed for $name" >&2; exit 2; }
  out=$(cut -d: -f1,2 <<<"$out")
  if [ -n "$out" ]; then
    while IFS= read -r loc; do echo "$loc: $name"; done <<<"$out"
    hits=$((hits + $(wc -l <<<"$out")))
  fi
}

scan private-key     '-----BEGIN [A-Z ]*PRIVATE KEY'
scan token-prefix    '\b(ghp_|gho_|github_pat_|sk-ant-|sk-[A-Za-z0-9]{20}|xox[abp]-|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{30})'
scan secret-assign   '(?i)\b(password|passwd|secret|token|api[_-]?key|psk)\b\s*[:=]\s*["'"'"'][^"'"'"']{6,}'
scan password-hash   '(?i)(hashedPassword|initialPassword|\$6\$|\$y\$)'
scan email           '[A-Za-z0-9._%+-]+@(?!github\.com\b|users\.noreply\.github\.com\b|anthropic\.com\b)[A-Za-z0-9.-]+\.[a-z]{2,}'
scan ipv4            '(?<![\w.-])(?!127\.|0\.0\.0\.0)(?:\d{1,3}\.){3}\d{1,3}(?![\w.])'
scan mac             '\b(?:[0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}\b'

[ "$hits" -eq 0 ] && echo "no matches" || { echo "$hits match(es): judge each by hand"; exit 1; }
