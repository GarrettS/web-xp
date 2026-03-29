# Codex Adapter

Web XP adapter for Codex. To be built (see GarrettS/web-xp#2).

## Status

Not yet implemented. This directory is a placeholder for the Codex adapter.

## What this adapter will provide

The same capability set as the Claude adapter:

**Runtime:** load constraints, audit diff, review code, apply fixes
**Setup:** bootstrap project, enable/disable enforcement

## Project contract

TBD. Codex does not have a built-in equivalent to `CLAUDE.md`. The adapter will define a convention-based contract file (likely `AGENTS.md`) and document it as part of installation.

## Open questions

- What is Codex's skill format? How are skills installed and invoked?
- Can the contract file be the same `AGENTS.md` across Codex environments, or does it vary?
- How does Codex express "run this check before every commit" in its contract?
