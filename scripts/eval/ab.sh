#!/usr/bin/env bash
# Run the same local fixture once without the plugin and once with it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUNNER="$ROOT/scripts/eval/run.sh"
OUT_ROOT="${EVAL_OUT:-$ROOT/.eval-runs/ab}"

usage() {
  cat <<'EOF'
Usage: scripts/eval/ab.sh [run.sh options] <scenario|all>

Runs a paired comparison:
  control - installed plugins isolated, no treatment plugin
  method  - only the staged copilot-coder treatment plugin

Custom instructions are disabled in both arms by default. Pass
--with-custom-instructions to enable them symmetrically.

Examples:
  scripts/eval/ab.sh s7-scope-overreach
  scripts/eval/ab.sh --judge auto all

A/B options:
  --seed <n>    Seed used to assign control/method to opaque run-A/run-B labels
                (default: current epoch seconds)
  --out <dir>   Root for paired artifacts (default: .eval-runs/ab)

`--control` and `--judge-label` are managed by this harness and are rejected.
EOF
}

if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
  exit 0
fi

seed="${AB_SEED:-$(date +%s)}"
args=()
scenario=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --seed) seed="${2:?--seed needs a value}"; shift 2;;
    --out) OUT_ROOT="${2:?--out needs a value}"; shift 2;;
    --model|--agent|--judge)
      args+=("$1" "${2:?$1 needs a value}")
      shift 2
      ;;
    --no-agent|--with-custom-instructions)
      args+=("$1")
      shift
      ;;
    --control|--judge-label)
      echo "error: $1 is managed by the paired harness" >&2
      exit 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [ -n "$scenario" ]; then
        echo "error: multiple scenarios supplied: '$scenario' and '$1'" >&2
        exit 2
      fi
      scenario="$1"
      shift
      ;;
  esac
done
[ -n "$scenario" ] || { usage >&2; exit 2; }

assignment="$(python3 - "$seed" <<'PY'
import random, sys
random.seed(sys.argv[1])
print("control,method" if random.randrange(2) == 0 else "method,control")
PY
)"
arm_a="${assignment%,*}"
arm_b="${assignment#*,}"

stamp="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT_ROOT/$scenario"
out="$(mktemp -d "$OUT_ROOT/$scenario/${stamp}.XXXXXX")"
run_arm() {
  local arm="$1" label="$2"
  local control=()
  [ "$arm" = control ] && control=(--control)
  "$RUNNER" "${control[@]}" --judge-label "$label" --out "$out/$label" "${args[@]}" "$scenario"
}

run_arm "$arm_a" run-A
run_arm "$arm_b" run-B

python3 - "$out/arm-map.json" "$seed" "$arm_a" "$arm_b" <<'PY'
import json, sys
path, seed, arm_a, arm_b = sys.argv[1:]
with open(path, "w") as fh:
    json.dump({"seed": seed, "run-A": arm_a, "run-B": arm_b}, fh, indent=2)
    fh.write("\n")
PY

printf '\nPaired artifacts (judge saw only opaque labels):\n'
printf '  run-A: %s\n  run-B: %s\n  mapping: %s\n' "$out/run-A" "$out/run-B" "$out/arm-map.json"
