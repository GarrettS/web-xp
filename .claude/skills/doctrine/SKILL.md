---
name: doctrine
description: "Load code standards as governing constraints for the current session. Reads code-guidelines.md and code-philosophy.md, summarizes active constraints, and enforces them for the remainder of the conversation."
---

# Doctrine — Inline Reference

Load the doctrine into the current session with the correct split between governing rules and explanatory context.

## Procedure

### 1. Locate and read doctrine files

Read `${CLAUDE_SKILL_DIR}/../code-guidelines.md` — governing standards: principles, patterns, language rules, formatting.

Read `${CLAUDE_SKILL_DIR}/../code-philosophy.md` — explanatory context: how and why the doctrine works, historical framing, and supporting examples.

### 2. Summarize active constraints

After reading, list the key constraints now governing the session. Draw the governing constraints from the CG, not the CP. Include at minimum: Fail-Safe, Module Cohesion, Shared Key, Event Delegation, Active Object, Ancestor Class, Design Tokens, Ubiquitous Language, and DOM-Light. State each with a one-line description drawn from the CG.

### 3. Apply for the session

For the remainder of this conversation:
- Evaluate all code written or reviewed against these constraints
- Flag violations by pattern name
- When proposing code, follow the doctrine's patterns
- Use `code-philosophy.md` to explain the reasoning behind the rules, not to invent new rules
- When the doctrine conflicts with a request, state the tension and ask
- On commit, remind to run pre-commit checks and re-read the CG
