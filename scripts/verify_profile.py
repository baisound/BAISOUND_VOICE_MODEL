#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


if len(sys.argv) != 2:
    raise SystemExit("usage: verify_profile.py profiles/<profile>.json")

profile_path = (ROOT / sys.argv[1]).resolve()
if ROOT not in profile_path.parents:
    raise SystemExit("profile must be inside the repository")

profile = json.loads(profile_path.read_text(encoding="utf-8"))
errors: list[str] = []
for family, item in profile.get("models", {}).items():
    path = ROOT / item["path"]
    if not path.is_file():
        errors.append(f"missing {family}: {item['path']}")
    elif sha256_file(path) != item["sha256"]:
        errors.append(f"sha256 mismatch {family}: {item['path']}")

if errors:
    for error in errors:
        print("FAIL:", error)
    raise SystemExit(1)

print(f"PROFILE VERIFY: PASS ({profile_path.relative_to(ROOT)})")
