#!/usr/bin/env bats

load 'test_helper'

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  CHECKER="$REPO_ROOT/bin/pre-commit-check.sh"
  CASE_DIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$CASE_DIR"
}

write_fixture() {
  local relpath="$1"
  local content="$2"
  mkdir -p "$(dirname "$CASE_DIR/$relpath")"
  printf '%s\n' "$content" > "$CASE_DIR/$relpath"
}

run_checker() {
  run bash -lc "cd \"$CASE_DIR\" && bash \"$CHECKER\" 2>&1"
}

@test "uncommented style tag fails" {
  write_fixture "index.html" '<style>body { margin: 0; }</style>'
  run_checker
  [ "$status" -eq 1 ]
  assert_output_matches 'FAIL.*Inline.*style'
}

@test "previous-line comment above style tag warns" {
  write_fixture "index.html" '<!-- Critical CSS exception -->
<style>body { margin: 0; }</style>'
  run_checker
  [ "$status" -eq 0 ]
  assert_output_matches 'WARN.*Inline.*style'
  assert_output_not_matches 'FAIL.*Inline.*style'
}

@test "same-line comment before style tag warns" {
  write_fixture "index.html" '<!-- exception --> <style>body { margin: 0; }</style>'
  run_checker
  [ "$status" -eq 0 ]
  assert_output_matches 'WARN.*Inline.*style'
  assert_output_not_matches 'FAIL.*Inline.*style'
}

@test "same-line comment without space before style tag warns" {
  write_fixture "index.html" '<!-- exception --><style>body { margin: 0; }</style>'
  run_checker
  [ "$status" -eq 0 ]
  assert_output_matches 'WARN.*Inline.*style'
  assert_output_not_matches 'FAIL.*Inline.*style'
}

@test "comment prose mentioning style tag passes" {
  write_fixture "index.html" '<!-- This mentions <style> in prose only -->
<p>No actual style tag here</p>'
  run_checker
  [ "$status" -eq 0 ]
  assert_output_matches 'PASS.*Inline.*style'
  assert_output_not_matches '(FAIL|WARN).*Inline.*style'
}

@test "multiline comment mentioning style tag passes" {
  write_fixture "index.html" '<!--
  This is a multi-line comment
  that mentions <style> in prose
-->
<p>No style tag</p>'
  run_checker
  [ "$status" -eq 0 ]
  assert_output_matches 'PASS.*Inline.*style'
  assert_output_not_matches '(FAIL|WARN).*Inline.*style'
}

@test "multiline comment above style tag warns" {
  write_fixture "index.html" '<!--
  Critical CSS for above-the-fold rendering.
  Single-file landing page exception.
-->
<style>body { margin: 0; }</style>'
  run_checker
  [ "$status" -eq 0 ]
  assert_output_matches 'WARN.*Inline.*style'
  assert_output_not_matches 'FAIL.*Inline.*style'
}

@test "style hit reports tag line not comment prose" {
  write_fixture "index.html" '<!--
  Inline <style> is an intentional exception
-->
<style>body { margin: 0; }</style>'
  run_checker
  [ "$status" -eq 0 ]
  assert_output_matches '<style>body'
  assert_output_not_matches 'intentional exception'
}

@test "commented fetch warns" {
  write_fixture "app.js" '// Fetches user profile, caught in caller
fetch("/api/profile");'
  run_checker
  [ "$status" -eq 0 ]
  assert_output_matches 'WARN.*fetch'
  assert_output_not_matches 'FAIL.*fetch.*\.js'
}

@test "uncommented fetch fails" {
  write_fixture "app.js" 'fetch("/api/profile");'
  run_checker
  [ "$status" -eq 1 ]
  assert_output_matches 'FAIL.*fetch'
}

@test "commented eval still fails" {
  write_fixture "app.js" '// Need dynamic evaluation here
eval("1 + 1");'
  run_checker
  [ "$status" -eq 1 ]
  assert_output_matches 'FAIL.*eval'
  assert_output_not_matches 'WARN.*eval'
}

@test "commented loose equality still fails" {
  write_fixture "app.js" '// Legacy comparison
if (x == 1) {}'
  run_checker
  [ "$status" -eq 1 ]
  assert_output_matches 'FAIL.*equality'
  assert_output_not_matches 'WARN.*equality'
}

@test "commented var still fails" {
  write_fixture "app.js" '// Old-style declaration
var x = 1;'
  run_checker
  [ "$status" -eq 1 ]
  assert_output_matches 'FAIL.*var'
  assert_output_not_matches 'WARN.*var'
}
