#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
JUDGE_PROMPT="$ROOT/scripts/eval/JUDGE.md"
MAX_EMBED=160000
EVAL_PLUGIN_NAME="${REAL_PR_EVAL_PLUGIN_NAME:-copilot-coder-real-pr-eval}"

usage() {
  cat <<'EOF'
Usage: real-pr-replay.sh --catalog FILE --case ID --out DIR
  [--model MODEL] [--agent AGENT] [--judge MODEL] [--plugin-dir DIR] [--seed N]
  [--with-custom-instructions]

The external JSON catalog must provide repo, base_ref, task, ground_truth, and
exactly one of head_ref or patch for the selected case. Optional mode is
implementation or review.
EOF
}

CATALOG=""
CASE_ID=""
OUT=""
MODEL=""
AGENT=""
JUDGE=""
PLUGIN_SOURCE=""
SEED="0"
USE_CUSTOM_INSTRUCTIONS=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --catalog) CATALOG="${2:?missing value}"; shift 2;;
    --case) CASE_ID="${2:?missing value}"; shift 2;;
    --out) OUT="${2:?missing value}"; shift 2;;
    --model) MODEL="${2:?missing value}"; shift 2;;
    --agent) AGENT="${2:?missing value}"; shift 2;;
    --judge) JUDGE="${2:?missing value}"; shift 2;;
    --plugin-dir) PLUGIN_SOURCE="${2:?missing value}"; shift 2;;
    --seed) SEED="${2:?missing value}"; shift 2;;
    --with-custom-instructions) USE_CUSTOM_INSTRUCTIONS=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2;;
  esac
done

if [ ! -s "$CATALOG" ] || [ -z "$CASE_ID" ] || [ -z "$OUT" ]; then
  usage >&2
  exit 2
fi
[ -n "$PLUGIN_SOURCE" ] || { echo "--plugin-dir is required" >&2; exit 2; }
[ -f "$PLUGIN_SOURCE/.github/plugin/plugin.json" ] || {
  echo "plugin manifest missing under $PLUGIN_SOURCE" >&2
  exit 2
}
[ -s "$JUDGE_PROMPT" ] || { echo "judge prompt missing: $JUDGE_PROMPT" >&2; exit 2; }

for command in git copilot python3 tar; do
  command -v "$command" >/dev/null 2>&1 || {
    echo "$command is required" >&2
    exit 127
  }
done

repo=""
base_ref=""
head_ref=""
patch=""
task=""
ground_truth=""
mode=""
catalog_assignments=""
if ! catalog_assignments="$(python3 - "$CATALOG" "$CASE_ID" <<'PY'
import json
import shlex
import sys

catalog_path, case_id = sys.argv[1:]
try:
    catalog = json.load(open(catalog_path))
    case = catalog["cases"][case_id]
except (OSError, KeyError, TypeError, json.JSONDecodeError) as exc:
    raise SystemExit(f"invalid catalog/case: {exc}")

for key in ("repo", "base_ref", "task", "ground_truth"):
    if not case.get(key):
        raise SystemExit("missing catalog field: " + key)

head_ref = str(case.get("head_ref", ""))
patch = str(case.get("patch", ""))
if bool(head_ref) == bool(patch):
    raise SystemExit("catalog must provide exactly one of head_ref or patch")

values = {
    "repo": str(case["repo"]),
    "base_ref": str(case["base_ref"]),
    "head_ref": head_ref,
    "patch": patch,
    "task": str(case["task"]),
    "ground_truth": str(case["ground_truth"]),
    "mode": str(case.get("mode", "implementation")),
}
for key, value in values.items():
    print(f"{key}={shlex.quote(value)}")
PY
)"; then
  exit 2
fi
eval "$catalog_assignments"

[ "$mode" = review ] || [ "$mode" = implementation ] || {
  echo "catalog mode must be 'review' or 'implementation'" >&2
  exit 2
}
[ -d "$repo" ] || { echo "catalog repo is not a directory: $repo" >&2; exit 2; }
[ -s "$task" ] || { echo "catalog task is missing/empty: $task" >&2; exit 2; }
[ -s "$ground_truth" ] || {
  echo "catalog ground truth is missing/empty: $ground_truth" >&2
  exit 2
}
if [ -n "$patch" ]; then
  [ -s "$patch" ] || { echo "catalog patch is missing/empty: $patch" >&2; exit 2; }
