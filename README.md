# copilot-coder

`copilot-coder` is a portable GitHub Copilot plugin for coding work that benefits
from a little structure: gather the right context, make a scoped plan, implement,
verify, and review.

It intentionally does not depend on private models, internal services, remote
sandboxes, or a particular Copilot host surface. When a generic task helper is
available, the workflow can delegate independent work; otherwise it runs the same
phases in the current session.

## Skills

- `/copilot-coder/coder-code` - full coding workflow and phase triage.
- `/copilot-coder/coder-build` - context bundle only; no code changes.
- `/copilot-coder/coder-plan` - implementation-ready plan only.
- `/copilot-coder/coder-review` - diff review and scope-aware closeout.
- `/copilot-coder/coder-team` - roles, panels, and shared working rules.

Copilot CLI can also load the selectable agents that mirror these skills. For Copilot
coding agent, invoke the skill path explicitly in the task prompt. As of August 18,
2026, plugin-supplied agents were not resolved by `gh agent-task --custom-agent`, while
explicit plugin skills were loaded and executed successfully.

## Install in Copilot CLI

Marketplace installation is the supported path. Register this repository as a
marketplace, then install the plugin by its marketplace-qualified name:

```bash
copilot plugin marketplace add yaananth/copilot-coder-plugin
copilot plugin install copilot-coder@yaananth-copilot-coder
```

Do not install the repository directly. Copilot CLI warns that direct installs from
repositories, URLs, and local paths are deprecated and will not be supported in a
future release.

### Migrate a direct installation

If `copilot plugin list` shows an unqualified `copilot-coder` installation, remove it
and reinstall through the marketplace:

```bash
copilot plugin uninstall copilot-coder
copilot plugin marketplace add yaananth/copilot-coder-plugin
copilot plugin install copilot-coder@yaananth-copilot-coder
```

Skip the marketplace-add command if `yaananth-copilot-coder` is already registered.
After migration, `copilot plugin list` should show
`copilot-coder@yaananth-copilot-coder`.

## Enable in Copilot Coding Agent

Add [templates/copilot-settings.json](templates/copilot-settings.json) to the
consumer repository as `.github/copilot/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "yaananth-copilot-coder": {
      "source": {
        "source": "github",
        "repo": "yaananth/copilot-coder-plugin"
      }
    }
  },
  "enabledPlugins": {
    "copilot-coder@yaananth-copilot-coder": true
  }
}
```

Commit this file to the consumer repository's default branch before starting the
hosted task. In an August 18, 2026 validation, CCA accepted a non-default `--base`
branch containing this file but did not load the external plugin from it.

To route every hosted review and coding task through the plugin, merge
[templates/copilot-instructions.md](templates/copilot-instructions.md) into the
consumer repository's `.github/copilot-instructions.md`. Repository instructions
must name the installed skills by their bare frontmatter names, `coder-review` and
`coder-code`, while identifying them as coming from the `copilot-coder` plugin.
Literal slash paths and `plugin:skill` identifiers did not resolve reliably when
passed directly to CCA's skill tool.

This automatic route was validated on August 19, 2026: CCA cloned the plugin,
invoked `coder-code`, read its routing/team/dispatch files, implemented and tested a
change, invoked `coder-review`, and emitted both profile markers. `coder-code` is the
sole top-level orchestrator inside a coding task. GitHub Copilot App's built-in
`/orchestrate` skill is useful before a task when work genuinely spans multiple
sessions or repositories; it should not be required inside every single-repository
CCA task.

Treat automatic-routing canaries and quality A/Bs as different experiments. A
quality A/B must omit the mandatory routing instructions from both arms so the
plugin-disabled control remains a normal CCA run; the method arm enables the plugin
and prepends the explicit skill invocation shown below. See
[eval/ab/CCA-PROTOCOL.md](eval/ab/CCA-PROTOCOL.md) before running either experiment.

For a one-off CCA treatment task without repository routing instructions, start with:

```text
Use the /copilot-coder/coder-code skill for this task.
```

## Use

```text
/copilot-coder/coder-code add a request timeout to the API client
/copilot-coder/coder-build map the files needed for a billing retry change
/copilot-coder/coder-plan split the cache migration into safe work items
/copilot-coder/coder-review review the current branch
/copilot-coder/coder-team show the review panel
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

The template routes CCA tasks through the installed skills and tells native code
review to apply `/REVIEW.md`. Keep the review portion aligned with
`skills/coder-review/SKILL.md`.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for local checks and
[eval/ab/README.md](eval/ab/README.md) for the paired control-versus-plugin
evaluation harness.

## Publication Status

This repository grants permission to download, install, and execute unmodified copies
for GitHub Copilot use and evaluation. Redistribution, modified copies, derivative
works, and broader product use remain restricted. Open-source licensing remains gated
on the provenance review in [PUBLICATION_CHECKLIST.md](PUBLICATION_CHECKLIST.md) and
[NOTICE](NOTICE).
