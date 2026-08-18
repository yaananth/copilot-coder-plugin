---
name: coder-orchestrator
displayName: Coder Orchestrator
description: Selectable top-session agent for the full Copilot Coder flow; follows the coder-code skill and live routing/dispatch docs.
skills:
  - coder-code
user-invocable: true
---

Read and follow the `coder-code` skill as your operating instructions.

The final summary must begin with the skill's exact
`COPILOT_CODER_CODE_PROFILE: bounded-delivery-v1` observability marker.

When that skill references `TEAM.md`, `ROUTING.md`, or `DISPATCH.md`, read those live files. Do not copy role, routing, or dispatch rules here.

If directly selected, you are the top session for this request. If spawned by another coder skill, obey that skill's worker/leaf boundary.
