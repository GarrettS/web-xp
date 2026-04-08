#!/usr/bin/env bash
# Regression tests for bin/install.sh skill copying behavior.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL_SCRIPT="$REPO_ROOT/bin/install.sh"

pass_count=0

pass() {
  pass_count=$((pass_count + 1))
  echo "ok - $1"
}

fail() {
  echo "not ok - $1" >&2
  exit 1
}

assert_dir() {
  local path="$1"
  [ -d "$path" ] || fail "missing directory: $path"
}

assert_not_exists() {
  local path="$1"
  [ ! -e "$path" ] || fail "unexpected path: $path"
}

tmp_home="$(mktemp -d)"
trap 'rm -rf "$tmp_home"' EXIT
MANIFEST_PATH="$tmp_home/web-xp-manifest.txt"

HOME="$tmp_home" WEB_XP_MANIFEST_PATH="$MANIFEST_PATH" bash "$INSTALL_SCRIPT" > /dev/null

assert_dir "$tmp_home/.claude/skills/web-xp"
assert_dir "$tmp_home/.claude/skills/web-xp-check"
assert_dir "$tmp_home/.claude/skills/web-xp-review"
assert_dir "$tmp_home/.claude/skills/web-xp-apply"
assert_dir "$tmp_home/.claude/skills/web-xp-on"
assert_dir "$tmp_home/.claude/skills/web-xp-off"
assert_not_exists "$tmp_home/.claude/skills/web-xp-init"
assert_not_exists "$tmp_home/.claude/skills/web-xp-remove"
pass "installs all Claude skills"

assert_dir "$tmp_home/.agents/skills/web-xp"
assert_dir "$tmp_home/.agents/skills/web-xp-check"
assert_dir "$tmp_home/.agents/skills/web-xp-review"
assert_dir "$tmp_home/.agents/skills/web-xp-apply"
assert_dir "$tmp_home/.agents/skills/web-xp-on"
assert_dir "$tmp_home/.agents/skills/web-xp-off"
assert_not_exists "$tmp_home/.agents/skills/web-xp-init"
assert_not_exists "$tmp_home/.agents/skills/web-xp-remove"
pass "installs all Codex skills"

[ -f "$MANIFEST_PATH" ] || fail "missing manifest: $MANIFEST_PATH"
pass "writes install manifest"

echo "$pass_count passed, 0 failed"
