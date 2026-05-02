# Doctrine Restructure Prompt

Use this prompt when restructuring an existing doctrine entry into explicit Markdown structure.

This workflow supports the doctrine-family structure work described in issue `#33`.
The output should produce explicit structured examples in the style now used for `Fail-Safe` and `Ubiquitous Language` in `code-guidelines.md`.

## Prompt

You are helping restructure an existing doctrine entry in `code-guidelines.md` without rewriting its substance unless necessary.

Issue context:

- `#33` defines the rough family-level structure for doctrine, especially `Design Principles`.
- The goal is explicit Markdown structure that agents can parse directly rather than infer from prose order.

Your task:

1. Read the supplied doctrine entry as it exists now.
2. Determine what the rule does.
3. Determine which doctrine family it belongs to.
4. Determine what structure best preserves that function.
5. Map the existing text into explicit Markdown sections.
6. Do not force every possible section to exist if the rule does not actually contain that material.
7. Prefer preserving the existing prose.
8. Only suggest wording changes when:
   - the current wording is materially weak,
   - the current wording contradicts the doctrine's own rule,
   - or explicit structure exposes a gap that needs a short bridging statement.

For `Design Principles`, use this explicit section vocabulary from `#33` where it fits:

- Governing Statement
- Core Distinctions
- Example
- What This Rules Out
- Allowed Exception Shape
- Reference Examples
- Related Rules / Related Sections

Use the sections in that order when they are present.
Do not force every rule to use every section. Omit a section when the source entry does not actually contain that material.

Important constraints:

- Do not invent examples unless asked.
- Do not paraphrase aggressively.
- Do not compress distinct categories into one summary statement if the source text keeps them separate.
- Do not force content into a slot if it does not fit cleanly; flag the mismatch instead.
- If a section should be omitted because the rule does not contain that material, say so.
- Preserve heading levels relative to the surrounding doctrine. If the rule is a `###` entry, its substructure is `####`; do not drift.
- The output must make the structure explicit in Markdown. Do not leave the organization implicit in prose order alone.

Output format:

## What This Rule Does

State the function of the rule in 1-3 short paragraphs.

## Recommended Family

Name the doctrine family and explain why.

## Recommended Structure

List only the sections that this rule should actually have, in the explicit Markdown order you recommend.

## Block Mapping

Map the existing source material into those sections. Quote short lead-ins or describe blocks precisely enough to identify them.

## Tensions / Misfits

List any parts of the current rule that do not fit the family structure cleanly.

## Structure-Only Rewrite

Provide a Markdown rewrite that:
- adds explicit subheads
- preserves existing prose as much as possible
- omits empty sections
- uses `[[...]]` placeholders only if a structural slot is clearly needed but the current text does not provide it
- produces an explicit structured example comparable to the live `Fail-Safe` / `Ubiquitous Language` examples

## Notes on Wording

Only include this section if there are specific wording problems worth revising later.

## Usage

Paste the live doctrine entry after the prompt under a heading like:

`## Source Entry`

Then ask for the restructuring analysis and structure-only rewrite.
