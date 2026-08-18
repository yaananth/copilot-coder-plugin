from dataclasses import dataclass

from contracts import AssignmentResponse
from mask_hints import build_mask_hints


NARROW_FLAG = "mask_variable_access_ids"
BROAD_FLAG = "mask_all_access_ids"


@dataclass(frozen=True)
class Claims:
    workspace_owner: str
    account_owner: str


@dataclass(frozen=True)
class AssignmentRequest:
    owner: str


def build_assignment(request, claims, features, preloaded):
    actor = request.owner or claims.workspace_owner
    narrow = features.enabled_for(preloaded, NARROW_FLAG, actor)
    broad = features.enabled_for(preloaded, BROAD_FLAG, actor)
    return AssignmentResponse(build_mask_hints(narrow, broad))
