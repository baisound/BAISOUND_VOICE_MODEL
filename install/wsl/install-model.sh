#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "usage: install-model.sh DESTINATION [stable|signature-preview]" >&2
  exit 2
fi

DESTINATION="$1"
PROFILE="${2:-stable}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROFILE_PATH="$ROOT/profiles/$PROFILE.json"

[ -f "$PROFILE_PATH" ] || { echo "ERROR: unknown profile: $PROFILE" >&2; exit 3; }
python3 "$ROOT/scripts/verify_profile.py" "profiles/$PROFILE.json"
mkdir -p "$DESTINATION"

python3 - "$ROOT" "$PROFILE_PATH" "$DESTINATION" <<'PY'
import json
import shutil
import sys
from pathlib import Path

root = Path(sys.argv[1])
profile = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
destination = Path(sys.argv[3])
for model in profile["models"].values():
    source = root / model["path"]
    shutil.copy2(source, destination / source.name)
    print(f"INSTALLED: {destination / source.name}")
PY
