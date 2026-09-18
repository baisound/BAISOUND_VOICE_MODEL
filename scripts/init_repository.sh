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

# .gitattributes is canonical; these calls also verify Git LFS is operational.
git lfs track "*.pth" "*.ckpt" "*.safetensors" "*.onnx" "*.bin" >/dev/null

echo
echo "Repository initialized:"
echo "  $ROOT"
echo
echo "Next:"
echo "  bash scripts/import_task097_checkpoints.sh"
echo "  python3 scripts/generate_manifest.py"
echo "  bash scripts/verify_repository.sh"
