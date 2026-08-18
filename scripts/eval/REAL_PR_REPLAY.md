# External Real-PR Replay

`real-pr-replay.sh` runs an external real-PR fixture in paired control and
method worktrees. The catalog, repository snapshot, task, and ground truth stay
outside this public plugin.

The runner randomizes which condition receives `run-A` or `run-B` from
`--seed`. It writes `arm-map.json` only after both runs complete. The judge packet
contains candidates by opaque label and never includes that mapping.

Catalog fields:

```json
{
  "cases": {
    "review-from-head": {
      "repo": "/private/repo",
      "base_ref": "base-commit",
      "head_ref": "head-commit",
      "task": "/private/task.md",
      "ground_truth": "/private/GROUND-TRUTH.md",
      "mode": "review"
    },
    "review-from-patch": {
      "repo": "/private/repo",
      "base_ref": "base-commit",
      "patch": "/private/change.diff",
      "task": "/private/task.md",
      "ground_truth": "/private/GROUND-TRUTH.md",
      "mode": "review"
    }
  }
}
```

Every case must pin `base_ref` and provide exactly one of `head_ref` or `patch`.
The runner reconstructs the proposed pull-request state in separate detached
worktrees and gives the agent the exact PR diff as `.copilot-eval/change.diff`.

Review mode uses a read-only tool allowlist and fails when the worktree changes.
Implementation mode permits the normal coding tools. Each arm gets a fresh
`HOME`, `XDG_CONFIG_HOME`, `COPILOT_HOME`, and `GH_CONFIG_DIR`; Git credential
helpers, terminal prompts, SSH-agent access, and built-in MCPs are disabled.
Authentication for the Copilot service is supplied as a protected secret from
`COPILOT_GITHUB_TOKEN`, `GH_TOKEN`, `GITHUB_TOKEN`, or `gh auth token`.

```bash
scripts/eval/real-pr-replay.sh --catalog /private/catalog.json \
  --case review-1 --out /private/results/run-1 --seed 42 \
  --plugin-dir /private/staged/copilot-coder-plugin --judge <model>
```

By default, repository custom instructions are disabled in both arms. Add
`--with-custom-instructions` to enable them symmetrically when the intended
comparison is normal repository-configured CCA versus the same CCA plus the plugin.

Each arm preserves the original PR diff, report, stderr, exit status, commit,
tracked/index/untracked state, a complete post-run filesystem snapshot, the
harness-computed agent-only diff, verification result, and optional validated
`score.json`. `manifest.json` records the pinned source identity. `arm-map.json` is
written only after both opaque arms and any judges have completed.

Nonzero agent, mutation-check, or judge exits make the runner fail. The judge uses
the same structured rubric and score validator as the synthetic harness.
