#!/usr/bin/env python3
from __future__ import annotations
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
manifest_path = ROOT / "manifests" / "checkpoints.json"

def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

data = json.loads(manifest_path.read_text(encoding="utf-8"))
items = data.get("checkpoints") or []

if data.get("schema") != "baisound.voice-model.checkpoint-manifest.v1":
    raise SystemExit("FAIL: unsupported manifest schema")

errors = []
for item in items:
    rel = item["file"]
    path = ROOT / rel
    if not path.exists():
        errors.append(f"missing: {rel}")
        continue
    actual_size = path.stat().st_size
    actual_sha = sha256_file(path)
    if actual_size != item["bytes"]:
        errors.append(f"size mismatch: {rel}")
    if actual_sha != item["sha256"]:
        errors.append(f"sha256 mismatch: {rel}")

if len(items) != 7:
    errors.append(f"expected 7 checkpoints, got {len(items)}")

if errors:
    for e in errors:
        print("FAIL:", e)
    raise SystemExit(1)

print("MANIFEST VERIFY: PASS")
