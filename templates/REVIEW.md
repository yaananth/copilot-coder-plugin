# Code Review Instructions

Review the requested outcome, not only the changed lines.

Before ordinary findings, name the changed contract and symbols, show the
repository-wide searches used to find construction/ownership/caller/consumer sites,
and emit the impact inventory. If the semantic-impact trigger does not apply, say why.

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

Produce a bounded inventory:

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
The review output must include the inventory before ordinary findings.

## Findings

Report concrete correctness, regression, security, verification, and completeness
issues with exact file/symbol evidence and what breaks. Reject speculative risks and
optional improvements. If no actionable issue is supported, say so and list any
remaining verification gaps. Claim that a command, test, or reproduction ran only
when it was actually executed during this review; otherwise describe the conclusion
as static reasoning.
