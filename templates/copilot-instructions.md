# Copilot Coder Routing

## Copilot Coding Agent

When operating as Copilot Coding Agent, for every pull-request or code-change review,
you MUST invoke the installed `coder-review` skill from the `copilot-coder` plugin.
If the skill is unavailable, stop and report
`COPILOT_CODER_REVIEW_SKILL_UNAVAILABLE` instead of performing a fallback review.

When operating as Copilot Coding Agent, for every other coding, implementation,
debugging, investigation, planning, or code-change task, you MUST invoke the
installed `coder-code` skill from the `copilot-coder` plugin as the sole top-level
coding orchestrator. Let that skill select the lightest complete workflow and
delegate independent work under its own routing rules. If the skill is unavailable,
stop and report `COPILOT_CODER_CODE_SKILL_UNAVAILABLE` instead of performing a
fallback workflow.

GitHub Copilot App's built-in `/orchestrate` skill is for work that genuinely needs
coordination across multiple sessions or repositories. Do not invoke it inside an
ordinary single-repository coding-agent task; `coder-code` already orchestrates that
task.

## Native GitHub Copilot Code Review

When operating as native GitHub Copilot code review, do not apply the Copilot Coding
Agent skill-unavailable stop rules above. Apply the checks in `/REVIEW.md`.
