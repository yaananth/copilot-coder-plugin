---
name: coder-code
description: >
  Portable end-to-end coding workflow. Triage a request, gather focused context,
  make a scoped plan when needed, implement, verify, and review. Uses generic task
  helpers when available and otherwise runs phases inline.
---

# Coder Orchestrator

Task: $ARGUMENTS

Use this skill for non-trivial implementation, debugging, investigation, planning,
or review requests. Read [ROUTING.md](ROUTING.md), [TEAM.md](TEAM.md), and
[DISPATCH.md](DISPATCH.md) before choosing the flow.

## Workflow

1. **Triage.** State the selected phases in one line. For a question, gather focused
   evidence and answer; do not invent implementation work.
2. **Scope.** Translate the user's intended outcome into the `SCOPE:` line from
   `TEAM.md`. Add evidence-backed related requirements that are needed for a complete
   solution, even when the user did not enumerate them. Broad discovery is allowed;
   unrelated editing is not.
3. **Context.** For a multi-file, unclear, or risky change, run `coder-build` or
   perform its focused equivalent. Identify owners, callers, tests, conventions, and
   direct dependencies.
   When a shared contract changes, require the `IMPACT INVENTORY` from `TEAM.md`;
   changed files alone are not sufficient context.
4. **Plan.** For more than an obvious single edit, run `coder-plan` or create a short
   ordered plan with done-when criteria and tests.
5. **Implement.** Use the `engineer` role through a generic task helper when one is
   available, otherwise work inline. Keep one writer for overlapping files.
6. **Verify.** Run the narrowest relevant checks first, then broader checks when the
   repository makes them useful. Reconcile shared-contract work against the impact
   inventory, then report actual results, including unrelated failures.
7. **Review.** Run `coder-review` or apply its checklist. If review identifies missing
   related integration required for the intended outcome, update scope and complete
   it. Do not absorb unrelated cleanup.

## Delegation

Use generic task helpers only under the portable contract in [DISPATCH.md](DISPATCH.md).
Do not assume a helper, model selector, session API, remote sandbox, project registry,
or branch manager exists. If unavailable, continue inline.

## Closeout

Report:

- requested outcome and scope boundary;
- changed files and why each change was required;
- checks run and their real result;
- review result;
- assumptions, blockers, and separately reported out-of-scope findings.