fi

repo="$(cd "$repo" && pwd)"
PLUGIN_SOURCE="$(cd "$PLUGIN_SOURCE" && pwd)"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"

base_sha="$(git -C "$repo" rev-parse --verify "${base_ref}^{commit}")" || {
  echo "cannot resolve base_ref: $base_ref" >&2
  exit 2
}
head_sha=""
source_sha="$base_sha"
source_kind="patch"
if [ -n "$head_ref" ]; then
  head_sha="$(git -C "$repo" rev-parse --verify "${head_ref}^{commit}")" || {
    echo "cannot resolve head_ref: $head_ref" >&2
    exit 2
  }
  source_sha="$head_sha"
  source_kind="head"
fi

root="$(mktemp -d "${TMPDIR:-/tmp}/real-pr-replay.XXXXXX")"
cleanup() {
  local path=""
  for path in "$root/run-A-work" "$root/run-B-work" "$root/baseline-work"; do
    git -C "$repo" worktree remove --force "$path" >/dev/null 2>&1 || true
  done
  rm -rf "$root"
}
trap cleanup EXIT

pr_diff="$root/pr.diff"
if [ "$source_kind" = head ]; then
  git -C "$repo" diff --binary "$base_sha" "$head_sha" >"$pr_diff"
else
  cp "$patch" "$pr_diff"
fi
[ -s "$pr_diff" ] || { echo "the selected base/head or patch has an empty diff" >&2; exit 2; }

resolve_eval_auth_token() {
  local token="${COPILOT_GITHUB_TOKEN:-${GH_TOKEN:-${GITHUB_TOKEN:-}}}"
  if [ -z "$token" ] && command -v gh >/dev/null 2>&1; then
    token="$(gh auth token 2>/dev/null || true)"
  fi
  if [ -z "$token" ]; then
    echo "isolated replay needs COPILOT_GITHUB_TOKEN, GH_TOKEN, GITHUB_TOKEN, or 'gh auth token'" >&2
    return 1
  fi
  printf '%s' "$token"
}

EVAL_AUTH_TOKEN="$(resolve_eval_auth_token)" || exit 1

copilot_eval() {
  local home="$1"
  shift
  mkdir -p "$home/user-home" "$home/copilot" "$home/gh-config" "$home/xdg-config"
  HOME="$home/user-home" \
  XDG_CONFIG_HOME="$home/xdg-config" \
  COPILOT_HOME="$home/copilot" \
  GH_CONFIG_DIR="$home/gh-config" \
  GIT_CONFIG_COUNT=1 \
  GIT_CONFIG_KEY_0=credential.helper \
  GIT_CONFIG_VALUE_0='' \
  GIT_TERMINAL_PROMPT=0 \
  SSH_AUTH_SOCK='' \
  COPILOT_GITHUB_TOKEN="$EVAL_AUTH_TOKEN" \
  GH_TOKEN='' \
  GITHUB_TOKEN='' \
    copilot --secret-env-vars=COPILOT_GITHUB_TOKEN,GH_TOKEN,GITHUB_TOKEN \
      --no-auto-update "$@"
}

PLUGIN_DIR="$root/plugin"
mkdir -p "$PLUGIN_DIR/.github/plugin"
cp -R "$PLUGIN_SOURCE/skills" "$PLUGIN_DIR/skills"
cp -R "$PLUGIN_SOURCE/agents" "$PLUGIN_DIR/agents"
cp "$PLUGIN_SOURCE/.github/plugin/plugin.json" "$PLUGIN_DIR/.github/plugin/plugin.json"
python3 - "$PLUGIN_DIR/.github/plugin/plugin.json" "$EVAL_PLUGIN_NAME" <<'PY'
import json
import sys

path, name = sys.argv[1:]
with open(path) as handle:
    manifest = json.load(handle)
