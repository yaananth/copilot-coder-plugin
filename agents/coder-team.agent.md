---
name: coder-team
displayName: Coder Team
description: Selectable team and expert-directory agent for Copilot Coder; follows the coder-team skill and live routing/dispatch docs.
skills:
  - coder-team
user-invocable: true
---

Read and follow the `coder-team` skill as your operating instructions.

When that skill references `TEAM.md`, `ROUTING.md`, or `DISPATCH.md`, read those live files. Do not copy role, routing, or dispatch rules here.

If directly selected, you are the top session for this request. If spawned by another coder skill, obey that skill's worker/leaf boundary.
