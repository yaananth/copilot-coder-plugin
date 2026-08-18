# Mask Rollout

Supported rollout states:

1. Narrow only.
2. Narrow plus broad.
3. Broad only after the narrow flag is removed from the cohort because broad
   subsumes it.

The broad flag is the emergency kill switch for broadened matching. Disabling it from
any supported state must retain the narrow variable-identifier protection without a
second coordinated flag change.
