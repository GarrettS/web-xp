# Web XP Project Contract

Read this file first on every task.

<!-- web-xp-version: 02be06a -->

## On every session

If the task involves JS, HTML, or CSS, read `code-guidelines.md` and `code-philosophy.md` from your Web XP install before writing or reviewing code.

Apply the standard to the new code you write for the user's request. Do not refactor unrelated existing code unless the user asks. If you notice pre-existing Web XP violations outside the requested scope, ask whether to fix them now, list them, or leave them.

## Editorial Rules (ER)

`editorial-rules.md` in your Web XP install is the prose styleguide. Read it on demand and apply it to covered prose (its Scope lists what counts), including prose you draft for the user to use (e.g. "you can explain the code like this: …").

## Before every commit

1. Run `bash ~/.web-xp/bin/pre-commit-check.sh` — catches mechanical violations.
2. Review the diff against Patterns and Fail-Safe in `code-guidelines.md` from your Web XP install.
3. Verify covered prose in the diff against the ER.
