# Web XP Skill Discovery Test Protocol

Test project with intentionally bad code for verifying agent skill discovery and behavior.

## Purpose

Verify that Web XP skills are discovered, fail gracefully in incomplete setups, and run correctly in complete setups.

## Prerequisites

- Web XP installed globally (`~/.web-xp`)
- `bin/install.sh` has been run
- Claude skills installed to `$HOME/.claude/skills/`
- Codex skills installed to `$HOME/.agents/skills/`
- No flat Codex skill files in `adapters/codex/`
- Codex overlay does not reference a spec directory or flat skill files

## Variables

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
TEST_DIR="$HOME/tmp/web-xp-test"
```

All paths below use these variables. `$TEST_DIR` is user-scoped — no system `/tmp` dependency.

## Known violations

### HTML (index.html)

- Inline `<style>` block
- Hardcoded colors (`#3b82f6`, `gray`, `white`)
- Inline event handler (`onclick="addTask()"`)

### JavaScript (app.js)

- `var` instead of `const`/`let`
- Loose equality (`==`, `!=`) throughout
- Generic variable names (`val`, `inp`, `id`, `items`)
- `innerHTML` with string concatenation
- Inline styles (`li.style.padding`, `li.style.borderBottom`)
- `querySelectorAll` loop to find by known ID (breaks Shared Key)
- `.find()` linear scan for known key (breaks Shared Key)
- `addEventListener` inside a loop (`initFilters`)
- `addEventListener` inside a callable function (`attachHandlers`)
- Empty catch block (`loadFromServer`)
- `console.log` only in catch (`saveToServer` — not user-visible)
- `fetch` without checking `response.ok`
- `style.display` toggling instead of `hidden` attribute or class
- No module structure — everything global

---

## Suite A: No git repo

Tests skill discovery and graceful failure when there is no git repo.

### Setup

```bash
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cp "$REPO_ROOT/test/badcode-test-website/index.html" "$TEST_DIR/"
cp "$REPO_ROOT/test/badcode-test-website/app.js" "$TEST_DIR/"
cd "$TEST_DIR"
```

### Teardown

```bash
rm -rf "$TEST_DIR"
```

### Test A1: web-xp-check without a git repo

**Steps:**
1. Open a fresh agent session in `$TEST_DIR/`
2. Run `web-xp-check` (Codex) or `/web-xp-check` (Claude)

**Expected outcome:**
1. Agent discovers the skill from the global install path
2. Skill reports that there is no git repository — cannot produce a diff
3. Agent does not crash or produce confusing output
4. Agent may suggest running `git init` or using `web-xp-review` instead

**Record:** Skill discovered? Graceful failure? Error message?

---

## Suite B: Git repo, no contract

Tests skill discovery when the project is a git repo but has no Web XP contract.

### Setup

```bash
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cp "$REPO_ROOT/test/badcode-test-website/index.html" "$TEST_DIR/"
cp "$REPO_ROOT/test/badcode-test-website/app.js" "$TEST_DIR/"
cd "$TEST_DIR"
git init
git add .
git commit -m "initial bad code"
echo "// touched" >> app.js
```

### Teardown

```bash
rm -rf "$TEST_DIR"
```

### Test B1: web-xp-check without a contract

**Steps:**
1. Open a fresh agent session in `$TEST_DIR/`
2. Verify no `CLAUDE.md` or `CODEX.md` exists
3. Run `web-xp-check` (Codex) or `/web-xp-check` (Claude)

**Expected outcome:**
1. Agent discovers the skill from the global install path
2. Skill attempts to run — there is a git diff to check
3. Skill may report that no project contract was found
4. Skill may still check the diff if it can locate the standards from the global install

**Record:** Skill discovered? Attempted to run? Output or error?

---

## Suite C: Full project (git repo + contract)

Tests the complete happy path: project setup, check, review, and standards loading.

### Setup

```bash
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cp "$REPO_ROOT/test/badcode-test-website/index.html" "$TEST_DIR/"
cp "$REPO_ROOT/test/badcode-test-website/app.js" "$TEST_DIR/"
cd "$TEST_DIR"
git init
git add .
git commit -m "initial bad code"
echo "// touched" >> app.js
```

Then open a fresh agent session and run `web-xp-init` (Codex) or `/web-xp-init` (Claude).

### Teardown

```bash
rm -rf "$TEST_DIR"
```

### Test C1: web-xp-init creates a correct contract

**Steps:**
1. Run `web-xp-init` (Codex) or `/web-xp-init` (Claude)
2. Read the created contract file (`CODEX.md` or `CLAUDE.md`)

