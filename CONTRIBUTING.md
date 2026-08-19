# Contributing

Thanks for improving `copilot-coder`.

## Development Rules

- Keep changes narrowly tied to the issue or behavior being improved.
- Preserve the portable contract: no internal endpoints, company-only documents,
  private model names, host-specific project/session APIs, or remote-sandbox
  requirements.
- Put phase routing in `skills/coder-code/ROUTING.md`, portable dispatch in
  `skills/coder-code/DISPATCH.md`, and roles/shared bars in
  `skills/coder-code/TEAM.md`.
- Keep `templates/REVIEW.md` aligned with the semantic-impact and scope rules in
  `skills/coder-review/SKILL.md`. `templates/copilot-instructions.md` also owns the
  CCA automatic-routing contract: use the bare skill names `coder-review` and
  `coder-code`, identify them as coming from `copilot-coder`, and keep the native
  review exception aligned with `/REVIEW.md`.
- Update the manifest version for a user-visible plugin behavior change.

## Checks

Run these from the repository root:

```bash
python3 .github/checks.py
git diff --check
```

For a behavioral prompt change, run the targeted scenario in both arms:

```bash
scripts/eval/ab.sh s7-scope-overreach
```

The evaluation is a regression signal, not a benchmark. Record both outcomes,
including failures and ambiguous results, rather than presenting one run as proof of
quality.

## Pull Requests

Describe:

1. The user-facing behavior changed.
2. The scope boundary the change preserves.
3. The checks and evaluation scenarios run.
4. Any remaining uncertainty or follow-up work.
