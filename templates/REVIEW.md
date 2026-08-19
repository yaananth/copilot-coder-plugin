# Code Review Instructions

Review the requested outcome, not only the changed lines.

Before ordinary findings, identify the changed contract and symbols and use
repository-wide searches to find construction, ownership, caller, and consumer sites.

## Scope

- Treat the user's intended outcome as the boundary. Include related callers,
  configuration, tests, generated artifacts, and integration points when they are
  required for a complete solution.
- Do not request unrelated cleanup, refactors, modernization, documentation, or fixes
  for separate pre-existing failures.
- Flag unrelated edits already present in the diff as scope overreach.

## Semantic Impact Completeness

When a pull request changes an interface, implementation family, factory or
registration path, backing store or cutover, mutable-state ownership or copy
semantics, feature-controlled behavior, schema/protocol/event, or behavioral
dependency contract, do not treat the changed-file list as the full review scope.

Build a bounded internal inventory:

```text
IMPACT INVENTORY: contract=<changed behavior or ownership rule>
- <path/symbol> | role=<constructor/caller/consumer/copy/cache/etc.> |
  status=<changed | unchanged-valid | missing-required | unknown> | evidence=<why>
```

Search every production construction, registration, ownership/copy, caller, and
consumer site, including unchanged files.

For replacement or copy-on-write behavior, explicitly search for pointer/reference
owners, by-value or shallow copies, constructors that store the object by value,
cached slices/maps/routing tables or snapshots, and long-lived objects built before
runtime updates.

- `missing-required` is an actionable finding because the pull request is incomplete.
- `unknown` is a verification gap and blocks a clean completeness verdict.
- `unchanged-valid` means the current final code already satisfies the changed
  contract and may legitimately be absent from the diff; it requires a concrete
  reason. Do not flag an unchanged-valid site merely because the diff did not touch it.

Keep this pass tied to the changed contract. It is not a general audit.

When the review finds 8 or more candidate sites, the diff changes 20 or more files,
multiple shared contracts changed, or the candidates do not fit in one focused pass,
divide the inventory into bounded batches for construction/registration,
callers/consumers, ownership/copies/caches, feature transitions, and
tests/dependency behavior. Subdivide any oversized category. Process independent
batches in parallel only when helpers are available; otherwise process them serially.
Reconcile duplicate or conflicting findings across batches. Treat any unprocessed
candidate as `unknown`, not as a defect.

Do not require a separate overview comment, visible inventory, or custom output
format.

## Findings

Report concrete correctness, regression, security, verification, and completeness
issues with exact file/symbol evidence and what breaks. Reject speculative risks and
optional improvements. If no actionable issue is supported, say so and list any
remaining verification gaps. Claim that a command, test, or reproduction ran only
when it was actually executed during this review; otherwise describe the conclusion
as static reasoning.
