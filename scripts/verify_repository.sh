#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
fail=0

echo "== Required tools =="
for cmd in git git-lfs python3 sha256sum; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "PASS: $cmd"
  else
    echo "FAIL: missing $cmd"
    fail=1
  fi
done

echo
echo "== Public model counts =="
declare -A expected=(
  [models/candidates/v1/sovits]=4
  [models/candidates/v1/gpt]=3
  [models/stable/v2]=2
  [models/experimental/signature-preview-v2]=1
)
for dir in "${!expected[@]}"; do
  count="$(find "$dir" -maxdepth 1 -type f \( -name '*.pth' -o -name '*.ckpt' \) | wc -l)"
  if [ "$count" -eq "${expected[$dir]}" ]; then
    echo "PASS: $dir = $count"
  else
    echo "FAIL: $dir expected ${expected[$dir]}, got $count"
    fail=1
  fi
done

echo
echo "== Public naming =="
if find models -type f -printf '%P\n' | grep -Eiq 'TASK-?[0-9]+|TASK-XXX|FRESH|C04|C09|e4_s192|e6_s288'; then
  echo "FAIL: internal identifier found in public model path"
  find models -type f -printf '%P\n' | grep -Ei 'TASK-?[0-9]+|TASK-XXX|FRESH|C04|C09|e4_s192|e6_s288' || true
  fail=1
else
  echo "PASS: no internal identifier in public model paths"
fi

echo
echo "== Forbidden private/runtime files =="
approved_audio='./samples/public/baisound-narration-sample-v2.wav'
unexpected_audio="$(
  find . -path './.git' -prune -o -type f \
    \( -iname '*.wav' -o -iname '*.flac' -o -iname '*.mp3' -o -iname '*.m4a' \) \
    -print | grep -Fvx "$approved_audio" || true
)"
if [ -n "$unexpected_audio" ]; then
  echo "FAIL: unapproved audio file found"
  printf '%s\n' "$unexpected_audio"
  fail=1
else
  echo "PASS: only the owner-approved public sample is present"
fi
if find . -path './.git' -prune -o -type f \( -iname '*.pem' -o -iname '*.key' \) -print | grep -q .; then
  echo "FAIL: credential file found"
  fail=1
else
  echo "PASS: no credential files"
fi

echo
echo "== Git LFS =="
for ext in pth ckpt safetensors; do
  if grep -q "^\*\.$ext .*filter=lfs" .gitattributes; then
    echo "PASS: *.$ext policy"
  else
    echo "FAIL: *.$ext policy missing"
    fail=1
  fi
done
if grep -q '^samples/public/\*\.wav .*filter=lfs' .gitattributes; then
  echo "PASS: public WAV LFS policy"
else
  echo "FAIL: public WAV LFS policy missing"
  fail=1
fi
while IFS= read -r file; do
  [ -z "$file" ] && continue
  attr="$(git check-attr filter -- "$file" | awk -F': ' '{print $3}')"
  if [ "$attr" = "lfs" ]; then
    echo "PASS LFS attr: $file"
  else
    echo "FAIL LFS attr: $file -> $attr"
    fail=1
  fi
done < <(
  find models -type f \( -name '*.pth' -o -name '*.ckpt' -o -name '*.safetensors' \) -print
  find samples/public -maxdepth 1 -type f -name '*.wav' -print
)

echo
echo "== Manifests and profiles =="
python3 scripts/verify_manifest.py || fail=1
python3 scripts/verify_profile.py profiles/stable.json || fail=1
python3 scripts/verify_profile.py profiles/signature-preview.json || fail=1
python3 scripts/verify_public_sample.py || fail=1

echo
echo "== Checksums =="
sha256sum -c checksums/SHA256SUMS.txt || fail=1

if [ "$fail" -ne 0 ]; then
  echo "VERIFY: FAIL"
  exit 1
fi
echo "VERIFY: PASS"
