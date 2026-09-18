#!/usr/bin/env python3
from __future__ import annotations
import hashlib
import json
from pathlib import Path
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
MODEL_DIRS = [
    ("sovits", ROOT / "models" / "candidates" / "sovits", ".pth"),
    ("gpt", ROOT / "models" / "candidates" / "gpt", ".ckpt"),
]

def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

items = []
for family, folder, suffix in MODEL_DIRS:
    for path in sorted(folder.glob(f"*{suffix}")):
        items.append({
            "family": family,
            "file": path.relative_to(ROOT).as_posix(),
            "bytes": path.stat().st_size,
            "sha256": sha256_file(path),
        })

if not items:
    raise SystemExit("ERROR: no checkpoints found. Run import_task097_checkpoints.sh first.")

manifest = {
    "schema": "baisound.voice-model.checkpoint-manifest.v1",
    "generated_at_utc": datetime.now(timezone.utc).isoformat(),
    "project": "BAISOUND",
    "task": "TASK-097",
    "engine": "GPT-SoVITS v2Pro",
    "checkpoint_count": len(items),
    "checkpoints": items,
}

out = ROOT / "manifests" / "checkpoints.json"
out.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"WROTE: {out}")
print(f"CHECKPOINTS: {len(items)}")
