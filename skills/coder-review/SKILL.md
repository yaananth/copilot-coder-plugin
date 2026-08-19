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
4. When the large-review threshold below is met, output `REVIEW MANIFEST` with
   explicit bounded batches before the impact inventory. Use at least two batches
   when there are at least two candidate sites or changed-file review units; never
   fabricate or duplicate candidates merely to create another batch. This applies
   even when one reviewer processes every batch inline and serially; batching tracks
   coverage and is not delegation.
5. Output:

```text
IMPACT SEARCH: symbols=<...>; searches=<...>; candidate sites=<...>
IMPACT INVENTORY: contract=<...>
- <path/symbol> | role=<...> |
  status=<changed | unchanged-valid | missing-required | unknown> | evidence=<...>
```

When the contract is feature-controlled, also output:

```text
FEATURE TRANSITIONS: states=<reachable combinations>; rollout=<path>;
rollback=<path>; guarantees=<matched or violated, with evidence>
```

If no impact trigger exists, output `IMPACT INVENTORY: not triggered — <reason>`.
Do not proceed to the final findings without this artifact.

Status is about the current final code, not whether a file appears in the diff:

- `unchanged-valid` means an unchanged site already satisfies the changed contract.
  Do not flag it merely because the diff did not touch it.
- `missing-required` means the current final code still violates the contract and the
  reviewed change is incomplete without updating that site.

## Large Review Batches

Use this protocol when the impact search finds 8 or more candidate sites, the diff
changes 20 or more files, multiple shared contracts changed, or the candidates do not
fit in one focused pass:

1. Output `REVIEW MANIFEST: batches=<groups>; reviewed=<sites>; remaining=<sites>;
   unknown=<sites>`.
2. Partition candidate sites or changed-file review units into bounded batches for
   construction/registration, callers/consumers, ownership/copies/caches, feature
   transitions, and tests/dependency behavior. Subdivide any category that is still
   too large for one focused pass.
3. Process independent batches in parallel only when a generic helper is available;
   otherwise process the same batches serially.
   Never replace required serial batches with one grouped inventory range merely
   because all candidates fit in the current context.
4. Update the manifest after each batch and reconcile duplicate or conflicting
   findings before the final result.
5. Do not issue a clean completeness verdict while a required site remains. If a
   context, tool, or time limit prevents completion, classify the remaining sites as
   `unknown` and report the exact verification gap.

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
   For feature-controlled behavior, enumerate reachable flag combinations and the
   rollout or rollback transitions promised by code or documentation. Static
   combination tests do not by themselves prove a transition or fallback invariant.
   For every supported enabled state, apply each independent disable or kill-switch
   transition and state the resulting behavior. A fallback guarantee is satisfied
   only when it holds from every supported pre-state or the required pre-state
   invariant is explicit and enforced.
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
5. Report only actionable findings, ordered by severity. Before elevating an
   observation to a finding, name the currently reachable call, input, or state that
   fails and the violated contract or concrete consequence. A risky API shape,
   hypothetical future misuse, or maintainability preference without a current
   failing path belongs in `Out-of-scope observations`, not the findings list. Do not
   assign a `P` severity to an `unknown` or unverified site; keep it in verification
   gaps until the affected runtime path is proven. If no finding is supported, say so
   and name remaining verification gaps.

## Finding Format

Place the mandatory impact artifact before findings:

```text
IMPACT INVENTORY: contract=<changed behavior or ownership rule>
- <path/symbol> | role=<constructor/caller/consumer/copy/cache/etc.> |
  status=<changed | unchanged-valid | missing-required | unknown> | evidence=<why>
```

For a feature-controlled contract, place the mandatory `FEATURE TRANSITIONS` line
immediately after the inventory.

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
