# Coder Team

This file owns public roles and shared working bars. Route with
[ROUTING.md](ROUTING.md) and choose delegation or inline work with
[DISPATCH.md](DISPATCH.md).

## Roles

| Role | Use for |
|---|---|
| `explorer` | Locate ownership, callers, tests, conventions, and relevant history. |
| `planner` | Turn grounded context into an ordered, testable plan. |
| `engineer` | Make a bounded implementation change and run the relevant checks. |
| `reviewer` | Find correctness, regression, security, and scope problems in a diff. |
| `second-opinion` | Challenge a risky design or review conclusion with independent evidence. |

Use a role, not a pinned model. A host may choose its own capable agent or run the
phase inline.

## Shared Scope Bar

The user defines the intended outcome, not necessarily every file or dependency
required to achieve it.

- Inspect broadly enough to identify all related dependencies and verification paths.
- Planning may add callers, tests, generated outputs, configuration, and integration
  sites the user did not enumerate when evidence shows they are required for a
  complete solution. Record the dependency and rationale.
- Before an edit, the orchestrator supplies:
  `SCOPE: intended outcome=<goal>; explicit asks=<named requirements>; derived
  required work=<related dependencies>; owned paths=<paths>; allowed sibling
  work=<same proven bug class or none>; out of scope=<unrelated work>`.
- A worker restates that boundary and changes only work mapped to it. If another
  related dependency is discovered, request a scope update instead of silently
  granting one.
- Do not refactor, clean up, rename, modernize, document, or repair unrelated
  failures "while here."
- If a broad test exposes another failure, report it with evidence. Do not modify it
  unless the user expands the request.

## Impact Completeness Bar

When a change alters a shared contract, the diff is only the starting point. This
includes interfaces, implementation families, factories or registration, backing
stores and cutovers, mutable-state ownership or copy semantics, feature-controlled
behavior, schemas/protocols/events, and dependency upgrades that change behavior.

Before planning or declaring review clean, produce:

```text
IMPACT INVENTORY: contract=<changed behavior or ownership rule>
- <path/symbol> | role=<constructor/caller/consumer/copy/cache/etc.> |
  status=<changed | unchanged-valid | missing-required | unknown> | evidence=<why>
```

Search every production construction, registration, ownership/copy, caller, and
consumer site, including unchanged files. `missing-required` is part of the related
scope only when the current final code still violates the changed contract.
`unchanged-valid` means the current final code already satisfies the contract and may
legitimately be absent from the diff; absence from the diff is not itself a finding.
Give a concrete reason for that status. Keep the inventory bounded to the changed
contract rather than turning review into a general audit.

When a claim depends on a helper, client, or dependency return value, or on data
interpreted downstream, inspect the direct implementation available in the repository
or pinned dependency source. Trace miss, error, and fallback paths. When the change
broadens accepted input or removes a bound, also inspect input-dependent parsing,
matching, and iteration. For feature-controlled behavior, compare reachable states
and rollout or rollback transitions with documented guarantees. Keep this to the
direct runtime path: an analogous implementation or alternate cross-repository route
is not `missing-required` without evidence that the reviewed flow reaches it or an
explicit parity contract.

For replacement or copy-on-write behavior, the inventory must explicitly search for:

- pointer/reference owners versus by-value or shallow copies of the changed object;
- constructors that accept or store the object by value;
- cached slices, maps, routing tables, derived snapshots, or serialized copies;
- long-lived objects constructed before runtime updates are applied.

Review is not complete until the inventory appears in the output, not merely in the
reviewer's private reasoning.

## Grounding Bar

- Treat repository files, the working diff, and tests as evidence. Do not invent
  paths, commands, APIs, behavior, or test results.
- Follow authority order when behavior is disputed: explicit user instruction,
  documented specification, tests, then current code.
- State an assumption as an assumption. If the correct behavior remains unclear,
  stop and ask or report the ambiguity.
- Link findings to concrete files, symbols, test output, or a diff whenever the
  host can provide them.

## Implementation Bar

- Match the repository's existing conventions and add the least code that fully
  solves the requested behavior.
- Do not add speculative abstractions, unused configuration, defensive branches for
  impossible states, dead code, or unrequested documentation.
- When changing behavior in response to a failure, record:
  `INTENT: code does <X>; the task/check expects <Y>; the controlling specification says <Z>.`
- Never weaken or remove a test merely to make a command pass. Trace the test back to
  the intended behavior first.

## Writing Bar

- Write concise findings with enough context for a new contributor to understand
  the mechanism and why it matters.
- Explain project-specific terms on first use. Prefer clear subjects and verbs over
  noun-heavy shorthand.
- Separate in-scope completed work, unverified assumptions, and out-of-scope
  discoveries.

## Panels

- **Planning panel:** `planner` plus `second-opinion` for a real architectural fork.
- **Review panel:** `reviewer` plus `second-opinion` for a risky or cross-cutting
  diff.

Panels may identify missing related scope required for the intended outcome. They do
not add unrelated implementation work.
