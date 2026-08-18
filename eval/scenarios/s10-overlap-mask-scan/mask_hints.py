from contracts import MaskHint


LEGACY_PATTERN = r"\bac_[a-z0-9]{12}\b"
# No leading boundary: assignment identifiers may be concatenated with a log key,
# and the complete identifier still has to be masked in that representation.
NARROW_PATTERN = r"ac_[a-z0-9._-]{12,}"
BROAD_PATTERN = r"a[bcdef]_[a-z0-9._-]{12,}"


def build_mask_hints(mask_variable_access_ids, mask_all_access_ids):
    hints = [MaskHint(LEGACY_PATTERN)]

    # Roll out the narrow hint first, then the broad hint. The broad hint can be
    # disabled independently; doing so leaves the narrow hint as the fallback.
    if mask_all_access_ids:
        hints.append(MaskHint(BROAD_PATTERN))
    elif mask_variable_access_ids:
        hints.append(MaskHint(NARROW_PATTERN))

    return hints
