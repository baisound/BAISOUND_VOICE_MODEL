#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

for cmd in git git-lfs python3 sha256sum; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: required command not found: $cmd" >&2
    exit 2
  }
done

if [ ! -d .git ]; then
  git init -b main
fi

git lfs install --local
git lfs track "*.pth" "*.ckpt" "*.safetensors" "*.onnx" "*.bin" >/dev/null

echo "Repository initialized: $ROOT"
echo "Next: hydrate LFS objects and run bash scripts/verify_repository.sh"
