#!/usr/bin/env bash
# Checks the jail's --reveal/--reveal-rw flags against a throwaway fixture.
# Usage: tests/reveal.sh <path to a built jailed-shell>
set -u

jail=${1:?usage: $0 <jailed-shell>}
here=$(cd "$(dirname "$0")" && pwd -P)
# Fixed name: bwrap leaves each bind's parents in the state directory, so a
# random name would add another empty tree there on every run.
fx=$here/reveal-fixture
rm -rf "$fx"
trap 'rm -rf "$fx"' EXIT

proj=$fx/proj ro=$fx/ro rw=$fx/rw nest=$fx/nest unrev=$fx/unrevealed
mkdir -p "$proj/sub" "$ro" "$rw" "$nest/in" "$unrev" "$fx/.hidden"
touch "$ro/file"
ln -s "$fx/.hidden" "$fx/link"

failures=0
check() {
  if "${@:2}"; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi
}
jailed() { (cd "$proj" && "$jail" "$@"); }
# Refused: no session starts, and the message names the path.
refused() {
  ! out=$(jailed "$@" -c 'echo STARTED' 2>&1) &&
    [[ $out != *STARTED* && $out == *"refusing to reveal $2:"* ]]
}

check "read-only reveal reads, refuses writes" \
  jailed --reveal "$ro" -c "test -f '$ro/file' && ! touch '$ro/new' 2>/dev/null"
check "writable reveal writes through to the host" \
  bash -c "cd '$proj' && '$jail' --reveal-rw '$rw' -c \"touch '$rw/new'\" && test -f '$rw/new'"
check "revealed parent leaves the project writable" \
  jailed --reveal "$fx" -c "touch '$proj/new' && ! touch '$ro/other' 2>/dev/null"
check "inner nested reveal wins (outer flag first)" \
  jailed --reveal "$nest" --reveal-rw "$nest/in" -c "touch '$nest/in/a' && ! touch '$nest/b' 2>/dev/null"
check "inner nested reveal wins (inner flag first)" \
  jailed --reveal-rw "$nest/in" --reveal "$nest" -c "touch '$nest/in/c' && ! touch '$nest/d' 2>/dev/null"
check "the descriptor used for the bind is closed inside the session" \
  jailed --reveal "$ro" -c 'for f in /proc/$$/fd/*; do [ ! "$f" -ef "$1" ] || exit 1; done' name "$ro"
check "unrevealed sibling is absent" \
  jailed --reveal "$ro" -c "! test -e '$unrev'"
check "arguments after the flags reach the agent" \
  test "$(jailed --reveal "$ro" -c 'printf %s "$1"' name 'a b')" = "a b"

check "home directory refused"      refused --reveal "$HOME"
check "path outside home refused"   refused --reveal /tmp
check "missing path refused"        refused --reveal "$fx/missing"
check "file refused"                refused --reveal "$ro/file"
check "hidden directory refused"    refused --reveal "$fx/.hidden"
check "symlink to hidden refused"   refused --reveal "$fx/link"
check "launch directory refused"    refused --reveal "$proj"
check "path inside project refused" refused --reveal "$proj/sub"
# Nothing may follow the flag here, so this one cannot go through refused().
check "flag without a path refused" \
  bash -c "! out=\$(cd '$proj' && '$jail' --reveal 2>&1 </dev/null) && [[ \$out == *'refusing to reveal (nothing):'* ]]"

[ "$failures" -eq 0 ] && echo "all passed" || { echo "$failures failed"; exit 1; }
