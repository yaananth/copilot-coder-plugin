import re


class RegexMask:
    def __init__(self, pattern):
        self.pattern = re.compile(pattern)

    def positions(self, text):
        cursor = 0
        while cursor < len(text):
            match = self.pattern.search(text, cursor)
            if match is None:
                return
            cursor = match.start() + 1
            yield match.start(), match.end()


class SecretRedactor:
    def __init__(self, hints):
        self.masks = [RegexMask(hint.pattern) for hint in hints]

    def mask(self, text):
        positions = sorted(
            position
            for mask in self.masks
            for position in mask.positions(text)
        )
        if not positions:
            return text

        merged = []
        for start, end in positions:
            if not merged or start > merged[-1][1]:
                merged.append([start, end])
            else:
                merged[-1][1] = max(merged[-1][1], end)

        parts = []
        cursor = 0
        for start, end in merged:
            parts.append(text[cursor:start])
            parts.append("***")
            cursor = end
        parts.append(text[cursor:])
        return "".join(parts)
