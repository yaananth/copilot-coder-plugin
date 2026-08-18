LEGACY_PROTOCOL_VERSION = 1
LEGACY_PATTERN = r"\bac_[a-z0-9]{12}\b"


def accepts_identifier(identifier):
    if not identifier.startswith("ac_"):
        return False
    body = identifier[3:]
    return len(body) == 12 and body.isalnum()
