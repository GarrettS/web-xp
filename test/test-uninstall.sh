#!/usr/bin/env bash
# Regression tests for bin/uninstall.sh.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
TMP_INSTALL="$TMP_HOME/.web-xp"
MANIFEST_PATH="$TMP_INSTALL/web-xp-manifest.txt"

pass_count=0

pass() {
  pass_count=$((pass_count + 1))
  echo "ok - $1"
}

fail() {
  echo "not ok - $1" >&2
  exit 1
}

assert_exists() {
  local path="$1"
  [ -e "$path" ] || fail "missing path: $path"
}

assert_not_exists() {
  local path="$1"
  [ ! -e "$path" ] || fail "unexpected path: $path"
}

trap 'rm -rf "$TMP_HOME"' EXIT

mkdir -p "$TMP_INSTALL/bin" \
         "$TMP_HOME/.claude/skills/web-xp-check" \
         "$TMP_HOME/.agents/skills/web-xp-check"
cp "$REPO_ROOT/bin/uninstall.sh" "$TMP_INSTALL/bin/uninstall.sh"
printf 'skill\n' > "$TMP_HOME/.claude/skills/web-xp-check/SKILL.md"
printf 'skill\n' > "$TMP_HOME/.agents/skills/web-xp-check/SKILL.md"
cat > "$MANIFEST_PATH" <<EOF
# web-xp-manifest-v1
$TMP_HOME/.claude/skills/web-xp-check/SKILL.md
$TMP_HOME/.agents/skills/web-xp-check/SKILL.md
EOF

printf '\n' | HOME="$TMP_HOME" WEB_XP_MANIFEST_PATH="$MANIFEST_PATH" "$TMP_INSTALL/bin/uninstall.sh" > "$TMP_HOME/cancel.txt"
assert_exists "$TMP_INSTALL"
assert_exists "$TMP_HOME/.claude/skills/web-xp-check"
assert_exists "$TMP_HOME/.agents/skills/web-xp-check"
pass "cancel leaves install intact"

printf 'y\n' | HOME="$TMP_HOME" WEB_XP_MANIFEST_PATH="$MANIFEST_PATH" "$TMP_INSTALL/bin/uninstall.sh" > "$TMP_HOME/remove.txt"
assert_not_exists "$TMP_INSTALL"
assert_not_exists "$TMP_HOME/.claude/skills/web-xp-check"
assert_not_exists "$TMP_HOME/.agents/skills/web-xp-check"
pass "confirmation removes install and skills"

echo "$pass_count passed, 0 failed"