manifest["name"] = name
with open(path, "w") as handle:
    json.dump(manifest, handle, indent=2)
    handle.write("\n")
PY

if [ -z "$AGENT" ]; then
  if [ "$mode" = review ]; then
    AGENT="$EVAL_PLUGIN_NAME:coder-review"
  else
    AGENT="$EVAL_PLUGIN_NAME:coder-orchestrator"
  fi
elif [[ "$AGENT" != *:* ]]; then
  AGENT="$EVAL_PLUGIN_NAME:$AGENT"
elif [ "${AGENT%%:*}" = "copilot-coder" ]; then
  AGENT="$EVAL_PLUGIN_NAME:${AGENT#*:}"
elif [ "${AGENT%%:*}" != "$EVAL_PLUGIN_NAME" ]; then
  echo "--agent must target the staged plugin '$EVAL_PLUGIN_NAME'" >&2
  exit 2
fi

agent_name="${AGENT#*:}"
case "$agent_name" in
  ""|*[!A-Za-z0-9_-]*)
    echo "invalid staged agent name: $agent_name" >&2
    exit 2
    ;;
esac
[ -f "$PLUGIN_DIR/agents/$agent_name.agent.md" ] || {
  echo "staged plugin has no agent '$agent_name'" >&2
  exit 2
}
if ! copilot_eval "$root/preflight-home" --plugin-dir "$PLUGIN_DIR" plugin list 2>/dev/null \
    | grep -Fq "$EVAL_PLUGIN_NAME"; then
  echo "staged evaluation plugin '$EVAL_PLUGIN_NAME' was not discovered" >&2
  exit 1
fi

prepare_worktree() {
  local path="$1"
  git -C "$repo" worktree add --detach "$path" "$source_sha" >/dev/null || return $?
  if [ "$source_kind" = patch ]; then
    git -C "$path" apply --binary "$pr_diff" || return $?
  fi
  mkdir -p "$path/.copilot-eval" || return $?
  cp "$pr_diff" "$path/.copilot-eval/change.diff" || return $?
}

snapshot_tree() {
  local source="$1"
  local destination="$2"
  mkdir -p "$destination" || return $?
  tar -C "$source" \
    --exclude='.git' \
    --exclude='*/.git' \
    --exclude='__pycache__' \
    --exclude='*/__pycache__' \
    --exclude='*.pyc' \
    --exclude='.pytest_cache' \
    --exclude='*/.pytest_cache' \
    --exclude='.ruff_cache' \
    --exclude='*/.ruff_cache' \
    --exclude='.mypy_cache' \
    --exclude='*/.mypy_cache' \
    --exclude='.DS_Store' \
    -cf - . | tar -C "$destination" -xf -
}

assignment="$(python3 - "$SEED" <<'PY'
import random
import sys

random.seed(sys.argv[1])
print("control,method" if random.randrange(2) == 0 else "method,control")
PY
)"
arm_a="${assignment%,*}"
arm_b="${assignment#*,}"

