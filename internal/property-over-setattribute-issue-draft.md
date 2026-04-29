# Draft Issue: Prefer Properties over setAttribute

## Summary

Add a JavaScript rule: prefer DOM properties over `setAttribute`, and
use `Object.assign` to set multiple properties at once. Properties
take typed values directly; `setAttribute` is a string-only fallback
for cases where no property exists.

## Proposed entry

> **Prefer Properties over `setAttribute`**
>
> Set DOM state through properties, not `setAttribute`. Properties
> take typed values directly — `disabled = true` instead of
> `setAttribute('disabled', '')`, `tabIndex = -1` instead of
> `setAttribute('tabindex', '-1')`. `setAttribute` is the fallback
> only when no property exists: custom attributes, most SVG
> attributes, and some ARIA attributes.
>
> For multiple values on the same element, use `Object.assign`.
>
> ✅
> ```js
> Object.assign(el, {
>   id: 'save',
>   className: 'btn primary',
>   textContent: 'Save',
>   disabled: true,
> });
> el.dataset.action = 'save';
> ```
>
> ❌
> ```js
> el.setAttribute('id', 'save');
> el.setAttribute('class', 'btn primary');
> el.setAttribute('disabled', '');
> el.textContent = 'Save';
> el.setAttribute('data-action', 'save');
> ```
>
> **Exceptions.** Use `setAttribute` for: `data-*` attributes set by
> a computed name (otherwise prefer `dataset`); custom attributes
> with no property form; SVG attributes without property mirrors;
> ARIA attributes whose property form is not in the supported
> browser baseline.
>
> When `setAttribute` is the right tool and multiple values are
> going on the same element, batch them via `Object.entries` instead
> of repeating the call:
>
> ✅
> ```js
> markerEl.id = markerId;
> Object.entries({
>   markerWidth: '8',
>   markerHeight: '6',
>   refX: '8',
>   refY: '3',
>   orient: 'auto',
> }).forEach(([k, v]) => markerEl.setAttribute(k, v));
> ```
>
> ❌
> ```js
> markerEl.setAttribute('id', markerId);
> markerEl.setAttribute('markerWidth', '8');
> markerEl.setAttribute('markerHeight', '6');
> markerEl.setAttribute('refX', '8');
> markerEl.setAttribute('refY', '3');
> markerEl.setAttribute('orient', 'auto');
> ```

## Placement

**Language Rules → JavaScript.** A JS-level preference about DOM API
usage, not a structural pattern. Cross-link from Template and
cloneNode, since `cloneNode` plus per-instance assignment is a
primary site where this rule fires.

## Acceptance Criteria

- New entry added under Language Rules → JavaScript.
- Rule states the property-first preference and names the exceptions
  (custom attributes, SVG, unreflected ARIA, computed data names).
- Includes the `Object.assign` form for multi-property assignment.
- Includes the `Object.entries` batching form for the `setAttribute`
  exception case.
- Cross-linked from Template and cloneNode.

## Related

- Pairs with Template and cloneNode (per-instance assignment site).
- Pairs with Semantic Markup (#47) — the rule applies after the
  decision to construct an element at all.
