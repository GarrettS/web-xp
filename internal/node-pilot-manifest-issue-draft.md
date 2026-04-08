# Draft Issue: Use Manifest-Backed Install/Uninstall as the #25 Node.js Pilot

## Summary

`#25` is currently framed as a Node.js evaluation. That is too abstract. A better shape is to give it a bounded deliverable:

- implement manifest-backed install/uninstall
- use that work as the concrete Node.js pilot

This turns `#25` into an engineering decision with a real output instead of an open-ended runtime discussion.

## Problem

Web XP needs install-state tracking for correctness:

- install should be able to remove artifacts from older layouts, renames, and removals
- uninstall should remove exactly the files Web XP installed
- glob-based cleanup is brittle and can leave orphans behind

The proposed solution is a manifest, likely something like:

```json
{
  "version": 1,
  "installed": [
    "/Users/x/.claude/skills/web-xp/SKILL.md",
    "/Users/x/.claude/skills/code-guidelines.md"
  ]
}
```

The problem is that shell has no native JSON support. If we choose a JSON manifest, shell alone is not the implementation. We would need to:

- parse/write JSON with `jq`
- shell out to Python
- shell out to Node
- or build a brittle text-parsing layer around `grep` / `sed` / `awk`

That makes a “shell manifest now, Node later” path likely temporary work if Node is the eventual direction.

## Proposal

Use manifest-backed install/uninstall as the concrete scope for `#25`.

Specifically:

- keep the manifest schema minimal:
  - `version`
  - `installed`
- move manifest read/write/diff logic into Node
- use that Node logic from install/uninstall
- judge `#25` on whether this produces a meaningfully cleaner, safer install-state model than the current shell-only path

## Why This Is a Good Node Pilot

- bounded scope
  - install/uninstall is a small subsystem
  - easier to review and test than a broad rewrite

- native JSON fit
  - Node handles JSON parsing/serialization directly
  - no `jq` dependency
  - no brittle shell text parsing

- real correctness payoff
  - exact artifact tracking
  - deterministic cleanup on reinstall
  - deterministic uninstall behavior

- concrete dogfooding
  - Web XP is a web-facing toolchain
  - using Node for structured tooling is a coherent product choice, not just a technical convenience

- future leverage
  - if successful, the same runtime can later absorb other structured scripts:
    - `bin/web-xp-on`
    - `bin/web-xp-off`
    - `tools/build-adapter-skills.sh`
    - `tools/build-contracts.sh`

## Why Not Python?

Python is also a valid runtime for this class of work and would likely be slightly cheaper in authoring time/tokens.

Reasons Node is the stronger candidate here:

- equal or better fit for JSON manifest/state handling
- better strategic alignment with the repo's web-platform identity
- better dogfooding story for `#25`
- more coherent long-term target if Web XP wants one structured scripting runtime beyond shell

## Why Not Stay in Shell?

Shell is still fine for:

- thin wrappers
- simple file orchestration
- grep-style mechanical checks

Shell is weak for:

- JSON state management
- structured text transforms with validation
- multi-step migration logic

If the manifest format is JSON, shell is no longer a complete solution by itself.

The only strong reason to stay shell-native is if Web XP explicitly wants to avoid adding any runtime dependency beyond POSIX shell and standard utilities. In that case, the better move is likely to avoid JSON entirely and choose a simpler manifest format.

## Scope Recommendation

Recommended `#25` pilot scope:

1. Add a Node entry point for manifest operations.
2. Make install compute the desired managed artifact set.
3. Diff against the previous manifest.
4. Remove previously managed artifacts that no longer belong.
5. Write the new manifest after successful install.
6. Make uninstall remove exactly the recorded artifacts.

Keep `bin/pre-commit-check.sh` in shell for now. It is mostly grep/awk tripwire logic and is not the best first migration target.

## Decision Hinge

This issue really asks one product question:

Is Web XP willing to make Node part of its structured tooling/bootstrap contract?

- If no, avoid JSON or keep the solution shell-compatible without a new runtime.
- If yes, manifest-backed install/uninstall is a strong first pilot.

## Suggested Outcome

Approve `#25` as:

"Pilot Node.js for manifest-backed install/uninstall. Use the result to decide whether Node should replace more of Web XP's structured shell tooling."
