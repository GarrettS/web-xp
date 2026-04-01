---
name: web-xp-review
description: "Review code against Web XP standards. Activate when: code pasted or file given, 'review this', 'what's wrong with this', evaluate quality, vanilla equivalent."
---
<!-- DO NOT EDIT — canonical source is /adapters/claude/web-xp-review/SKILL.md.     This copy is auto-synced by the pre-commit hook. Edits here will be overwritten. -->
# Web XP Review — Evaluate Any Code Against the Standards

Review code the user provides — pasted snippets, file paths, or URLs — against the Web XP standards. Unlike web-xp-check (which audits git diffs), this works on any code from any source.

## Procedure

### 1. Load the standards

Read `${CLAUDE_SKILL_DIR}/../code-guidelines.md`. For explanatory context, read `${CLAUDE_SKILL_DIR}/../code-philosophy.md`.

### 2. Receive code to review

If the user provided a file path or pasted code with the command, use that. Otherwise, check if the current working directory is a project with source files. If it is, ask which files or directories to review.

If none of the above, prompt: "What would you like me to review? You can paste code, give me a file path, or point me at a directory."

The user provides code in one of these forms:
- Pasted directly in the conversation
- A file path or directory to read
- A description of a pattern to evaluate

If the user provides a React component or framework code, evaluate both the original and what the Web XP-aligned vanilla equivalent would look like.

### 3. Analyze against Web XP patterns

For each concern in the code, assess against the patterns defined in the Patterns and Fail-Safe sections of code-guidelines.md. Use the same pattern recognition list as web-xp-check: Event Delegation, Active Object, Shared Key, Ancestor Class, Dispatch Table, Fail-Safe, CSS over JS, hidden attribute, Extract Shared Logic, Template and cloneNode.

Also assess against Language Rules: naming conventions, module cohesion, identifier accuracy, guard clauses, DOM content, string concatenation.

### 4. Report findings

For each finding, report the pattern name, whether the code violates or could benefit from it, and the Web XP-aligned alternative.

When reviewing framework code, show the vanilla equivalent side by side. Do not just criticize the framework code — demonstrate what replaces it and why.

### 5. Offer next steps

After the report, prompt the user with actionable options based on what was found. Examples:

- "Want me to fix the hardcoded colors and add tokens to `:root`?"
- "Want me to move the inline `<style>` block to an external stylesheet?"
- "Want me to generate the Web XP-compliant version of this component?"
- "Want me to tackle these one at a time, or apply all fixes at once?"

Tailor the prompts to the specific findings. Do not offer generic options — reference the actual violations and opportunities from the report. If the review found nothing, say so and skip this step.
