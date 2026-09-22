#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

: "${BAISOUND_STABLE_SOVITS_SOURCE:?set BAISOUND_STABLE_SOVITS_SOURCE}"
: "${BAISOUND_STABLE_GPT_SOURCE:?set BAISOUND_STABLE_GPT_SOURCE}"
: "${BAISOUND_SIGNATURE_PREVIEW_SOVITS_SOURCE:?set BAISOUND_SIGNATURE_PREVIEW_SOVITS_SOURCE}"

for source in \
  "$BAISOUND_STABLE_SOVITS_SOURCE" \
  "$BAISOUND_STABLE_GPT_SOURCE" \
  "$BAISOUND_SIGNATURE_PREVIEW_SOVITS_SOURCE"; do
  [ -f "$source" ] || { echo "ERROR: missing source: $source" >&2; exit 3; }
done

mkdir -p \
  "$ROOT/models/stable/v2" \
  "$ROOT/models/experimental/signature-preview-v2"

cp -p -- "$BAISOUND_STABLE_SOVITS_SOURCE" \
  "$ROOT/models/stable/v2/baisound-voice-v2-sovits.pth"
cp -p -- "$BAISOUND_STABLE_GPT_SOURCE" \
  "$ROOT/models/stable/v2/baisound-voice-v2-gpt.ckpt"
cp -p -- "$BAISOUND_SIGNATURE_PREVIEW_SOVITS_SOURCE" \
  "$ROOT/models/experimental/signature-preview-v2/baisound-voice-v2-signature-preview-sovits.pth"

echo "Imported approved stable and experimental public models."
