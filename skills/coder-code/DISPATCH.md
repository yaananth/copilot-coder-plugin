# Portable Dispatch

This file owns how the public plugin delegates work. It deliberately assumes only a
generic task helper may exist; it does not depend on a project registry, session API,
worktree manager, remote execution surface, or model-setting API.

## Decide Once

1. Read [ROUTING.md](ROUTING.md) to select the needed phases.
2. Read [TEAM.md](TEAM.md) to select the role and shared bars.
3. If a generic `task` or sub-agent helper is available, delegate independent units.
   Otherwise, run the selected phases inline in the current session.

Do not stop because delegation is unavailable. The workflow remains useful inline.

## Worker Brief

Every delegated unit receives:

```text
You are a worker, not an orchestrator. Complete this one bounded job and report
back. Do not start another copy of the full workflow or delegate named roles.

SCOPE: intended outcome=<goal>; explicit asks=<requirements>; derived required
work=<related dependencies>; owned paths=<paths>; allowed sibling work=<same proven
bug class or none>; out of scope=<unrelated work>.

Treat that boundary as authoritative. Restate it before editing and request an update
if another related dependency is required; do not widen it yourself. Ground claims in
repository evidence. Report changed files, checks actually run, remaining uncertainty,
and out-of-scope findings separately.
```

For work longer than a couple of steps, ask the worker to keep a small visible task
list if the host offers one.

## Parallelism

Delegate in parallel only when the units are independent and will not edit the same
files. Good examples are a caller inventory plus a test inventory, or independent
review angles. Serialize work when a later step needs the earlier result or two
writers would overlap.

For one coherent change, prefer one writer. A task helper is not permission to create
unnecessary branches, sessions, or copies of the task.

## Inline Fallback

When no helper exists:

1. Perform the same discovery, plan, implementation, verification, and review steps
   yourself.
2. Keep the scope statement in the response or working notes.
3. Say which checks were actually run and which were unavailable.

Never claim that a worker, isolated environment, or external verification performed a
step that ran inline or did not run.
