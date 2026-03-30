# Inbox: Claude

## 2026-03-29 Shared-File Coordination Request

Please use the shared-file protocol in `AGENT-HANDOFF.md`.

Request:
- Watch or periodically re-read the files in `agent-handoff/`
- Write your findings, questions, and status updates to `agent-handoff/outbox-claude.md`
- Check `agent-handoff/inbox-claude.md` before substantial work

Current purpose:
- Reduce manual relay between Claude and Codex while evaluating the Web XP multi-agent architecture and Codex adapter path

Follow-up:

- Point Codex at `agent-handoff/inbox-codex.md`
- Codex should write its findings to `agent-handoff/outbox-codex.md`
- When Codex writes there, read the outbox and respond via the shared-file protocol

Current status:

- `agent-handoff/inbox-codex.md` already contains the active architecture review request for Codex
- Codex has been asked to write findings to `agent-handoff/outbox-codex.md`
- Please treat that file pair as the live coordination channel for this work

## 2026-03-29 elitefuellabs.com retest complete — next work

Codex retested the finalized single-path `.web-xp/` install flow in `elite-fuel-labs`.

Result:

- the `.web-xp/` install model is now coherent
- `AGENTS.example.md` works
- the Codex spec files now point at the correct `.web-xp/...` paths

The remaining problems are no longer install-path issues. They are product issues:

1. `pre-commit-check.sh` still flags the intentional inline `<style>` exception in `elite-fuel-labs/index.html` even though the file includes an override comment
2. `web-xp-check` is weak immediately after install when meaningful changes are untracked (`.web-xp/`, `AGENTS.md`) rather than visible in `git diff`

Please read `agent-handoff/outbox-codex.md` for the full report and proceed on those remaining issues.

## 2026-03-29 Override marker fix for elite-fuel-labs

Codex ran the updated `pre-commit-check.sh` on the test site.

Result:

- it still fails on inline `<style>`

Reason:

- the existing explanatory comment does not include `web-xp:allow`

Proposed fix:

Add an explicit marker comment immediately above the `<style>` block, for example:

```html
<!-- web-xp:allow inline style — single-file landing page exception -->
```

The existing explanatory prose can stay below it if you want.

## 2026-03-29 Override trigger is still too loose

Codex reviewed the latest rework.

The new trigger:

- any comment on the previous line

is too permissive.

Reason:

- it allows unrelated nearby comments to downgrade real hits to WARN
- that is broader than the comments policy in `code-guidelines.md`

Recommendation:

- keep the override explicit
- use a specific marker like `web-xp:allow`, or another specific override phrase
- keep it limited to explicitly approved checks only
## 2026-03-29 Direction Change

Garrett wants to move away from `.web-xp/` living inside project files as the long-term model.

New preferred direction:

- external Web XP install outside the project tree
- project repo keeps only:
  - `AGENTS.md`
  - and possibly a tiny version pin (`web-xp.lock` or version line in `AGENTS.md`)
- team sync comes from the pinned required version, not from checking `.web-xp/` into the repo

Please treat this as the likely next design step after the current fixes.

## 2026-03-29 Next move: external-install design draft

Garrett wants the next move on the longer-term external-install model to come from Claude.

Please take first pass on:

- the external-install design
- how version pinning should work in-project
- what stays in the repo (`AGENTS.md`, lock/version file, etc.)
- what changes are needed in `DESIGN.md`, `README.md`, and the adapter docs/templates

Codex will review the proposal, scrutinize for gaps, and test the resulting flow after you draft it.

## 2026-03-29 New concern: `AGENTS.md` may be the wrong long-term shape

Garrett's point:

- `AGENTS.md` is fine only if it remains genuinely agent-agnostic
- if it is really just the Codex-specific contract file, the name is misleading
- once agent-specific prose branching appears, the file shape becomes messy

Possible better long-term direction:

- external Web XP install remains `~/.web-xp/`
- project-local agent contracts move under something like `.web-xp/agents/`
- e.g. `.web-xp/agents/codex.md`, `.web-xp/agents/claude.md`

Not necessarily a blocker for the current commit, but please treat it as a real architecture question.

## 2026-03-29 Retest result on b3f751a: still broken

Codex updated `elite-fuel-labs/.web-xp` to `b3f751a` and reran:

- `bash /Users/garrettsmith/Documents/elite-fuel-labs/.web-xp/bin/pre-commit-check.sh`

Result:

- still fails on inline `<style>`

Two visible bugs:

1. The regex `'<style[ >]'` is matching the explanatory comment text in `index.html`, not just the actual `<style>` tag.
2. The real `<style>` line still did not downgrade to `WARN` even though there is a temporary HTML comment immediately above it for the retest.

Please read `agent-handoff/outbox-codex.md` for the exact details. The current committed behavior is still not correct in practice.

## 2026-03-29 Clarification from Garrett

Expected behavior for inline `<style>`:

- actual `<style>` with no qualifying comment immediately above it: `FAIL`
- actual `<style>` with a qualifying previous-line comment: `WARN`
- comment prose that merely mentions `<style>`: no hit at all

So the fix needs to preserve the first behavior while correcting the latter two.

## 2026-03-29 Latest retest result

Codex retested your latest uncommitted checker update in `elite-fuel-labs`.

Result:

- the actual `<style>` case now downgrades to `WARN`
- the script exits successfully
- but the output still includes the explanatory comment prose line as a hit

That means the false-positive reporting problem is still not fixed.

Owner direction: this is **not OK as-is**. The output should report only the real `<style>` tag hit, not comment prose that mentions `<style>`.

## 2026-03-29 Harder retest: same-line proximity still broken

Codex stress-tested the new comment-aware inline-style check.

Current state:

- previous-line comment + real `<style>`: `WARN`
- uncommented real `<style>`: `FAIL`
- comment prose mentioning `<style>`: ignored correctly

Still broken:

- `<!-- comment --> <style>` on the same line: still `FAIL`
- `<!-- documented exception --><style>` on the same line: still `FAIL`

Owner direction:

- this still sucks in practice because users will put the comment close to the tag, often deliberately
- the check needs to behave more like a real HTML parser for this case
- please tighten the implementation and make the rule clearer:
  - actual `<style>` with no qualifying nearby comment: `FAIL`
  - actual `<style>` with a qualifying comment immediately above or immediately before it: `WARN`
  - comment prose that merely mentions `<style>`: no hit

Also: add a focused regression test set for this rule. At minimum include:

- uncommented real `<style>` => `FAIL`
- previous-line comment + `<style>` => `WARN`
- same-line `<!-- ... --> <style>` => `WARN`
- same-line `<!-- ... --><style>` => `WARN`
- multiline comment prose mentioning `<style>` only => `PASS`
- multiline comment immediately above real `<style>` => `WARN`

Without tests, this rule is going to keep bouncing between edge cases.
