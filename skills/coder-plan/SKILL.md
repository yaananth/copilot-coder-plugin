---
name: coder-plan
description: >
  Produce a grounded implementation plan for a coding task. Maps direct seams,
  defines scoped work items and verification, but does not implement the plan.
---

# Coder Plan

Task: $ARGUMENTS

Create an implementation-ready plan and stop. Read `../coder-code/TEAM.md` for the
scope, grounding, and writing bars. Use an `explorer` or `second-opinion` helper only
when a generic task helper is available and the question warrants it.

## Planning Steps

1. State the intended outcome and explicit asks.
2. Map the seams: source owner, callers, configuration, tests, and externally visible
   behavior. Add evidence-backed derived requirements when the outcome would otherwise
   be incomplete, and state the rationale.
3. When a shared contract changes, build the impact inventory from `TEAM.md`. Every
   `missing-required` or unexplained `unknown` site becomes a work item or open question.
4. Resolve intent from user instruction, documentation, tests, and current code in
   that order. Mark unresolved behavior as an open question.
5. Write ordered work items. Each item names files or symbols, the exact behavior,
   direct fallout, and done-when verification.
6. For risky plans, ask for a second opinion on the real decision fork, then record
   the deciding evidence and mitigation.

## Output

```markdown
# Plan: <task>

## Scope
- Intended outcome:
- Explicit asks:
- Derived required work and rationale:
- Owned paths:
- Allowed sibling work:
- Out of scope:

## Approach
<short explanation of the chosen path and why>

## Impact Inventory
<when triggered: every production constructor/registration/owner/copy/caller/consumer and status>

## Work Items
- [ ] <item>: <paths/symbols>, behavior, and verification

## Risks and Open Questions
- <grounded uncertainty only>

## Verification
- <command or observable outcome>
```

Do not implement or modify tests while planning. Broaden the literal prompt only to
the related scope required for the intended outcome; exclude optional or unrelated
improvements.
