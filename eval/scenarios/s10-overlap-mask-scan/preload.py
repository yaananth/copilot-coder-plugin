RUNNER_FEATURES = (
    "mask_variable_access_ids",
    "mask_all_access_ids",
)


def preload_claim_actors(primary, claims):
    values = {}
    for actor in (claims.workspace_owner, claims.account_owner):
        if not actor:
            continue
        for feature in RUNNER_FEATURES:
            values[(feature, actor)] = primary.is_enabled(feature, actor)
    return values
