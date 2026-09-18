#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_ROOT="${TASK097_GPTSOVITS_ROOT:-/home/baisound/BAI_AI/task097_gptsovits/GPT-SoVITS}"

SOVITS_SRC="$SOURCE_ROOT/SoVITS_weights_v2Pro"
GPT_SRC="$SOURCE_ROOT/GPT_weights_v2Pro"

SOVITS_DST="$ROOT/models/candidates/sovits"
GPT_DST="$ROOT/models/candidates/gpt"

mkdir -p "$SOVITS_DST" "$GPT_DST"

sovits=(
  "BAISOUND_TASK097_V1_e2_s100.pth"
  "BAISOUND_TASK097_V1_e4_s200.pth"
  "BAISOUND_TASK097_V1_e6_s300.pth"
  "BAISOUND_TASK097_V1_e8_s400.pth"
)

gpt=(
  "BAISOUND_TASK097_V1-e5.ckpt"
  "BAISOUND_TASK097_V1-e10.ckpt"
  "BAISOUND_TASK097_V1-e15.ckpt"
)

missing=0

for f in "${sovits[@]}"; do
  if [ ! -f "$SOVITS_SRC/$f" ]; then
    echo "MISSING: $SOVITS_SRC/$f" >&2
    missing=1
  fi
done

for f in "${gpt[@]}"; do
  if [ ! -f "$GPT_SRC/$f" ]; then
    echo "MISSING: $GPT_SRC/$f" >&2
    missing=1
  fi
done

[ "$missing" -eq 0 ] || {
  echo "ERROR: expected TASK-097 checkpoints are missing. Nothing copied." >&2
  exit 3
}

for f in "${sovits[@]}"; do
  cp -p -- "$SOVITS_SRC/$f" "$SOVITS_DST/$f"
done

for f in "${gpt[@]}"; do
  cp -p -- "$GPT_SRC/$f" "$GPT_DST/$f"
done

rm -f "$SOVITS_DST/.gitkeep" "$GPT_DST/.gitkeep"

echo "Imported 4 SoVITS + 3 GPT checkpoints."
echo "Source: $SOURCE_ROOT"
