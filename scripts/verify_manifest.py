#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = ROOT / "manifests" / "model-registry.json"
FORBIDDEN_PUBLIC_NAME = re.compile(r"TASK-?\d+|TASK-XXX", re.IGNORECASE)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


data = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
errors: list[str] = []
if data.get("schema") != "baisound.voice-model.registry.v1":
    errors.append("unsupported registry schema")

models = data.get("models") or []
paths: set[str] = set()
filenames: set[str] = set()
status_counts: Counter[str] = Counter()

for model in models:
    rel = model.get("path", "")
    public_filename = model.get("public_filename", "")
    status_counts[model.get("status", "")] += 1
    if rel in paths:
        errors.append(f"duplicate path: {rel}")
    paths.add(rel)
    if public_filename in filenames:
        errors.append(f"duplicate public filename: {public_filename}")
    filenames.add(public_filename)
    if FORBIDDEN_PUBLIC_NAME.search(rel) or FORBIDDEN_PUBLIC_NAME.search(public_filename):
        errors.append(f"internal task name in public path: {rel}")

    path = ROOT / rel
    if not path.is_file():
        errors.append(f"missing: {rel}")
        continue
    if path.stat().st_size != model.get("bytes"):
        errors.append(f"size mismatch: {rel}")
    if sha256_file(path) != model.get("sha256"):
        errors.append(f"sha256 mismatch: {rel}")

expected = Counter({"STABLE": 2, "CANDIDATE": 7, "EXPERIMENTAL": 1})
if status_counts != expected:
    errors.append(f"unexpected status counts: {dict(status_counts)}")

if errors:
    for error in errors:
        print("FAIL:", error)
    raise SystemExit(1)

print("MANIFEST VERIFY: PASS")
