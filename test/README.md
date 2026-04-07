# Tests

## Quick start

```bash
brew install bats-core    # one-time
bash test/run-unit.sh     # run all unit tests
```

## Unit tests (Bats)

`test/unit/*.bats` — local, deterministic, no network or agent CLI required.

| File | Tests | What it covers |
|---|---|---|
| `install.bats` | 4 | install.sh copies skills and standards to correct paths, cleans stale files, preserves unrelated files |
| `uninstall.bats` | 2 | uninstall.sh confirms by default and removes installed runtime state on approval |
| `pre-commit.bats` | 13 | pre-commit-check.sh catches violations and respects comment overrides |
| `sync.bats` | 3 | build-adapter-skills.sh generates correct YAML frontmatter and DO NOT EDIT headers |

Runner: `test/run-unit.sh` — checks bats-core is installed, runs all `.bats` files.

Helper: `test/unit/test_helper.bash` — shared assertions (`assert_dir_exists`).

## E2E tests (agent CLI)

Behavioral tests that verify skill discovery and enforcement in real agent sessions. Require a separate macOS user (`webxp-test`) for clean-state isolation. See `E2E-README.md` for full setup and rationale.

| File | Purpose |
|---|---|
| `e2e-run.sh` | Full setup → test → teardown runner |
| `e2e-setup.sh` | Cleans Codex state, creates test project |
| `e2e-teardown.sh` | Removes test project, cleans state |
| `webxp-test-user-clean-settings.sh` | Removes session files from test user's ~/.codex/ |

## Test fixtures

`test/badcode-test-website/` — intentionally bad HTML/JS with known Web XP violations.

| File | Purpose |
|---|---|
| `index.html` | Inline styles, hardcoded colors, inline event handler |
| `app.js` | var, loose equality, empty catch, addEventListener in loops, querySelectorAll scans, innerHTML |
| `TEST-PROTOCOL.md` | Automated test protocol (4 suites, 10 cases) |
| `MANUAL-TEST.md` | Interactive behavioral tests (7 cases) |
| `TEST-RESULTS.md` | Results artifact |

## Legacy

These scripts are superseded by the Bats suite but still work:

- `test-pre-commit.sh`
- `test-sync.sh`
- `test-install.sh`

## Known limitations

- **Cross-project session state** ([#21](https://github.com/GarrettS/web-xp/issues/21), [openai/codex#16799](https://github.com/openai/codex/issues/16799)): Codex persists hidden session state (approved commands, behavioral rules) across projects and sessions. A "fresh session" is not reliably clean, and behavioral test results may not be reproducible. Claude has explicit cross-project memory on disk (`~/.claude/projects/`) which is accessible but not injected automatically. Neither agent provides true project-scoped isolation.
- **Workaround:** separate macOS user (`webxp-test`) with clean `$HOME`. See `E2E-README.md`.
- E2E agent tests are not yet automated. Strategy under evaluation ([#20](https://github.com/GarrettS/web-xp/issues/20)).
- Legacy test scripts are being replaced by the Bats suite. They still work but are redundant.