**Expected outcome:**
1. Contract file created in `$TEST_DIR/`
2. File contains `<!-- BEGIN WEB-XP` and `<!-- END WEB-XP -->` markers
3. File does NOT contain "spec directory" or reference flat files in `adapters/codex/`
4. File contains session directives (read standards) and commit directives (run pre-commit check)

**Record:** Contract created? Managed block markers present? Flat-file references absent?

### Test C2: web-xp-check finds violations

**Steps:**
1. Verify the contract from C1 exists
2. Verify there is an unstaged diff (`echo "// touched" >> app.js` from setup)
3. Run `web-xp-check` (Codex) or `/web-xp-check` (Claude)

**Expected outcome:**
1. Agent discovers the skill
2. Skill runs the pre-commit check and structural review
3. Reports at least 5 violations from the known violations list
4. Violations include at minimum: `var`, loose equality (`==`), empty catch, inline event handler, hardcoded colors
5. Each finding includes: file, line, pattern name, violation or opportunity, alternative

**Record:** Skill discovered? Check ran? Violation count? False positives? Significant misses?

### Test C3: web-xp-review reviews a specific file

**Steps:**
1. Verify the contract exists
2. Run `web-xp-review app.js` (Codex) or `/web-xp-review app.js` (Claude)

**Expected outcome:**
1. Agent discovers the skill
2. Skill reviews `app.js` against the full Web XP standard
3. Reports violations and opportunities — should find more than `web-xp-check` since it reviews the whole file, not just the diff
4. Findings reference specific patterns by name

**Record:** Skill discovered? Review ran? Finding count?

### Test C4: web-xp loads standards

**Steps:**
1. Verify the contract exists
2. Run `web-xp` (Codex) or `/web-xp` (Claude)

**Expected outcome:**
1. Agent discovers the skill
2. Standards loaded into the session
3. Agent acknowledges Web XP constraints are active
4. Subsequent code suggestions in the session follow Web XP patterns

**Record:** Skill discovered? Standards loaded? Agent acknowledges constraints?

---

## Suite D: Contract exists, always-on off

Tests that skills are still discoverable on demand when enforcement is disabled, but the agent does not enforce automatically.

### Setup

```bash
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cp "$REPO_ROOT/test/badcode-test-website/index.html" "$TEST_DIR/"
cp "$REPO_ROOT/test/badcode-test-website/app.js" "$TEST_DIR/"
cd "$TEST_DIR"
git init
git add .
git commit -m "initial bad code"
echo "// touched" >> app.js
```

Then open a fresh agent session, run `web-xp-init`, then run `web-xp-off`.

### Teardown

```bash
rm -rf "$TEST_DIR"
```

### Test D1: Skills discoverable with enforcement off

**Steps:**
1. Verify contract exists and always-on is disabled (directives commented out)
2. Run `web-xp-check` (Codex) or `/web-xp-check` (Claude)

**Expected outcome:**
1. Agent discovers the skill — enforcement being off does not prevent manual invocation
2. Skill runs the check and reports violations
3. Behavior is the same as C2 — the skill works, it just wasn't loaded automatically

**Record:** Skill discovered? Check ran? Violation count?

### Test D2: Agent does not auto-enforce with always-on off

**Steps:**
1. Verify contract exists and always-on is disabled
2. Ask the agent to write code (e.g. "add a delete-all button to app.js")
3. Observe whether the agent loads Web XP standards before writing code

**Expected outcome:**
1. Agent writes code WITHOUT loading Web XP standards first
2. The generated code may contain Web XP violations — that is expected
3. The agent does not mention pre-commit checks or Web XP patterns unless asked

**Record:** Did agent auto-load standards? (should be no) Did agent mention Web XP unprompted? (should be no)

### Test D3: Re-enable always-on

**Steps:**
1. Run `web-xp-on` (Codex) or `/web-xp-on` (Claude)
2. Ask the agent to write code again

**Expected outcome:**
1. Agent now loads Web XP standards before writing code
2. Generated code follows Web XP patterns
3. Agent mentions pre-commit checks before committing

**Record:** Standards loaded automatically? Code follows patterns? Pre-commit mentioned?

---

## Pass criteria

| Test | Pass condition |
|------|---------------|
| A1 | Skill discovered, graceful failure, no crash |
| B1 | Skill discovered, attempts to run |
| C1 | Contract created, managed block present, no flat-file references |
| C2 | Skill ran, at least 5 violations found |
| C3 | Skill ran, findings reported |
| C4 | Skill ran, standards loaded |
| D1 | Skill discovered and ran with enforcement off |
| D2 | Agent does NOT auto-enforce with always-on off |
| D3 | Agent auto-enforces after web-xp-on |
