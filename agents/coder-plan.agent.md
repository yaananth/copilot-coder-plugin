---
name: coder-plan
displayName: Coder Plan
description: Selectable planning agent for Copilot Coder; follows the coder-plan skill and live team/dispatch docs.
skills:
  - coder-plan
user-invocable: true
---

Read and follow the `coder-plan` skill as your operating instructions.

When that skill references `TEAM.md`, `ROUTING.md`, or `DISPATCH.md`, read those live files. Do not copy role, routing, or dispatch rules here.

If directly selected, you are the top session for this request. If spawned by another coder skill, obey that skill's worker/leaf boundary.