run_arm() {
  local arm="$1"
  local label="$2"
  local dir="$root/$label-work"
  local dest="$OUT/$label"
  local home="$root/$label-home"
  local prompt=""
  local status=0

  prepare_worktree "$dir" || return $?
  mkdir -p "$dest" || return $?
  cp "$task" "$dest/task.md" || return $?
  cp "$pr_diff" "$dest/pr.diff" || return $?

  prompt="$(cat "$task")" || return $?
  prompt+=$'\n\nThe exact pull-request diff is available at `.copilot-eval/change.diff`.'
  if [ "$mode" = review ]; then
    prompt+=$'\nREVIEW-ONLY: inspect and report findings. Do not edit, create, delete, or format files.'
  fi

  local -a args=(
    -p "$prompt"
    --no-color
    -s
    -C "$dir"
    --disable-builtin-mcps
  )
  if [ "$mode" = review ]; then
    args+=("--available-tools=view,grep,glob")
  else
    args+=(--allow-all-tools)
  fi
  [ "$USE_CUSTOM_INSTRUCTIONS" = 0 ] && args+=(--no-custom-instructions)
  if [ "$arm" = method ]; then
    args+=(--plugin-dir "$PLUGIN_DIR" --add-dir "$PLUGIN_DIR" --agent "$AGENT")
  fi
  [ -n "$MODEL" ] && args+=(--model "$MODEL")

  copilot_eval "$home" "${args[@]}" >"$dest/report.txt" 2>"$dest/agent.err" || status=$?
  if [ ! -s "$dest/report.txt" ]; then
    echo "agent returned an empty report" >>"$dest/agent.err"
    [ "$status" -ne 0 ] || status=1
  fi

  printf '%s\n' "$status" >"$dest/exit-status" || return $?
  git -C "$dir" rev-parse HEAD >"$dest/commit.txt" || return $?
  git -C "$dir" status --short --untracked-files=all >"$dest/status.txt" || return $?
  git -C "$dir" diff --binary >"$dest/worktree.diff" || return $?
  git -C "$dir" diff --cached --binary >"$dest/index.diff" || return $?
  git -C "$dir" ls-files --others --exclude-standard >"$dest/untracked.txt" || return $?
  snapshot_tree "$dir" "$dest/result" || return $?
  return "$status"
}

status_a=0
status_b=0
if run_arm "$arm_a" run-A; then
  status_a=0
else
  status_a=$?
fi
if run_arm "$arm_b" run-B; then
  status_b=0
else
  status_b=$?
fi

prepare_worktree "$root/baseline-work"
snapshot_tree "$root/baseline-work" "$root/baseline"

finalize_run() {
  local label="$1"
  local dest="$OUT/$label"
  local dstat=0
  local changed=""

  git diff --no-index --binary "$root/baseline" "$dest/result" \
    >"$dest/agent-changed.diff" 2>"$dest/diff.err" || dstat=$?
  if [ "$dstat" -gt 1 ] || [ -s "$dest/diff.err" ]; then
    changed="ERROR"
  elif [ -s "$dest/agent-changed.diff" ]; then
    changed="yes"
  else
    changed="no"
  fi
  printf '%s\n' "$changed" >"$dest/files-changed" || return $?

  if [ "$changed" = ERROR ]; then
    echo "DIFF_ERROR" >"$dest/verification.txt" || return 1
    return 1
  fi
  if [ "$mode" = review ] && [ "$changed" = yes ]; then
    echo "REVIEW_ONLY_VIOLATION" >"$dest/verification.txt" || return 1
    return 1
  fi
  {
    printf 'files_changed=%s\n' "$changed"
    if [ "$mode" = review ]; then
      printf 'review_only_ok=yes\n'
    fi
  } >"$dest/verification.txt" || return $?
}

diff_a=0
diff_b=0
if finalize_run run-A; then
  diff_a=0
else
  diff_a=$?
fi
if finalize_run run-B; then
  diff_b=0
else
  diff_b=$?
fi

validate_score() {
  python3 - "$1" <<'PY'
import json
import re
import sys

try:
    raw = open(sys.argv[1]).read()
except OSError:
    raise SystemExit(1)
match = re.search(r"\{.*\}", raw, re.S)
if not match:
    raise SystemExit(1)
try:
    data = json.loads(match.group(0))
except json.JSONDecodeError:
    raise SystemExit(1)

keys = ["correct_action", "evidence", "verification", "report"]
if not all(type(data.get(key)) is int for key in keys):
    raise SystemExit(1)
values = {key: data[key] for key in keys}
if any(value < 0 or value > 2 for value in values.values()):
    raise SystemExit(1)
total = sum(values.values())
correct = values["correct_action"]
verdict = "fail" if correct == 0 else ("pass" if correct == 2 and total >= 7 else "partial")
result = dict(values)
result.update(total=total, verdict=verdict, note=str(data.get("note", ""))[:120])
print(json.dumps(result, separators=(",", ":")))
PY
}

capped_file() {
  local path="$1"
  local label="$2"
  head -c "$MAX_EMBED" "$path" 2>/dev/null || true
  if [ "$(wc -c <"$path")" -gt "$MAX_EMBED" ]; then
    printf '\n...[%s truncated]\n' "$label"
  fi
}

