# A/B Evaluation Design

This harness compares the same coding task in two conditions:

| Arm | Setup |
|---|---|
| `control` | Copilot CLI with installed plugins isolated and no treatment plugin |
| `method` | Copilot CLI with only the staged `copilot-coder` treatment plugin and its orchestrator agent |

The scenario task and fixture are identical. `GROUND-TRUTH.md` stays out of the
agent's temporary workspace. After each run, the harness computes a diff against a
fresh pristine fixture, so changed files are measured rather than self-reported. Arm
assignment is seeded and randomized behind opaque `run-A` / `run-B` labels; the judge
does not receive the control/method mapping. Custom instructions are disabled in both
arms by default and can be enabled in both with `--with-custom-instructions`.

## Run

```bash
scripts/eval/ab.sh s7-scope-overreach
scripts/eval/ab.sh --judge auto s7-scope-overreach
scripts/eval/ab.sh --seed 42 --judge auto s7-scope-overreach
scripts/eval/ab.sh --out /tmp/copilot-coder-ab --seed 42 s7-scope-overreach
```

Use `all` to run every scenario:

```bash
scripts/eval/ab.sh all
```

The optional judge scores correct action, evidence, verification honesty, and report
quality from the task, hidden answer sheet, agent report, and harness-computed diff.
The mapping is written only after both runs to `arm-map.json`.

## Use Another Repository's Task Catalog

Keep repository-specific tasks with that repository and point the harness at them:

```bash
EVAL_SCEN_DIR=/path/to/repo/eval/copilot-coder-ab/tasks \
  scripts/eval/ab.sh --with-custom-instructions --seed 42 --judge auto task-id
```

Each task directory uses the same contract as the built-in scenarios: `task.md`,
fixture files, and a hidden `GROUND-TRUTH.md`. The
`--with-custom-instructions` flag keeps normal repository instructions enabled in
both arms, so the only intended treatment difference is the staged plugin.

## Compare Carefully

- Use the same installed Copilot CLI and default model for both arms.
- Do not add a task-specific prompt to only one arm.
- Repeat a scenario when randomness matters; one result is an observation, not proof.
- Compare the actual diff before comparing prose. A polished report cannot compensate
  for an incorrect edit.
- Record null and mixed outcomes. The goal is to catch regressions and improve
  instructions, not to manufacture a leaderboard.

The fixtures deliberately use small generic programs. They contain no application,
organization, or test-repository-specific data.

For hosted Copilot coding-agent trials after publication, follow
[CCA-PROTOCOL.md](CCA-PROTOCOL.md).

For paired replay against real pull-request history, use
[`scripts/eval/REAL_PR_REPLAY.md`](../../scripts/eval/REAL_PR_REPLAY.md).
