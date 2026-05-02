# Editorial Rules — initial skeleton

Initial draft of `editorial-rules.md` per the editor-filter issue. These rules are Web XP's own. References for consideration: WHATWG, MDN, and the Google Developer Documentation Style Guide.

Web XP doctrine style is concise, direct, and precise.

## Authoritative references

*To be filled per #56 — authoritative spec references for web-platform terminology (WHATWG, ECMA-262, W3C CSS, RFC 2119, etc.) and terminology priming.*

## Person

- **Doctrine and rule prose** — no first or second person. State the rule.
- **Contributor instructions** — second person (*"you"*). Tell the reader what to do.

## Voice and tense

- Active voice over passive.
- Present tense.

## Punctuation

### Logical punctuation

Punctuation goes outside quotation marks when not part of the quoted material; only original-text punctuation belongs inside the quotes.

> **Example of synthesis.** Standard in WHATWG specs, Wikipedia, Linux kernel docs, and most engineering style guides. The Google Developer Documentation Style Guide uses American journalistic style (comma inside even when not quoted); Web XP departs from it on this point. Where authorities conflict, name the choice and the reason — don't pretend one authority covers everything.

## Words to avoid

Generally avoid these words; prefer stronger alternatives or restructure the sentence.

- **Patronizing** — *obviously*, *simply*, *easy*, *just*.
- **Filler / defensive intensifiers** — *actually*, *really*, *real*.

## Meta-mode-leakage patterns

- **Self-references** — *"this issue"*, *"the issue scope"*, *"this issue ships"*. Legitimate use: dependency notes (*"this depends on #56"*) and explicit scope statements.
- **Scope defenses** — *"not narrowed to X"*, *"not just Y"*, *"the broader Z"*. Often defensive positioning against drafting feedback.
- **Revision narration** — *"the point of the pilot is"*, *"what this demonstrates"*. Often explains what the artifact does instead of doing it.
- **Instructional leaks** — drafting instructions to the producing agent transcribed as artifact content.
- **Meta-ACs** — acceptance criteria about what's in the artifact body rather than what gets delivered.
- **Surface-vs-target conflations** — listing the file where a rule lives (delivery surface) as if it were an artifact class the rule reviews (review target). Example: writing *"the priming applies to `CODEX.md`"* when the priming actually applies to issue drafts, doctrine, and contributor docs — `CODEX.md` is the file where the priming text lives, not an artifact class being reviewed.

## Format

Each rule lands in a per-topic section with **Recommended** / **Not recommended** entries (Google Developer Documentation Style Guide format) and uses plain `must` / `must not` / `should` / `should not` for normative force, without RFC 2119 capitalization (per `MAINTAINERS.md`:82, RFC 2119 is reserved for tight agent operations).
