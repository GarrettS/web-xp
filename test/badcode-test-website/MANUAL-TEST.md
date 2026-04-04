# Manual Agent Skill Verification

Interactive manual tests for verifying agent skill discovery, auto-activation behavior, enforcement modes, and scope control.

## Why manual tests

Automated tests (`codex exec`, shell scripts) verify mechanics: does the skill discover? Does it run? Does it find violations? But they cannot catch behavioral problems that only appear in interactive sessions:

- **Auto-activation without contract** (#17) — the agent silently loads skill files for unrelated tasks. Only visible in a multi-turn session where the agent decides to use a skill unprompted.
- **Scope violation on refactor** (#18) — the agent rewrites an entire file when asked for one feature. Requires interactive back-and-forth to observe.
- **Pre-commit enforcement** — does the agent run the pre-commit check before committing? Requires a session where the agent is asked to commit.
- **Session instruction leaking** (openai/codex#16799) — the agent uses paths from other projects. Only diagnosable by asking the agent where a path came from.
- **Skill procedure compliance** — does the agent follow the skill's steps (e.g. stop if no diff exists)? Requires observing the agent's decision-making in real time.

These tests apply to both Claude and Codex. Use `/web-xp-check` for Claude, `web-xp-check` for Codex.

## Variables

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
TEST_DIR="$HOME/tmp/web-xp-test"
```

## Per-test setup and teardown

Each test gets a fresh directory. Run setup before each test, teardown after.

**Setup:**
```bash
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cp "$REPO_ROOT/test/badcode-test-website/index.html" "$TEST_DIR/"
cp "$REPO_ROOT/test/badcode-test-website/app.js" "$TEST_DIR/"
cd "$TEST_DIR"
git init && git add . && git commit -m "initial"
echo "// touched" >> app.js
```

**Teardown:**
```bash
rm -rf "$TEST_DIR"
```

---

## Test 1: Skill discovery without contract

**Setup:** Fresh directory with git. No CODEX.md/CLAUDE.md.

**Steps:**
1. Open a fresh agent session in `$TEST_DIR/`
2. Type: `web-xp-check` (or `/web-xp-check`)

**Expected:** Agent discovers the skill from the global install path and runs it. Reports mechanical violations (var, loose equality, inline onclick, etc.).

**Known issue:** openai/codex#16799 — Codex may run pre-commit-check.sh from a different project's path due to session instruction leaking. Verify the path used is `~/.web-xp/bin/pre-commit-check.sh`, not a path from another project.

**Record:** Skill discovered? Check ran? Correct path used? Violations found?

---

## Test 2: Auto-activation without contract

**Setup:** Fresh directory with git. No CODEX.md/CLAUDE.md.

**Steps:**
1. Open a fresh agent session in `$TEST_DIR/`
2. Type: `add a dark mode toggle button`

**Expected:** Observe whether the agent loads SKILL.md, code-guidelines.md, or code-philosophy.md before writing code. If it does, the skill is auto-activating without a contract.

**Verify:** Check the agent's output log for file reads.

**Known issue:** #17 — skills auto-activate based on description trigger matching.

---

## Test 3: Auto-activation does not enforce

**Setup:** Fresh directory with git. No CODEX.md/CLAUDE.md.

**Steps:**
1. Open a fresh agent session in `$TEST_DIR/`
2. Ask the agent to write code (e.g. `add a dark mode toggle button`)
3. Let it commit without intervention

**Expected:** Agent writes code without enforcing doctrine. May produce violations (var, inline handlers, hardcoded colors). Does NOT run pre-commit-check.sh. Does NOT warn about violations before committing.

**Verify:** Inspect committed code for doctrine violations. Confirm no pre-commit warnings.

---

## Test 4: web-xp-init creates correct contract

**Setup:** Fresh directory with git. No contract.

**Steps:**
1. Open a fresh agent session in `$TEST_DIR/`
2. Type: `web-xp-init` (or `/web-xp-init`)
3. In a separate terminal: `cat $TEST_DIR/CODEX.md` (or `CLAUDE.md`)

**Expected:** Contract created with managed block markers (`<!-- BEGIN WEB-XP -->` / `<!-- END WEB-XP -->`). No "spec directory" or flat-file references. Contains session and commit directives.

---

## Test 5: Enforcement with contract (always-on)

**Setup:** Fresh directory with git. Run `web-xp-init` to create contract.

**Steps:**
1. Open a fresh agent session in `$TEST_DIR/`
2. Type: `add a sort button that sorts tasks alphabetically`
3. Observe: does the agent load standards? Does it apply them to new code?
4. Tell the agent to commit. Does it run pre-commit-check.sh first?

**Expected:** Agent loads standards at session start. New code follows doctrine. Pre-commit check runs before committing. Agent does NOT rewrite existing code unprompted — only the new feature should be added.

**Known issue:** #18 — agent may auto-refactor the entire file instead of just adding the feature.

**Verify:** Compare scope of changes to scope of request. Was only the requested feature added?

---

## Test 6: web-xp-off disables enforcement

**Setup:** Fresh directory with git + contract from `web-xp-init`.

**Steps:**
1. Open a fresh agent session in `$TEST_DIR/`
2. Type: `web-xp-off` (or `/web-xp-off`)
3. Type: `add a delete-all button to app.js`
4. Let it commit

**Expected:** Agent writes code WITHOUT enforcing standards. Does NOT run pre-commit check. Does NOT mention Web XP patterns unless asked.

---

## Test 7: web-xp-on re-enables enforcement

**Setup:** Fresh directory with git + contract. Run `web-xp-off` then `web-xp-on`.

**Steps:**
1. Open a fresh agent session in `$TEST_DIR/`
2. Type: `web-xp-on` (or `/web-xp-on`)
3. Type: `add a filter bar with All, Active, Done buttons`
4. Tell the agent to commit

**Expected:** Agent loads standards and applies them to new code. Pre-commit check runs before committing.

---

## Results table

| Test | What | Catches | Pass? | Notes |
|------|------|---------|-------|-------|
| 1 | Explicit invocation without contract | Skill discovery works globally | | |
| 2 | Auto-activation without contract | #17 — skills fire without opt-in | | |
| 3 | Auto-activation does not enforce | Passive loading vs active enforcement | | |
| 4 | web-xp-init creates correct contract | Contract correctness, no stale refs | | |
| 5 | Enforcement with contract | Always-on works; #18 — scope violation | | |
| 6 | web-xp-off disables enforcement | Off mode actually disables | | |
| 7 | web-xp-on re-enables enforcement | On/off toggle works | | |
