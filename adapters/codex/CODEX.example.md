<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->

# Web XP Project Contract

Read this file first on every task.

<!-- web-xp-version: 02be06a -->

## On every session

If the task involves JS, HTML, or CSS, read `code-guidelines.md` and `code-philosophy.md` from your Web XP install before writing or reviewing code.

## Before every commit

1. Run `bash ~/.web-xp/bin/pre-commit-check.sh` — catches mechanical violations.
2. Review the diff against Patterns and Fail-Safe in `code-guidelines.md` from your Web XP install.

## Web XP spec directory

Treat `~/.web-xp/adapters/codex/` as the Web XP spec directory. When asked to follow a spec (e.g. `web-xp-check.md`), read it from that directory.

<!-- END WEB-XP -->
