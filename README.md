# copilot-coder

`copilot-coder` is a portable GitHub Copilot plugin for coding work that benefits
from a little structure: gather the right context, make a scoped plan, implement,
verify, and review.

It intentionally does not depend on private models, internal services, remote
sandboxes, or a particular Copilot host surface. When a generic task helper is
available, the workflow can delegate independent work; otherwise it runs the same
phases in the current session.

## Skills

- `/copilot-coder:coder-code` - full coding workflow and phase triage.
- `/copilot-coder:coder-build` - context bundle only; no code changes.
- `/copilot-coder:coder-plan` - implementation-ready plan only.
- `/copilot-coder:coder-review` - diff review and scope-aware closeout.
- `/copilot-coder:coder-team` - roles, panels, and shared working rules.

The selectable agents mirror these skills. Choose `coder-orchestrator` for the
normal end-to-end flow, or choose a phase agent when that is all you need.

## Install

Install with a Copilot CLI build that supports plugins:

```bash
copilot
/plugin install yaananth/copilot-coder-plugin
exit
copilot
```

## Use

```text
/copilot-coder:coder-code add a request timeout to the API client
/copilot-coder:coder-build map the files needed for a billing retry change
/copilot-coder:coder-plan split the cache migration into safe work items
/copilot-coder:coder-review review the current branch
/copilot-coder:coder-team show the review panel
```

The central rule is complete but bounded delivery: treat the user's intended outcome,
not their literal file list, as the scope. Derive required callers, configuration,
tests, generated artifacts, and integration points when repository evidence shows
they are needed. Do not turn adjacent cleanup or a different failing feature into
part of the task.

To apply the same completeness rules to native GitHub Copilot code review:

1. Copy [`templates/REVIEW.md`](templates/REVIEW.md) to the consumer repository
   root as `REVIEW.md`.
2. Merge [`templates/copilot-instructions.md`](templates/copilot-instructions.md)
   into the consumer repository's `.github/copilot-instructions.md`. Create that
   file if it does not exist; do not overwrite unrelated repository instructions.

The bridge tells native code review to apply `/REVIEW.md`. Keep both templates
aligned with `skills/coder-review/SKILL.md`.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for local checks and
[eval/ab/README.md](eval/ab/README.md) for the paired control-versus-plugin
evaluation harness.

## Publication Status

This repository is private while behavior, provenance, and redistribution rights are
validated. No public license is granted yet. See [PUBLICATION_CHECKLIST.md](PUBLICATION_CHECKLIST.md)
and [NOTICE](NOTICE).
