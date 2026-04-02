#!/usr/bin/env bash
# Internal maintainer regression coverage for Web XP project bootstrap.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$REPO_ROOT/bin/web-xp-init"

pass_count=0

pass() {
  pass_count=$((pass_count + 1))
  echo "ok - $1"
}

fail() {
  echo "not ok - $1" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq "$needle" "$file"; then
    fail "$file does not contain: $needle"
  fi
}

assert_first_line() {
  local file="$1"
  local expected="$2"
  local actual
  actual="$(head -n 1 "$file")"
  [ "$actual" = "$expected" ] || fail "$file first line mismatch: expected '$expected', got '$actual'"
}

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

(
  cd "$tmpdir"
  bash "$SCRIPT" > /dev/null
  [ -f CLAUDE.md ] || fail "CLAUDE.md not created"
  [ -f CODEX.md ] || fail "CODEX.md not created"
  assert_first_line CLAUDE.md '<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->'
  assert_first_line CODEX.md '<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->'
)
pass "creates both contracts by default"

(
  cd "$tmpdir"
  cat > CLAUDE.md <<'EOF'
# Local Notes

Keep this content.
EOF
  bash "$SCRIPT" claude > /dev/null
  assert_first_line CLAUDE.md '<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->'
  assert_contains CLAUDE.md '# Local Notes'
  assert_contains CLAUDE.md 'Keep this content.'
)
pass "prepends managed block to existing contract"

(
  cd "$tmpdir"
  perl -0pi -e 's/Read this file first on every task\./Read this file second on every task./' CODEX.md
  bash "$SCRIPT" codex > /dev/null 2>stderr.txt
  assert_contains stderr.txt 'warning: replacing drifted Web XP managed block in CODEX.md'
  assert_contains CODEX.md 'Read this file first on every task.'
)
pass "replaces drifted managed block and warns"

(
  preview_dir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir" "$preview_dir"' EXIT
  cd "$preview_dir"
  preview_file="$(mktemp)"
  bash "$SCRIPT" --preview codex > "$preview_file"
  [ ! -f CODEX.md ] || fail "preview should not create CODEX.md"
  assert_contains "$preview_file" '+++'
  assert_contains "$preview_file" 'Read this file first on every task.'
)
pass "preview shows proposed codex diff without writing"

echo "$pass_count passed, 0 failed"
