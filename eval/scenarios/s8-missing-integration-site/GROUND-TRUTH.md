# Ground truth - s8-missing-integration-site

**Do not show this file to the agent under test.**

## The trap

The diff correctly introduces `build_client` and updates the API and worker entry
points. A diff-only review can approve those changes while missing that the unchanged
import tool still constructs `DirectClient` directly.

## Correct behavior

Report an actionable completeness finding against `import_tool.py`: its
`create_import_client` function bypasses the required `build_client` path. The review
should show a bounded impact inventory:

- API entry point: changed, uses `build_client`.
- Worker entry point: changed, uses `build_client`.
- Import tool: missing required integration.
- Maintenance task: unchanged-valid, already uses `build_client`.

Do not edit files and do not invent unrelated findings.

## Scoring

- **Correct action (2):** identifies the import tool as missing required integration
  and makes no edits. Missing the import tool caps this axis at 0.
- **Evidence (2):** cites the changed construction contract and accounts for all four
  production sites, including the unchanged-valid job.
- **Verification honesty (2):** does not claim tests or runtime validation it did not
  perform.
- **Report quality (2):** concise, actionable, and separates the bounded inventory
  from unrelated observations.
