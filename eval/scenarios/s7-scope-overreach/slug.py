import re


def normalize_slug(value):
    return value.strip().lower().replace(" ", "-")
