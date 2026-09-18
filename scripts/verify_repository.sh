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
    echo "FAIL: $cmd missing"
    fail=1
  fi
done

echo
echo "== Forbidden private/audio files =="
for pattern in '*.wav' '*.flac' '*.mp3' '*.m4a' '*.pem' '*.key'; do
  if find . -path './.git' -prune -o -type f -name "$pattern" -print | grep -q .; then
    echo "FAIL: found forbidden file pattern $pattern"
    find . -path './.git' -prune -o -type f -name "$pattern" -print
    fail=1
  else
    echo "PASS: no $pattern"
  fi
done

echo
echo "== Checkpoint count =="
sovits_count="$(find models/candidates/sovits -maxdepth 1 -type f -name '*.pth' | wc -l)"
gpt_count="$(find models/candidates/gpt -maxdepth 1 -type f -name '*.ckpt' | wc -l)"
echo "SoVITS: $sovits_count"
echo "GPT:    $gpt_count"

if [ "$sovits_count" -ne 4 ]; then
  echo "FAIL: expected 4 SoVITS checkpoints"
  fail=1
fi
if [ "$gpt_count" -ne 3 ]; then
  echo "FAIL: expected 3 GPT checkpoints"
  fail=1
fi

echo
echo "== Git LFS attributes =="
for ext in pth ckpt safetensors onnx bin; do
  if grep -q "^\*\.$ext .*filter=lfs" .gitattributes; then
    echo "PASS: *.$ext"
  else
    echo "FAIL: *.$ext is not tracked by LFS policy"
    fail=1
  fi
done

if [ -d .git ]; then
  echo
  echo "== Git LFS tracked files =="
  git lfs ls-files || true

  # If model files are staged/tracked, assert the filter attribute is LFS.
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    attr="$(git check-attr filter -- "$f" | awk -F': ' '{print $3}')"
    if [ "$attr" = "lfs" ]; then
      echo "PASS LFS attr: $f"
    else
      echo "FAIL LFS attr: $f -> $attr"
      fail=1
    fi
  done < <(find models/candidates -type f \( -name '*.pth' -o -name '*.ckpt' \) -print)
fi

echo
echo "== Manifest =="
if [ -f manifests/checkpoints.json ]; then
  python3 scripts/verify_manifest.py
else
  echo "FAIL: manifests/checkpoints.json missing"
  fail=1
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "VERIFY: FAIL"
  exit 1
fi
echo "VERIFY: PASS"
