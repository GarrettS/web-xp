#!/usr/bin/env bats

load 'test_helper'

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  TMP_HOME="$(mktemp -d)"
  TMP_INSTALL="$TMP_HOME/.web-xp"
  MANIFEST_PATH="$TMP_INSTALL/web-xp-manifest.txt"

  mkdir -p "$TMP_INSTALL/bin" \
           "$TMP_HOME/.claude/skills/web-xp-check" \
           "$TMP_HOME/.agents/skills/web-xp-check"

  cp "$REPO_ROOT/bin/uninstall.sh" "$TMP_INSTALL/bin/uninstall.sh"
  echo "skill" > "$TMP_HOME/.claude/skills/web-xp-check/SKILL.md"
  echo "skill" > "$TMP_HOME/.agents/skills/web-xp-check/SKILL.md"
}

teardown() {
  rm -rf "$TMP_HOME"
}

@test "uninstall cancels by default" {
  cat > "$MANIFEST_PATH" <<EOF
# web-xp-manifest-v1
$TMP_HOME/.claude/skills/web-xp-check/SKILL.md
$TMP_HOME/.agents/skills/web-xp-check/SKILL.md
EOF

  run bash -lc "printf '\n' | HOME=\"$TMP_HOME\" WEB_XP_MANIFEST_PATH=\"$MANIFEST_PATH\" \"$TMP_INSTALL/bin/uninstall.sh\""
  [ "$status" -eq 0 ]
  assert_output_matches "Uninstall cancelled\\."
  assert_output_matches "$TMP_INSTALL/web-xp-manifest\\.txt"
  assert_output_matches "$TMP_HOME/\\.claude/skills/web-xp-check/SKILL\\.md"
  assert_output_matches "$TMP_HOME/\\.agents/skills/web-xp-check/SKILL\\.md"
  assert_output_not_matches "$TMP_HOME/\\.claude/skills/web-xp\\*"
  [ -d "$TMP_INSTALL" ]
  assert_dir_exists "$TMP_HOME/.claude/skills/web-xp-check"
  assert_dir_exists "$TMP_HOME/.agents/skills/web-xp-check"
}

@test "uninstall removes manifest-recorded files and install root after confirmation" {
  cat > "$MANIFEST_PATH" <<EOF
# web-xp-manifest-v1
$TMP_HOME/.claude/skills/web-xp-check/SKILL.md
$TMP_HOME/.agents/skills/web-xp-check/SKILL.md
EOF

  run bash -lc "printf 'y\n' | HOME=\"$TMP_HOME\" WEB_XP_MANIFEST_PATH=\"$MANIFEST_PATH\" \"$TMP_INSTALL/bin/uninstall.sh\""
  [ "$status" -eq 0 ]
  assert_output_matches "Web XP was removed from this machine\\."
  assert_output_matches "Project agent files \\(CLAUDE\\.md, CODEX\\.md\\) are not removed\\."
  [ ! -e "$TMP_INSTALL" ]
  [ ! -e "$TMP_HOME/.claude/skills/web-xp-check" ]
  [ ! -e "$TMP_HOME/.agents/skills/web-xp-check" ]
}

@test "uninstall falls back to legacy glob cleanup when manifest is missing" {
  run bash -lc "printf 'y\n' | HOME=\"$TMP_HOME\" WEB_XP_MANIFEST_PATH=\"$MANIFEST_PATH\" \"$TMP_INSTALL/bin/uninstall.sh\""
  [ "$status" -eq 0 ]

  [ ! -e "$TMP_INSTALL" ]
  [ ! -e "$TMP_HOME/.claude/skills/web-xp-check" ]
  [ ! -e "$TMP_HOME/.agents/skills/web-xp-check" ]
}
