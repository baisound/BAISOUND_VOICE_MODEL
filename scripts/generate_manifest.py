#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = ROOT / "manifests" / "model-registry.json"


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


registry = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
for model in registry["models"]:
    path = ROOT / model["path"]
    if not path.is_file():
        raise SystemExit(f"ERROR: missing model: {model['path']}")
    model["bytes"] = path.stat().st_size
    model["sha256"] = sha256_file(path)

registry["generated_at_utc"] = datetime.now(timezone.utc).isoformat()
REGISTRY_PATH.write_text(
    json.dumps(registry, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
)
print(f"WROTE: {REGISTRY_PATH}")
