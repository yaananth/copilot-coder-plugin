---
name: coder-review
description: >
  Review a coding change for correctness, regressions, verification gaps, and
  scope discipline. Reports prioritized findings and does not make edits unless the
  user explicitly asks to address them.
---

# Coder Review

Review target: $ARGUMENTS

Read `../coder-code/TEAM.md`, `../coder-code/ROUTING.md`, and
`../coder-code/DISPATCH.md`. Use a generic `reviewer` task only when the host makes
one available; otherwise perform this review inline.

For plugin-load observability, the final review summary must begin with this exact
line:

```text
COPILOT_CODER_REVIEW_PROFILE: semantic-impact-v1
```

## Mandatory Pre-Findings Artifact

Before ordinary findings:

1. Name the changed contract and the concrete symbols/types that implement it.
2. Search those symbols/types across the repository, not only the diff.
3. For replacement or copy-on-write behavior, search explicitly for value or shallow
   copies, dereferences passed to constructors, struct/object fields stored by value,
   cached derived collections, snapshots, and long-lived owners created before
   runtime updates.
4. Output:

```text
IMPACT SEARCH: symbols=<...>; searches=<...>; candidate sites=<...>
IMPACT INVENTORY: contract=<...>
- <path/symbol> | role=<...> |
  status=<changed | unchanged-valid | missing-required | unknown> | evidence=<...>
```

If no impact trigger exists, output `IMPACT INVENTORY: not triggered — <reason>`.
Do not proceed to the final findings without this artifact.

Status is about the current final code, not whether a file appears in the diff:

- `unchanged-valid` means an unchanged site already satisfies the changed contract.
  Do not flag it merely because the diff did not touch it.
- `missing-required` means the current final code still violates the contract and the
  reviewed change is incomplete without updating that site.

## Review Method

1. Establish the intended outcome, explicit asks, and any evidence-backed derived
   requirements. Inspect the diff, touched tests, and the nearest owning code.
2. Trace changed behavior to direct callers, contracts, configuration, and tests.
   Inspect unchanged siblings when needed to determine whether a required integration
   site was missed.
   When the diff changes a shared contract listed in `TEAM.md`, produce the bounded
   `IMPACT INVENTORY` before ordinary findings. Search every production construction,
   registration, ownership/copy, caller, and consumer site, including unchanged files.
   A `missing-required` site is actionable; an unexplained `unknown` blocks a clean
   completeness verdict. An unchanged site that already uses the required path is
   `unchanged-valid`, not a stale-diff finding.
   For replacement or copy-on-write changes, explicitly search for value/shallow
   copies, constructors that store the object by value, cached derived collections,
   snapshots, and long-lived objects created before runtime updates.
3. Separate missing related integration required for the intended outcome from a
   separate bug or optional cleanup. Do not ask for unrelated improvement merely
   because it is visible.
4. Verify claims against code, tests, or command output. Do not infer a passing check
   from an edited assertion or a green-looking diff. Claim that a command, test, or
   reproduction ran only when the current review actually executed it and observed the
   result; otherwise label the conclusion as static reasoning.
5. Report only actionable findings, ordered by severity. If no finding is supported,
   say so and name remaining verification gaps.

## Finding Format

Place the mandatory impact artifact before findings:

```text
IMPACT INVENTORY: contract=<changed behavior or ownership rule>
- <path/symbol> | role=<constructor/caller/consumer/copy/cache/etc.> |
  status=<changed | unchanged-valid | missing-required | unknown> | evidence=<why>
```

```markdown
### [P<severity>] <short title>

<what fails, under what condition, and why it matters>

Evidence: <file/symbol/test/diff reference>
Suggested in-scope fix: <specific correction>
```

Close with a short scope verdict:

```text
Scope verdict: <complete and contained | missing related required integration | over-broad>
Impact inventory: <not triggered | complete | unknown sites remain>
Out-of-scope observations: <none or separate follow-ups>
Verification gaps: <none or exact gaps>
```

Do not edit code as part of review unless the user explicitly changes the request to
ask for fixes. When fixes are authorized, edit only `missing-required` sites accepted
into the finalized scope or sibling work explicitly allowed by that scope. Report
other same-pattern discoveries as follow-ups.
