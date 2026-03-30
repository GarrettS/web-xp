# Web XP Review — Evaluate Any Code Against the Standards

Review code provided by the user — pasted snippets, file paths, or directories — against the Web XP standards. Unlike web-xp-check (which audits git diffs), this works on any code from any source.

## Procedure

### 1. Load the standards

Read `code-guidelines.md` from your Web XP install. For explanatory context, read `code-philosophy.md`.

### 2. Receive code to review

Accept code as: pasted text, a file path, a directory, or a description of a pattern to evaluate. If nothing provided, ask what to review.

If framework code is provided (React, Vue, etc.), evaluate both the original and what the Web XP-aligned vanilla equivalent would look like.

### 3. Analyze against Web XP patterns

Assess against the same pattern list as web-xp-check: Event Delegation, Active Object, Shared Key, Ancestor Class, Dispatch Table, Fail-Safe, CSS over JS, hidden attribute, Extract Shared Logic, Template and cloneNode.

Also assess against Language Rules: naming conventions, module cohesion, identifier accuracy, guard clauses, DOM content, string concatenation.

### 4. Report findings

For each finding: pattern name, violation or opportunity, Web XP-aligned alternative.

For framework code, show the vanilla equivalent side by side.

### 5. Offer next steps

Suggest specific actions based on findings. Reference the actual violations, not generic options.
