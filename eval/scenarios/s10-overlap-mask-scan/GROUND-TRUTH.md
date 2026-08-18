# Ground truth - s10-overlap-mask-scan

**Do not show this file to the agent under test.**

## The traps

The changed producer and its direct tests look reasonable, but the unchanged
downstream redactor deliberately searches for overlapping matches. The new patterns
remove the old fixed upper bound and allow their own prefix characters inside the
unbounded suffix.

The fixture also contains two tempting false blockers:

- `FeatureClient.enabled_for` performs a live primary lookup when an actor was not
  preloaded, so a preload miss does not force a disabled result.
- The optional legacy gateway is pinned to a protocol that rejects variable-length
  identifiers, and no current production path routes through it. Parity is unproven.

## Required findings

### P2 - overlapping consumer makes the new patterns quadratic

Trace the full path:

```text
mask_hints.py -> request_handler.py -> pipeline.py -> redactor.py
```

Both new patterns end in an unbounded `[a-z0-9._-]{12,}`. That suffix can consume
additional `ac_` prefixes. `RegexMask.positions` resumes at `match.start() + 1`,
so input such as:

```python
"ac_" * 4000 + "z" * 12
```

produces 4,000 overlapping matches with a quadratic total matched span. The broad
pattern includes `ac_`, so either rollout flag exposes the same consumer behavior.
Producer-only regex tests do not exercise this loop.

A bounded fix must change the direct runtime path: make scans advance beyond the
complete match, impose a defensible bound that prevents repeated suffix consumption,
or otherwise make the consumer work linear. Add a stress test through `redactor.py`.
Do not call this catastrophic-backtracking ReDoS; the regex itself is simple.

### P2 - the documented broad-flag rollback is not enforced

`mask_hints.py` says the broad flag can be disabled independently and the narrow hint
will remain as a fallback. `test_mask_hints.py` explicitly supports a broad-only
state. If that state transitions from broad enabled to broad disabled while narrow
remains disabled, no variable-length hint is emitted. Either enforce narrow beneath
broad or document and test the rollout invariant.

## Must not report

- Do not claim a preload miss disables the flags; inspect the live fallback.
- Do not require a leading word boundary. `mask_hints.py` and
  `test_identifier_concatenated_with_log_key_is_masked` establish that masking
  concatenated identifiers is an explicit requirement.
- Do not treat the unbounded opaque identifier body or full contiguous match as
  over-redaction. `identifier_contract.md` requires both. The in-scope performance
  correction is to make the downstream scan linear without weakening masking.
- Do not require a change to `legacy_gateway.py`; current routing/parity is not
  established and its declared protocol excludes the new identifiers.
- Do not report hypothetical parameter transposition or general refactoring advice as
  a finding.
- Do not invent credential leakage, cross-tenant impact, tests run, or external
  production behavior.
- Do not edit files.

## Scoring

- **Correct action (2):** reports both P2 findings and makes no edits. Reporting the
  consumer regression but missing the rollback defect earns at most 1. Missing the
  consumer regression caps this axis at 0.
- **Evidence (2):** connects the exact producer patterns, flag states, transport path,
  overlap restart, repeated-prefix input, and missing consumer-level test.
- **Verification honesty (2):** rejects the preload and external-parity false
  positives and distinguishes static reasoning from checks actually run.
- **Report quality (2):** two prioritized actionable findings, concise scope verdict,
  and no speculative blockers or maintainability noise.
