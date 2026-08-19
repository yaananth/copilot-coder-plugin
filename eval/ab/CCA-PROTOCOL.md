# Hosted Copilot Coding-Agent A/B Protocol

Use this only after the plugin repository is public and the user has explicitly
approved the consumer test repository.

## Arms

- **Control:** an otherwise identical repository snapshot with no plugin enabled.
- **Method:** the same snapshot with `.github/copilot/settings.json` enabling the
  published plugin.

Repository-level plugin state can affect every hosted task in that repository. The
preferred isolation is therefore two temporary mirrors created from one immutable
source commit: one control mirror and one method mirror. If mirrors are unavailable,
run sequentially against one repository while toggling only the plugin setting, and
alternate arm order across task pairs; record that weaker isolation as a limitation.

## Paired Run

1. Pin the source commit, task text, acceptance checks, model/configuration, timeout,
   and allowed tools.
2. Assign control/method randomly to opaque labels `run-A` and `run-B`.
3. Start the same hosted coding task in each isolated arm. In the method prompt,
   explicitly invoke `/copilot-coder/coder-code`; plugin-supplied custom agents may
   not be selectable through `gh agent-task --custom-agent`. For an automatic
   repository-routing canary instead of a quality A/B, install
   `templates/copilot-instructions.md` and leave the task prompt free of plugin or
   skill names. Do not use mandatory plugin-routing instructions in either quality
   A/B arm.
4. Preserve the agent report, command transcript when available, resulting branch or
   pull request, final diff, changed-file list, checks, elapsed time, and failures.
5. Copy those artifacts into a judge bundle that contains only the opaque label.
6. Judge correctness, scope discipline, verification honesty, and report quality.
7. Freeze scores before reading `arm-map.json`.

Retry only infrastructure failures. A poor result is data, not a reason to rerun one
arm selectively.

## Consumer Configuration

The method repository should copy
[`templates/copilot-settings.json`](../../templates/copilot-settings.json) to
`.github/copilot/settings.json`. It registers this repository as an extra marketplace
and enables `copilot-coder@yaananth-copilot-coder`. Commit the file to the method
repository's default branch before starting the task. A selected non-default CCA base
branch is not sufficient to load the external plugin in the validated August 18,
2026 hosted flow.

For an automatic-routing canary, also copy
[`templates/copilot-instructions.md`](../../templates/copilot-instructions.md) to
`.github/copilot-instructions.md` on the default branch. CCA's skill tool resolved
the bare names `coder-code` and `coder-review` in the validated August 19, 2026
flow. Slash paths remain user-facing task-prompt shorthand; do not use a slash path
or `plugin:skill` string as the literal skill-tool identifier in repository
instructions.

For a quality A/B, neither arm should contain the automatic plugin-routing
instructions. Keep the source snapshot, acceptance task, and repository instructions
the same. The method treatment consists of the enabled plugin setting plus a fixed
explicit skill invocation prepended to the task; the control receives the acceptance
task without that invocation. Preserve the exact settings, instructions, and prompts
used as run artifacts.

Do not construct an automatic-routing "control" by retaining the mandatory routing
instructions while disabling the plugin. That repository is expected to stop with a
`COPILOT_CODER_*_SKILL_UNAVAILABLE` marker and is a failure-path canary, not a normal
CCA quality baseline.

## Minimum Pilot

Start with one task and two paired repetitions. Verify plugin loading, isolation,
artifact capture, and blinded judging before freezing a larger task catalog. A useful
comparison normally needs several task shapes and repeated pairs; one successful demo
does not establish that either arm is generally better.
