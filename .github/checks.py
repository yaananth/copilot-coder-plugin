"""Small consistency checks for the public copilot-coder plugin."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []


def error(message: str) -> None:
    errors.append(message)
    print(f"FAIL  {message}")


def ok(message: str) -> None:
    print(f"ok    {message}")


manifest_path = ROOT / "plugin.json"
try:
    manifest = json.loads(manifest_path.read_text())
except Exception as exc:
    error(f"{manifest_path.relative_to(ROOT)}: {exc}")
    manifest = {}

required = {"name", "version", "description", "author", "skills", "agents"}
missing = sorted(required - manifest.keys()) if isinstance(manifest, dict) else sorted(required)
if missing:
    error(f"plugin manifest missing: {', '.join(missing)}")
else:
    string_fields = ("name", "version", "description")
    invalid_strings = [
        field for field in string_fields
        if not isinstance(manifest.get(field), str) or not manifest[field].strip()
    ]
    if invalid_strings:
        error(f"plugin manifest invalid string fields: {', '.join(invalid_strings)}")

    version = manifest.get("version", "")
    if isinstance(version, str) and not re.fullmatch(r"\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?", version):
        error(f"plugin manifest version is not semantic: {version!r}")

    author = manifest.get("author")
    if not isinstance(author, dict) or not isinstance(author.get("name"), str) or not author["name"].strip():
        error("plugin manifest author must be an object with a non-empty name")
    elif any(
        key in author and (not isinstance(author[key], str) or not author[key].strip())
        for key in ("email", "url")
    ):
        error("plugin manifest author email/url must be non-empty strings when present")

    for field in ("skills", "agents"):
        entries = manifest.get(field)
        if isinstance(entries, str):
            entries = [entries]
        if (
            not isinstance(entries, list)
            or not entries
            or any(not isinstance(entry, str) or not entry.strip() for entry in entries)
        ):
            error(f"plugin manifest {field} must be a path or non-empty path array")

    if not errors:
        ok(f"plugin manifest valid ({manifest['name']} v{manifest['version']})")

skill_entries = manifest.get("skills", []) if isinstance(manifest, dict) else []
if isinstance(skill_entries, str):
    skill_entries = [skill_entries]
skills: list[Path] = []
for relative in skill_entries:
    if not isinstance(relative, str):
        continue
    path = ROOT / relative
    if (path / "SKILL.md").is_file():
        skills.append(path)
    elif path.is_dir():
        found = sorted(candidate for candidate in path.iterdir() if (candidate / "SKILL.md").is_file())
        if not found:
            error(f"{relative}: no skill directories found")
        skills.extend(found)
    else:
        error(f"{relative}: skill path missing")

for skill_dir in skills:
    skill = skill_dir / "SKILL.md"
    if not skill.is_file():
        error(f"{skill_dir.relative_to(ROOT)}: SKILL.md missing")
        continue
    head = skill.read_text()[:1600]
    if not head.startswith("---\n") or "\nname:" not in head or "\ndescription:" not in head:
        error(f"{skill.relative_to(ROOT)}: invalid frontmatter")
    else:
        ok(f"{skill.relative_to(ROOT)} frontmatter valid")

agent_entries = manifest.get("agents", []) if isinstance(manifest, dict) else []
if isinstance(agent_entries, str):
    agent_entries = [agent_entries]
agents: list[Path] = []
for relative in agent_entries:
    if not isinstance(relative, str):
        continue
    path = ROOT / relative
    if path.is_file():
        agents.append(path)
    elif path.is_dir():
        found = sorted(path.glob("*.agent.md"))
        if not found:
            error(f"{relative}: no agent files found")
        agents.extend(found)
    else:
        error(f"{relative}: agent path missing")

for agent in agents:
    if not agent.is_file():
        error(f"{agent.relative_to(ROOT)}: agent file missing")

marketplace_path = ROOT / ".github" / "plugin" / "marketplace.json"
try:
    marketplace = json.loads(marketplace_path.read_text())
except Exception as exc:
    error(f"{marketplace_path.relative_to(ROOT)}: {exc}")
    marketplace = {}

if isinstance(marketplace, dict):
    plugins = marketplace.get("plugins")
    if not isinstance(plugins, list) or not plugins:
        error("marketplace plugins must be a non-empty array")
    else:
        matching = [
            plugin for plugin in plugins
            if isinstance(plugin, dict) and plugin.get("name") == manifest.get("name")
        ]
        if len(matching) != 1:
            error("marketplace must contain exactly one entry for the plugin manifest name")
        else:
            plugin = matching[0]
            if plugin.get("version") != manifest.get("version"):
                error("marketplace plugin version must match plugin.json")
            if plugin.get("source") != ".":
                error("marketplace plugin source must be repository root (.)")
    metadata = marketplace.get("metadata")
    if isinstance(metadata, dict) and metadata.get("version") != manifest.get("version"):
        error("marketplace metadata version must match plugin.json")

link_pattern = re.compile(r"\]\((?!https?://|#)([^)\s]+)\)")
for markdown in ROOT.rglob("*.md"):
    if ".git" in markdown.parts:
        continue
    body = markdown.read_text()
    for match in link_pattern.finditer(body):
        raw = match.group(1).split("#", 1)[0]
        if not raw or raw.startswith("<"):
            continue
        target = (markdown.parent / raw).resolve()
        if not target.exists():
            error(f"{markdown.relative_to(ROOT)}: broken link {match.group(1)}")

scenario_root = ROOT / "eval" / "scenarios"
for scenario in sorted(path for path in scenario_root.iterdir() if path.is_dir()):
    required_files = [scenario / "task.md", scenario / "GROUND-TRUTH.md"]
    absent = [path.name for path in required_files if not path.is_file() or not path.read_text().strip()]
    if absent:
        error(f"{scenario.relative_to(ROOT)} missing/non-empty: {', '.join(absent)}")
    else:
        ok(f"{scenario.relative_to(ROOT)}")

print()
if errors:
    print(f"{len(errors)} check(s) failed")
    sys.exit(1)
print("all checks passed")
