#!/bin/bash
# Regression tests for bin/pre-commit-check.sh
# Runs each test case in an isolated temp directory.
#
# Usage: bash test/test-pre-commit.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECKER="$REPO_ROOT/bin/pre-commit-check.sh"

PASS_COUNT=0
FAIL_COUNT=0
TOTAL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Run a test case in an isolated temp directory.
# $1: test name
# $2: expected exit code (0 or 1)
# $3: expected output pattern (grep -E regex)
# $4: unexpected output pattern (grep -E regex, must NOT appear)
# Fixture files are written before calling this function via
# write_fixture().
CASE_DIR=""

setup_case() {
  CASE_DIR=$(mktemp -d)
}

teardown_case() {
  rm -rf "$CASE_DIR"
  CASE_DIR=""
}

write_fixture() {
  local relpath="$1"
  local content="$2"
  local dir
  dir=$(dirname "$CASE_DIR/$relpath")
  mkdir -p "$dir"
  printf '%s\n' "$content" > "$CASE_DIR/$relpath"
}

run_case() {
  local name="$1"
  local expected_exit="$2"
  local expected_pattern="${3:-}"
  local unexpected_pattern="${4:-}"

  TOTAL=$((TOTAL + 1))

  local output exit_code=0
  output=$(cd "$CASE_DIR" && bash "$CHECKER" 2>&1) || exit_code=$?

  local failed=0

  # Check exit code
  if [ "$exit_code" != "$expected_exit" ]; then
    echo -e "${RED}FAIL${NC}  $name"
    echo "  Expected exit $expected_exit, got $exit_code"
    failed=1
  fi

  # Check expected pattern
  if [ -n "$expected_pattern" ]; then
    if ! echo "$output" | grep -qE "$expected_pattern"; then
      echo -e "${RED}FAIL${NC}  $name"
      echo "  Expected pattern not found: $expected_pattern"
      echo "  Output: $(echo "$output" | grep -iE 'style|FAIL|WARN' | head -5)"
      failed=1
    fi
  fi

  # Check unexpected pattern
  if [ -n "$unexpected_pattern" ]; then
    if echo "$output" | grep -qE "$unexpected_pattern"; then
      echo -e "${RED}FAIL${NC}  $name"
      echo "  Unexpected pattern found: $unexpected_pattern"
      echo "  Output: $(echo "$output" | grep -E "$unexpected_pattern" | head -5)"
      failed=1
    fi
  fi

  if [ "$failed" -eq 0 ]; then
    echo -e "${GREEN}PASS${NC}  $name"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi

  teardown_case
}

echo "=== Pre-Commit Check Regression Tests ==="
echo ""

# ---- Inline <style> tests ----

echo "--- Inline <style> ---"

# 1. Uncommented <style> => FAIL
setup_case
write_fixture "index.html" '<style>body { margin: 0; }</style>'
run_case "Uncommented <style> => FAIL" \
  1 \
  "FAIL.*Inline.*style" \
  ""

# 2. Previous-line comment + <style> => WARN
setup_case
write_fixture "index.html" '<!-- Critical CSS exception -->
<style>body { margin: 0; }</style>'
run_case "Previous-line comment + <style> => WARN" \
  0 \
  "WARN.*Inline.*style" \
  "FAIL.*Inline.*style"

# 3. Same-line comment with space before <style> => WARN
setup_case
write_fixture "index.html" '<!-- exception --> <style>body { margin: 0; }</style>'
run_case "Same-line <!-- ... --> <style> => WARN" \
  0 \
  "WARN.*Inline.*style" \
  "FAIL.*Inline.*style"

# 4. Same-line comment no space before <style> => WARN
setup_case
write_fixture "index.html" '<!-- exception --><style>body { margin: 0; }</style>'
run_case "Same-line <!-- ... --><style> => WARN" \
  0 \
  "WARN.*Inline.*style" \
  "FAIL.*Inline.*style"

# 5. Comment prose mentioning <style> => no hit
setup_case
write_fixture "index.html" '<!-- This mentions <style> in prose only -->
<p>No actual style tag here</p>'
run_case "Comment prose mentioning <style> => PASS" \
  0 \
  "PASS.*Inline.*style" \
  "(FAIL|WARN).*Inline.*style"

# 6. Multi-line comment mentioning <style> => no hit
setup_case
write_fixture "index.html" '<!--
  This is a multi-line comment
  that mentions <style> in prose
-->
<p>No style tag</p>'
run_case "Multi-line comment with <style> prose => PASS" \
  0 \
  "PASS.*Inline.*style" \
  "(FAIL|WARN).*Inline.*style"

# 7. Multi-line comment immediately above real <style> => WARN
setup_case
write_fixture "index.html" '<!--
  Critical CSS for above-the-fold rendering.
  Single-file landing page exception.
-->
<style>body { margin: 0; }</style>'
run_case "Multi-line comment above <style> => WARN" \
  0 \
  "WARN.*Inline.*style" \
  "FAIL.*Inline.*style"

# 8. Hit line reports the tag, not comment prose
setup_case
write_fixture "index.html" '<!--
  Inline <style> is an intentional exception
-->
<style>body { margin: 0; }</style>'
run_case "Hit line is the tag, not comment prose" \
  0 \
  "<style>body" \
  "intentional exception"

# ---- Overridable check tests ----

echo ""
echo "--- Overridable checks ---"

# 9. Commented fetch => WARN
setup_case
write_fixture "app.js" '// Fetches user profile, caught in caller
fetch("/api/profile");'
run_case "Commented fetch() => WARN" \
  0 \
  "WARN.*fetch" \
  "FAIL.*fetch.*\\.js"

# 10. Uncommented fetch => FAIL
setup_case
write_fixture "app.js" 'fetch("/api/profile");'
run_case "Uncommented fetch() => FAIL" \
  1 \
  "FAIL.*fetch" \
  ""

# ---- Hard-FAIL check tests (no override) ----

echo ""
echo "--- Hard-FAIL checks (no override) ---"

# 11. Commented eval => still FAIL
setup_case
write_fixture "app.js" '// Need dynamic evaluation here
eval("1 + 1");'
run_case "Commented eval() => still FAIL" \
  1 \
  "FAIL.*eval" \
  "WARN.*eval"

# 12. Commented loose equality => still FAIL
setup_case
write_fixture "app.js" '// Legacy comparison
if (x == 1) {}'
run_case "Commented loose equality => still FAIL" \
  1 \
  "FAIL.*equality" \
  "WARN.*equality"

# 13. Commented var => still FAIL
setup_case
write_fixture "app.js" '// Old-style declaration
var x = 1;'
run_case "Commented var => still FAIL" \
  1 \
  "FAIL.*var" \
  "WARN.*var"

# ---- Summary ----

echo ""
echo "=== Results: $PASS_COUNT passed, $FAIL_COUNT failed, $TOTAL total ==="

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
