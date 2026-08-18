#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/coder-eval-smoke.XXXXXX")"
HOST_HOME="$HOME"
cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

mkdir -p "$TMP_ROOT/bin"
cat >"$TMP_ROOT/bin/copilot" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

case " $* " in
  *" --no-auto-update "*) ;;
  *) echo "missing --no-auto-update" >&2; exit 91;;
esac
case " $* " in
  *" --secret-env-vars=COPILOT_GITHUB_TOKEN,GH_TOKEN,GITHUB_TOKEN "*) ;;
  *) echo "missing secret environment protection" >&2; exit 92;;
esac
[ -d "${GH_CONFIG_DIR:?}" ] || exit 93
[ -d "${COPILOT_HOME:?}" ] || exit 94
[ "${HOME:?}" != "${HOST_HOME:?}" ] || exit 95
[ "${GIT_TERMINAL_PROMPT:?}" = 0 ] || exit 96
[ -z "${SSH_AUTH_SOCK:-}" ] || exit 97
[ "${GIT_CONFIG_KEY_0:?}" = credential.helper ] || exit 98
printf '%s\t%s\t%s\n' "$COPILOT_HOME" "$GH_CONFIG_DIR" "$HOME" >>"${TRACE_FILE:?}"

plugin_dir=""
previous=""
judge=0
for argument in "$@"; do
  if [ "$previous" = plugin-dir ]; then
    plugin_dir="$argument"
    previous=""
    continue
  fi
  case "$argument" in
    --plugin-dir) previous=plugin-dir;;
    *"Behavioral Eval Judge"*) judge=1;;
  esac
done

case " $* " in
  *" plugin list "*)
    python3 - "$plugin_dir/.github/plugin/plugin.json" <<'PY'
import json
import sys
print("External Plugins (via --plugin-dir):")
print("  - " + json.load(open(sys.argv[1]))["name"])
PY
    ;;
  *)
    if [ "$judge" -eq 1 ]; then
      printf '%s\n' '{"correct_action":2,"evidence":2,"verification":2,"report":2,"total":8,"verdict":"pass","note":"smoke"}'
    else
      printf '%s\n' 'Smoke review completed without edits.'
    fi
    ;;
esac
SH
chmod +x "$TMP_ROOT/bin/copilot"

export PATH="$TMP_ROOT/bin:$PATH"
export COPILOT_GITHUB_TOKEN="smoke-token"
export TRACE_FILE="$TMP_ROOT/copilot-trace.tsv"
export HOST_HOME

repo="$TMP_ROOT/repo"
git init -q "$repo"
git -C "$repo" config user.name "Eval Smoke"
git -C "$repo" config user.email "eval-smoke@example.invalid"
printf 'base\n' >"$repo/service.txt"
git -C "$repo" add service.txt
git -C "$repo" commit -qm "base"
base_sha="$(git -C "$repo" rev-parse HEAD)"
printf 'head\n' >"$repo/service.txt"
git -C "$repo" commit -qam "head"
head_sha="$(git -C "$repo" rev-parse HEAD)"
git -C "$repo" diff --binary "$base_sha" "$head_sha" >"$TMP_ROOT/change.diff"

printf 'Review the supplied change and report concrete findings. Do not edit files.\n' >"$TMP_ROOT/task.md"
printf 'A correct smoke report makes no edits.\n' >"$TMP_ROOT/GROUND-TRUTH.md"

python3 - "$TMP_ROOT/catalog.json" "$repo" "$base_sha" "$head_sha" \
  "$TMP_ROOT/change.diff" "$TMP_ROOT/task.md" "$TMP_ROOT/GROUND-TRUTH.md" <<'PY'
import json
import sys

path, repo, base, head, patch, task, truth = sys.argv[1:]
with open(path, "w") as handle:
    json.dump(
        {
            "cases": {
                "head-case": {
                    "repo": repo,
                    "base_ref": base,
                    "head_ref": head,
                    "task": task,
                    "ground_truth": truth,
                    "mode": "review",
                },
                "patch-case": {
                    "repo": repo,
                    "base_ref": base,
                    "patch": patch,
                    "task": task,
                    "ground_truth": truth,
                    "mode": "review",
                },
            }
        },
        handle,
    )
PY

for case_id in head-case patch-case; do
  out="$TMP_ROOT/replay-$case_id"
  "$ROOT/scripts/eval/real-pr-replay.sh" \
    --catalog "$TMP_ROOT/catalog.json" \
    --case "$case_id" \
    --out "$out" \
    --plugin-dir "$ROOT" \
    --judge smoke \
    --seed 42
  grep -Fxq no "$out/run-A/files-changed"
  grep -Fxq no "$out/run-B/files-changed"
  test -s "$out/run-A/score.json"
  test -s "$out/run-B/score.json"
  test -s "$out/arm-map.json"
  test -s "$out/run-A/pr.diff"
done

: >"$TRACE_FILE"
EVAL_OUT="$TMP_ROOT/run-out" "$ROOT/scripts/eval/run.sh" all
home_count="$(cut -f1 "$TRACE_FILE" | sort -u | wc -l | tr -d ' ')"
[ "$home_count" -ge 4 ] || {
  echo "expected independent preflight/scenario homes, saw $home_count" >&2
  exit 1
}

if "$ROOT/scripts/eval/ab.sh" --control s7-scope-overreach >/dev/null 2>&1; then
  echo "ab.sh accepted its reserved --control option" >&2
  exit 1
fi
"$ROOT/scripts/eval/ab.sh" --out "$TMP_ROOT/ab-out" s8-missing-integration-site
find "$TMP_ROOT/ab-out" -name arm-map.json -type f | grep -q .

printf 'evaluation harness smoke tests passed\n'
