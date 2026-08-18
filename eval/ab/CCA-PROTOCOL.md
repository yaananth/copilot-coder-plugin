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
3. Start the same hosted coding task in each isolated arm.
4. Preserve the agent report, command transcript when available, resulting branch or
   pull request, final diff, changed-file list, checks, elapsed time, and failures.
5. Copy those artifacts into a judge bundle that contains only the opaque label.
6. Judge correctness, scope discipline, verification honesty, and report quality.
7. Freeze scores before reading `arm-map.json`.

Retry only infrastructure failures. A poor result is data, not a reason to rerun one
arm selectively.

## Consumer Configuration

The method repository should enable the public plugin through the current supported
repository settings format. Validate the identifier and settings schema against the
live hosted product before committing the file; do not assume private-repository
behavior proves public plugin discovery.

## Minimum Pilot

Start with one task and two paired repetitions. Verify plugin loading, isolation,
artifact capture, and blinded judging before freezing a larger task catalog. A useful
comparison normally needs several task shapes and repeated pairs; one successful demo
does not establish that either arm is generally better.