judge_one() {
  local label="$1"
  local dest="$OUT/$label"
  local judge_home="$root/$label-judge-home"
  local judge_cwd="$root/$label-judge-cwd"
  local changed=""
  local prompt=""
  local score=""

  changed="$(cat "$dest/files-changed")" || return $?
  mkdir -p "$judge_cwd" || return $?
  prompt="$(cat "$JUDGE_PROMPT")

## Scenario
$CASE_ID (candidate: $label; mode: $mode)

## Task given to the agent
$(cat "$task")

## Ground truth (the agent never received this file)
$(cat "$ground_truth")

## Original pull-request diff
\`\`\`diff
$(capped_file "$pr_diff" "pull-request diff")
\`\`\`

## Harness-computed agent workspace changes
files_changed: $changed
\`\`\`diff
$(capped_file "$dest/agent-changed.diff" "agent diff")
\`\`\`

## Post-run git status
\`\`\`text
$(capped_file "$dest/status.txt" "status")
\`\`\`

## Agent report
$(capped_file "$dest/report.txt" "report")"

  if ! copilot_eval "$judge_home" \
      -p "$prompt" --available-tools= --disable-builtin-mcps --no-custom-instructions \
      --no-color -s --model "$JUDGE" -C "$judge_cwd" \
      >"$dest/judge.raw" 2>"$dest/judge.err"; then
    return 1
  fi
  if ! score="$(validate_score "$dest/judge.raw")"; then
    echo "judge output was not valid score JSON" >>"$dest/judge.err"
    return 1
  fi
  printf '%s\n' "$score" >"$dest/score.json" || return $?
}

python3 - "$OUT/manifest.json" "$SEED" "$CASE_ID" "$mode" "$source_kind" \
  "$base_sha" "$head_sha" <<'PY'
import json
import sys

path, seed, case_id, mode, source_kind, base_sha, head_sha = sys.argv[1:]
with open(path, "w") as handle:
    json.dump(
        {
            "case": case_id,
            "seed": seed,
            "mode": mode,
            "source_kind": source_kind,
            "base_sha": base_sha,
            "head_sha": head_sha or None,
            "labels": ["run-A", "run-B"],
        },
        handle,
        indent=2,
    )
    handle.write("\n")
PY

judge_a=0
judge_b=0
if [ -n "$JUDGE" ] && [ "$status_a" -eq 0 ] && [ "$diff_a" -eq 0 ]; then
  if judge_one run-A; then
    judge_a=0
  else
    judge_a=$?
  fi
fi
if [ -n "$JUDGE" ] && [ "$status_b" -eq 0 ] && [ "$diff_b" -eq 0 ]; then
  if judge_one run-B; then
    judge_b=0
  else
    judge_b=$?
  fi
fi

python3 - "$OUT/arm-map.json" "$SEED" "$arm_a" "$arm_b" "$status_a" "$status_b" \
  "$diff_a" "$diff_b" "$judge_a" "$judge_b" <<'PY'
import json
import sys

(
    path,
    seed,
    arm_a,
    arm_b,
    status_a,
    status_b,
    diff_a,
    diff_b,
    judge_a,
    judge_b,
) = sys.argv[1:]
with open(path, "w") as handle:
    json.dump(
        {
            "seed": seed,
            "run-A": arm_a,
            "run-B": arm_b,
            "run-A-exit": int(status_a),
            "run-B-exit": int(status_b),
            "run-A-diff-exit": int(diff_a),
            "run-B-diff-exit": int(diff_b),
            "run-A-judge-exit": int(judge_a),
            "run-B-judge-exit": int(judge_b),
        },
        handle,
        indent=2,
    )
    handle.write("\n")
PY

printf 'Replay artifacts: %s\n' "$OUT"
if [ "$status_a" -ne 0 ] || [ "$status_b" -ne 0 ] \
    || [ "$diff_a" -ne 0 ] || [ "$diff_b" -ne 0 ] \
    || [ "$judge_a" -ne 0 ] || [ "$judge_b" -ne 0 ]; then
  exit 1
fi
