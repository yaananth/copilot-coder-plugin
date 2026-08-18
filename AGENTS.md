# Repository Agent Instructions

This repository defines portable Copilot skills. Treat the skill text as product
behavior: a small wording change can change how a future coding task is handled.

## Scope

- The user's intended outcome is the boundary; the prompt may not enumerate every
  caller, configuration file, test, generated artifact, or integration point needed
  for a complete solution. Derive those related requirements from repository evidence
  and explain why they belong.
- Do not add cleanup, refactors, modernization, documentation, or unrelated bug
  fixes because they are nearby or because a broad test command exposes them.
- State derived required work explicitly. A caller, generated file, configuration
  change, or sibling edit is allowed when it is necessary for the intended outcome
  or is an explicitly approved same-mechanism sweep.
- Report useful out-of-scope findings separately. Do not silently include them.

## Portable Dispatch

- The public plugin must not assume a particular host application, project
  registry, session API, model, reasoning setting, remote sandbox, or private
  service.
- When a generic `task` or sub-agent helper is available, use it for independent
  research, implementation, or review work. Give each worker a self-contained
  brief and keep it a leaf.
- When no helper is available, run the same phases inline. Do not claim that
  delegation, isolation, or an external check occurred when it did not.
- Never pin a private model identifier or require model-setting persistence.

## Documentation Structure

- `skills/coder-code/ROUTING.md` owns phase selection.
- `skills/coder-code/DISPATCH.md` owns the portable task-helper-or-inline rule.
- `skills/coder-code/TEAM.md` owns roles and the shared scope, grounding,
  implementation, and writing bars.
- Keep a rule in its owning file and link to it elsewhere instead of copying it.

## Validation

- Run `python3 .github/checks.py` and `git diff --check` for documentation or
  prompt changes.
- Run the relevant fixture validation for behavior changes. The local A/B harness
  is described in [eval/ab/README.md](eval/ab/README.md); it is a small,
  non-deterministic signal, not a release gate.
- Keep the manifest's version current for a published plugin change.
