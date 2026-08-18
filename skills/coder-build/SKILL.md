---
name: coder-build
description: >
  Build a focused, reviewable context bundle for a coding task. It explores and
  curates relevant files but does not plan, implement, or review.
---

# Context Builder

Task: $ARGUMENTS

Produce a compact context bundle and stop. This skill is for identifying the files,
tests, conventions, and dependencies a later planning or implementation step needs.

Read the shared bars in `../coder-code/TEAM.md`. Use `explorer` helpers only if the
host provides a generic task helper; otherwise inspect the repository inline.

## Bundle Format

```markdown
# Context bundle: <task>

## Scope boundary
- Intended outcome:
- Explicit asks:
- Candidate derived requirements and rationale:
- Likely owned paths:
- Explicit exclusions:

## Impact inventory (when a shared contract changes)
- Contract:
- <path/symbol> | role=<...> | status=<changed/unchanged-valid/missing-required/unknown> | evidence=<...>

## Repository orientation
- Stack and commands:
- Relevant local guidance:

## Files and why
- <path> - full, slice, or symbol summary - <reason>

## Tests and verification
- <existing tests and commands>

## Open questions
- <only unresolved facts that change the next step>
```

## Rules

- Curate rather than dump: include the few files that directly answer the task.
- Use full files only when needed. Prefer focused slices or symbol summaries for
  adjacent context.
- Inspect siblings to map impact. Mark evidence-backed dependencies required for a
  complete solution as candidate derived scope; label merely adjacent code as context,
  not permission to edit it.
- For interfaces, factories, stores, ownership/copy behavior, feature-controlled
  behavior, schemas/protocols/events, or behavioral dependency upgrades, inventory
  every production site, including unchanged files.
- Record relevant tests and any pre-existing failures without attempting repairs.
- Stop after the bundle. Do not plan, implement, or review.

Write the bundle to a session artifact only if the host supports a durable workspace;
otherwise return it directly.
