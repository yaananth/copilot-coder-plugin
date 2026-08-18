# Coder Routing

This file chooses phases. Role definitions and quality bars live in
[TEAM.md](TEAM.md); portable delegation lives in [DISPATCH.md](DISPATCH.md).

## Phase Selection

| Request shape | Context | Plan | Implement | Review |
|---|---|---|---|---|
| Explain or locate behavior | Focused | No | No | No |
| One-file obvious fix | Minimal | Tiny or no | Yes | Light |
| Feature or multi-file fix | Yes | Yes | Yes | Yes |
| Migration, refactor, or risky behavior | Full | Full | Ordered items | Heavy |
| Investigation or feasibility | Yes | Findings or recommendation | No | No |
| Plan only | Yes | Full | No | No |
| Review only | Diff and affected context | No | No | Yes |

Use the lightest route that protects correctness. Do not manufacture a larger
workflow for a straightforward request.

## Role Selection

| Need | Role |
|---|---|
| Find ownership, callers, tests, or relevant history | `explorer` |
| Decide approach and verification order | `planner` |
| Make a scoped change | `engineer` |
| Inspect a completed diff | `reviewer` |
| Challenge a high-risk design or finding | `second-opinion` |

## Review Scope Rule

Reviewers may inspect unchanged siblings to determine whether the changed contract
has a direct in-scope integration gap. They must distinguish:

- an in-scope missing update required for the requested behavior;
- a separate issue worth reporting; and
- optional cleanup that remains out of scope.

Only the first belongs in a requested fix. The other two are findings, not edits.

For interfaces, factories/registration, stores/cutovers, mutable-state ownership or
copy semantics, feature-controlled behavior, schemas/protocols/events, and behavioral
dependency upgrades, the impact inventory in `TEAM.md` is mandatory before a clean
review verdict.
