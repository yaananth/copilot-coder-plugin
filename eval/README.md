# Behavioral Evaluations

These small fixtures test whether the plugin's instructions still produce the
behavior they claim to enforce. They are regression signals, not a benchmark or a
statistical quality claim.

Each scenario contains a task, fixture files, and a hidden `GROUND-TRUTH.md`. The
runner copies only the task and fixture into a temporary workspace, then computes the
resulting diff after the agent exits.

## Scenarios

| Scenario | Trap | Guarded behavior |
|---|---|---|
| `s7-scope-overreach` | Fixing an unrelated failure exposed by a broad test run | Inspect broadly, edit only requested behavior |
| `s8-missing-integration-site` | Reviewing only changed entry points while an unchanged import tool bypasses a required client builder | Inventory unchanged production integration sites |
| `s9-stale-shared-state-copy` | Missing an unchanged copied owner after routing state becomes copy-on-write | Inventory ownership and copy semantics |
| `s10-overlap-mask-scan` | Reviewing producer regexes without tracing an overlapping downstream consumer, while accepting preload and external-parity false positives | Trace direct consumer complexity and flag transitions; require a present failure path |
| `s11-large-review-batches` | Treating a large constructor family as one opaque pass and missing the final unchanged integration site | Manifest, subdivide, reconcile, and complete bounded review batches |

## Run One Arm

```bash
scripts/eval/run.sh s7-scope-overreach
scripts/eval/run.sh --control s7-scope-overreach
```

The method arm loads this plugin. The control arm invokes the same Copilot CLI without
the plugin. Custom instructions are disabled in both arms by default; pass
`--with-custom-instructions` to enable them symmetrically. Both arms receive the same
task and fixture. Every agent and judge invocation uses fresh user, Copilot, GitHub
CLI, and XDG configuration directories, so globally installed plugins and local
configuration cannot leak into either arm. Built-in MCPs, Git credential helpers,
interactive Git authentication, SSH-agent access, and CLI auto-update are disabled.
Authentication for the Copilot service is resolved from the standard token variables
or `gh auth token` and is passed as a protected secret.

## Run a Pair

Use the paired A/B harness in [ab/README.md](ab/README.md):

```bash
scripts/eval/ab.sh s7-scope-overreach
```

Run a scenario more than once before drawing a conclusion. Preserve the artifacts
under `.eval-runs/` and compare the computed diffs, reports, and optional judge scores.

## Compare Instruction Revisions

Use the current harness and fixtures while staging another plugin checkout:

```bash
EVAL_PLUGIN_SOURCE=/path/to/prior-plugin-checkout \
  scripts/eval/run.sh --agent coder-review --judge auto \
  s10-overlap-mask-scan
```

Run the current candidate with the same command minus `EVAL_PLUGIN_SOURCE`. Keep the
scenario, model, judge, instructions, and tool policy identical. Repeat preselected
runs before attributing a score difference to the instruction change; one old/new
pair is only a signal.

For pinned base/head or base/patch replay of an external pull request, see
[`scripts/eval/REAL_PR_REPLAY.md`](../scripts/eval/REAL_PR_REPLAY.md).
