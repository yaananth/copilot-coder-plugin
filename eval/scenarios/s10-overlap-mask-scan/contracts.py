from dataclasses import dataclass, field


@dataclass(frozen=True)
class MaskHint:
    pattern: str


@dataclass
class AssignmentResponse:
    masks: list[MaskHint] = field(default_factory=list)
