---
name: doctrine-review
disable-model-invocation: true
allowed-tools: Read, Grep
---

# Doctrine Review — Evaluate Any Code Against the Doctrine

Review code the user provides — pasted snippets, file paths, or URLs — against code-guidelines.md. Unlike doctrine-check (which audits git diffs), this works on any code from any source.

## Procedure

### 1. Load the doctrine

Read code-guidelines.md from the project root or .doctrine/ subdirectory. If not found, report: "No doctrine files found. Run /doctrine-init first."

### 2. Receive code to review

The user provides code in one of these forms:
- Pasted directly in the conversation
- A file path to read
- A description of a pattern to evaluate

If the user provides a React component or framework code, evaluate both the original and what the doctrine-aligned vanilla equivalent would look like.

### 3. Analyze against doctrine patterns

For each concern in the code, assess against the doctrine patterns defined in the Patterns and Fail-Safe sections of code-guidelines.md. Use the same pattern recognition list as doctrine-check: Event Delegation, Active Object, Shared Key, Ancestor Class, Dispatch Table, Fail-Safe, CSS over JS, hidden attribute, Extract Shared Logic, Template and cloneNode.

Also assess against Language Rules: naming conventions, module cohesion, identifier accuracy, guard clauses, DOM content, string concatenation.

### 4. Report findings

For each finding, report the pattern name, whether the code violates or could benefit from it, and the doctrine-aligned alternative.

When reviewing framework code, show the vanilla equivalent side by side. Do not just criticize the framework code — demonstrate what replaces it and why.

### 5. If asked, generate the refactored version

On request, produce the doctrine-compliant version of the code. Follow all CG rules: named patterns, fail-safe error handling, semantic naming, no framework dependencies.
