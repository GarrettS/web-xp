#!/usr/bin/env bats

load 'test_helper'

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  INSTALL_SCRIPT="$REPO_ROOT/bin/install.sh"
  TMP_HOME="$(mktemp -d)"
  MANIFEST_PATH="$TMP_HOME/web-xp-manifest.txt"
  HOOK_CMD="bash $TMP_HOME/.web-xp/tools/review-stop-hook.sh"
  # Simulate the clone layout install.sh expects at ~/.web-xp, so the
  # registration guard (hook script must exist) is satisfied.
  mkdir -p "$TMP_HOME/.web-xp/tools"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$TMP_HOME/.web-xp/tools/review-stop-hook.sh"
}

teardown() {
  rm -rf "$TMP_HOME"
}

run_install() {
  run env HOME="$TMP_HOME" WEB_XP_MANIFEST_PATH="$MANIFEST_PATH" bash "$INSTALL_SCRIPT"
}

@test "install registers the review Stop hook in settings.json" {
  run_install
  [ "$status" -eq 0 ]
  assert_file_exists "$TMP_HOME/.claude/settings.json"
  run jq -e --arg c "$HOOK_CMD" '[.hooks.Stop[]?.hooks[]?.command] | index($c) != null' "$TMP_HOME/.claude/settings.json"
  [ "$status" -eq 0 ]
}

@test "registration is idempotent and preserves other settings and hooks" {
  mkdir -p "$TMP_HOME/.claude"
  cat > "$TMP_HOME/.claude/settings.json" <<'JSON'
{ "model": "keep-me", "hooks": { "Stop": [ { "hooks": [ { "type": "command", "command": "bash /other/hook.sh" } ] } ] } }
JSON
  run_install; [ "$status" -eq 0 ]
  run_install; [ "$status" -eq 0 ]

  run jq "[.hooks.Stop[].hooks[].command | select(contains(\"review-stop-hook.sh\"))] | length" "$TMP_HOME/.claude/settings.json"
  [ "$output" -eq 1 ]
  run jq -r '.model' "$TMP_HOME/.claude/settings.json"
  [ "$output" = "keep-me" ]
  run jq -e '[.hooks.Stop[].hooks[].command] | index("bash /other/hook.sh") != null' "$TMP_HOME/.claude/settings.json"
  [ "$status" -eq 0 ]
}

@test "uninstall unregisters the review Stop hook and keeps other hooks" {
  TMP_INSTALL="$TMP_HOME/.web-xp"
  mkdir -p "$TMP_INSTALL/bin" "$TMP_HOME/.claude/skills/web-xp-check"
  cp "$REPO_ROOT/bin/uninstall.sh" "$TMP_INSTALL/bin/uninstall.sh"
  echo skill > "$TMP_HOME/.claude/skills/web-xp-check/SKILL.md"
  jq -n --arg c "$HOOK_CMD" '{model:"keep", hooks:{Stop:[{hooks:[{type:"command",command:$c},{type:"command",command:"bash /other/hook.sh"}]}]}}' \
    > "$TMP_HOME/.claude/settings.json"
  cat > "$TMP_INSTALL/web-xp-manifest.txt" <<EOF
# web-xp-manifest-v1
$TMP_HOME/.claude/skills/web-xp-check/SKILL.md
EOF

  run bash -lc "printf 'y\n' | HOME=\"$TMP_HOME\" WEB_XP_MANIFEST_PATH=\"$TMP_INSTALL/web-xp-manifest.txt\" \"$TMP_INSTALL/bin/uninstall.sh\""
  [ "$status" -eq 0 ]

  run jq -e --arg c "$HOOK_CMD" '[.hooks.Stop[]?.hooks[]?.command] | index($c) == null' "$TMP_HOME/.claude/settings.json"
  [ "$status" -eq 0 ]
  run jq -e '[.hooks.Stop[].hooks[].command] | index("bash /other/hook.sh") != null' "$TMP_HOME/.claude/settings.json"
  [ "$status" -eq 0 ]
  run jq -r '.model' "$TMP_HOME/.claude/settings.json"
  [ "$output" = "keep" ]
}

@test "stop hook no-ops when codex is absent (never triggers a review)" {
  # a PATH with the hook's tools but deliberately no codex
  BIN="$TMP_HOME/bin"; mkdir -p "$BIN"
  for t in bash cat jq git grep rm mktemp sed; do
    p="$(command -v "$t" 2>/dev/null)" && ln -sf "$p" "$BIN/$t"
  done
  # a Web XP project with an uncommitted code change
  proj="$TMP_HOME/proj"; mkdir -p "$proj"
  (
    cd "$proj"
    git init -q
    git symbolic-ref HEAD refs/heads/main
    : > CLAUDE.md
    printf 'const a = 1;\n' > a.js
    git -c user.email=t@t -c user.name=t add -A
    git -c user.email=t@t -c user.name=t commit -qm base
    printf 'const b = 2;\n' >> a.js
  )
  run env -i HOME="$TMP_HOME" PATH="$BIN" bash "$REPO_ROOT/tools/review-stop-hook.sh" <<< "{\"cwd\":\"$proj\"}"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "install records the real installed commit in .web-xp-install-info" {
  run_install
  [ "$status" -eq 0 ]
  info="$TMP_HOME/.claude/skills/.web-xp-install-info"
  assert_file_exists "$info"
  grep -q '^installed-commit: ' "$info"
  grep -q '^installed-commit-date: ' "$info"
}
