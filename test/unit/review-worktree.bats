#!/usr/bin/env bats
#
# The hooks target the worktree a session is editing, found from a per-session
# record written by the PostToolUse hook, not the directory the session was
# launched in.

load 'test_helper'

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  TOUCH_HOOK="$REPO_ROOT/tools/review-touch-hook.sh"
  STOP_HOOK="$REPO_ROOT/tools/review-stop-hook.sh"
  # Resolve symlinks (macOS /var -> /private/var) so paths match what
  # `git rev-parse --show-toplevel` records.
  TMP="$(cd "$(mktemp -d)" && pwd -P)"
  STATE="$TMP/state"; mkdir -p "$STATE"
  # A stub codex so the Stop hook's `command -v codex` gate passes. The hook is a
  # gate and never runs codex, so an empty stub is enough.
  BIN="$TMP/bin"; mkdir -p "$BIN"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$BIN/codex"; chmod +x "$BIN/codex"
  # A HOME holding the standard file the Stop hook checks for.
  HOME_DIR="$TMP/home"; mkdir -p "$HOME_DIR/.web-xp"; : > "$HOME_DIR/.web-xp/code-guidelines.md"
}

teardown() {
  rm -rf "$TMP"
}

# A git repo on main with one committed app file and a CLAUDE.md marker.
make_repo() {
  local d="$1"; mkdir -p "$d"
  (
    cd "$d"
    git init -q
    git symbolic-ref HEAD refs/heads/main
    : > CLAUDE.md
    printf 'const a = 1;\n' > a.js
    git -c user.email=t@t -c user.name=t add -A
    git -c user.email=t@t -c user.name=t commit -qm base
  )
}

touch_hook() {
  # $1 json on stdin
  printf '%s' "$1" | env WEB_XP_STATE_DIR="$STATE" bash "$TOUCH_HOOK"
}

@test "touch hook records the worktree of the edited file for the session" {
  make_repo "$TMP/proj"
  touch_hook '{"session_id":"s1","tool_name":"Edit","tool_input":{"file_path":"'"$TMP/proj/a.js"'"}}'
  [ "$(cat "$STATE/s1.wt")" = "$TMP/proj" ]
}

@test "touch hook ignores a non-edit tool" {
  make_repo "$TMP/proj"
  touch_hook '{"session_id":"s1","tool_name":"Bash","tool_input":{"command":"ls"}}'
  [ ! -f "$STATE/s1.wt" ]
}

@test "touch hook records the feature worktree, not the main checkout" {
  make_repo "$TMP/main"
  git -C "$TMP/main" worktree add -q -b feat "$TMP/feat"
  touch_hook '{"session_id":"s1","tool_name":"Write","tool_input":{"file_path":"'"$TMP/feat/a.js"'"}}'
  [ "$(cat "$STATE/s1.wt")" = "$TMP/feat" ]
}

@test "concurrent sessions keep separate worktree records" {
  make_repo "$TMP/main"
  git -C "$TMP/main" worktree add -q -b feat "$TMP/feat"
  touch_hook '{"session_id":"sA","tool_name":"Edit","tool_input":{"file_path":"'"$TMP/main/a.js"'"}}'
  touch_hook '{"session_id":"sB","tool_name":"Edit","tool_input":{"file_path":"'"$TMP/feat/a.js"'"}}'
  [ "$(cat "$STATE/sA.wt")" = "$TMP/main" ]
  [ "$(cat "$STATE/sB.wt")" = "$TMP/feat" ]
}

@test "stop hook blocks on the session's unreviewed worktree and names it" {
  make_repo "$TMP/main"
  git -C "$TMP/main" worktree add -q -b feat "$TMP/feat"
  printf 'const b = 2;\n' >> "$TMP/feat/a.js"   # uncommitted change in the feature WT
  echo "$TMP/feat" > "$STATE/s1.wt"

  run env HOME="$HOME_DIR" PATH="$BIN:$PATH" WEB_XP_STATE_DIR="$STATE" \
    bash "$STOP_HOOK" <<< '{"session_id":"s1","cwd":"'"$TMP/main"'"}'
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.decision == "block"' >/dev/null
  echo "$output" | grep -qF "$TMP/feat"
}

@test "stop hook allows when the worktree's recorded review is clean" {
  make_repo "$TMP/main"
  git -C "$TMP/main" worktree add -q -b feat "$TMP/feat"
  printf 'const b = 2;\n' >> "$TMP/feat/a.js"
  echo "$TMP/feat" > "$STATE/s1.wt"

  # Record a clean review of the current change, built and hashed the same way
  # the hook does, in the feature worktree's own git dir.
  (
    cd "$TMP/feat"
    gd="$(git rev-parse --git-dir)"
    h="$(bash "$REPO_ROOT/tools/review-diff.sh" | git hash-object --no-filters --stdin)"
    printf '%s\n' "$h" > "$gd/.web-xp-review-hash"
    printf '0\n' > "$gd/.web-xp-review-findings"
  )

  run env HOME="$HOME_DIR" PATH="$BIN:$PATH" WEB_XP_STATE_DIR="$STATE" \
    bash "$STOP_HOOK" <<< '{"session_id":"s1","cwd":"'"$TMP/main"'"}'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "stop hook allows when the session has no worktree record" {
  run env HOME="$HOME_DIR" PATH="$BIN:$PATH" WEB_XP_STATE_DIR="$STATE" \
    bash "$STOP_HOOK" <<< '{"session_id":"unknown","cwd":"'"$TMP"'"}'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "install registers the PostToolUse touch hook with an edit matcher" {
  TMP_HOME="$TMP/installhome"
  mkdir -p "$TMP_HOME/.web-xp/tools"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$TMP_HOME/.web-xp/tools/review-stop-hook.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$TMP_HOME/.web-xp/tools/review-touch-hook.sh"
  run env HOME="$TMP_HOME" WEB_XP_MANIFEST_PATH="$TMP_HOME/web-xp-manifest.txt" bash "$REPO_ROOT/bin/install.sh"
  [ "$status" -eq 0 ]
  cmd="bash $TMP_HOME/.web-xp/tools/review-touch-hook.sh"
  run jq -e --arg c "$cmd" '[.hooks.PostToolUse[]?.hooks[]?.command] | index($c) != null' "$TMP_HOME/.claude/settings.json"
  [ "$status" -eq 0 ]
  run jq -r '.hooks.PostToolUse[0].matcher' "$TMP_HOME/.claude/settings.json"
  [ "$output" = "Edit|Write|MultiEdit|NotebookEdit" ]
}
