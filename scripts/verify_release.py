#!/usr/bin/env python3
"""Verify a release manifest against LFS content, profile, registry, and docs."""

from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
POINTER_PATTERN = re.compile(
    rb"\Aversion https://git-lfs.github.com/spec/v1\n"
    rb"oid sha256:([0-9a-f]{64})\n"
    rb"size ([0-9]+)\n?\Z"
)


def fail(message: str) -> None:
    raise SystemExit(f"FAIL: {message}")


def file_identity(path: Path) -> tuple[int, str, str]:
    payload = path.read_bytes()
    pointer = POINTER_PATTERN.fullmatch(payload)
    if pointer:
        return int(pointer.group(2)), pointer.group(1).decode("ascii"), "lfs-pointer"
    return len(payload), hashlib.sha256(payload).hexdigest(), "hydrated"


def main() -> None:
    if len(sys.argv) != 2:
        fail("usage: verify_release.py manifests/releases/vX.Y.Z.json")

    manifest_path = (ROOT / sys.argv[1]).resolve()
    if ROOT not in manifest_path.parents or not manifest_path.is_file():
        fail("release manifest must exist inside the repository")

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    profile = json.loads((ROOT / "profiles/stable.json").read_text(encoding="utf-8"))
    registry = json.loads(
        (ROOT / "manifests/model-registry.json").read_text(encoding="utf-8")
    )

    if manifest.get("schema") != "baisound.voice-model.release.v1":
        fail("unsupported release manifest schema")
    version = manifest.get("release_version")
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", str(version)):
        fail("release_version must be semantic X.Y.Z")
    if profile.get("release_version") != version:
        fail("stable profile version does not match release manifest")

    registry_stable = {
        item["family"]: item
        for item in registry.get("models", [])
        if item.get("status") == "STABLE"
    }
    modes: set[str] = set()
    for family in ("gpt", "sovits"):
        item = manifest.get("models", {}).get(family)
        if not item:
            fail(f"release manifest is missing {family}")

        asset_path = (ROOT / item["path"]).resolve()
        if ROOT not in asset_path.parents or not asset_path.is_file():
            fail(f"invalid or missing {family} asset path")
        actual_bytes, actual_sha256, mode = file_identity(asset_path)
        modes.add(mode)
        if actual_bytes != item.get("bytes"):
            fail(f"{family} byte size mismatch")
        if actual_sha256 != item.get("sha256"):
            fail(f"{family} SHA-256 mismatch")

        profile_item = profile.get("models", {}).get(family, {})
        if profile_item.get("path") != item.get("path"):
            fail(f"{family} profile path mismatch")
        if profile_item.get("sha256") != item.get("sha256"):
            fail(f"{family} profile SHA-256 mismatch")

        registry_item = registry_stable.get(family, {})
        for field in ("path", "bytes", "sha256"):
            if registry_item.get(field) != item.get(field):
                fail(f"{family} registry {field} mismatch")
        if registry_item.get("release_version") != version:
            fail(f"{family} registry version mismatch")

    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    if f"Stable release: **v{version}**" not in readme:
        fail("README latest Stable release does not match")

    citation = (ROOT / "CITATION.cff").read_text(encoding="utf-8")
    if f'version: "{version}"' not in citation:
        fail("CITATION version does not match")
    if f'date-released: "{manifest.get("released_at")}"' not in citation:
        fail("CITATION release date does not match")

    print(
        f"PASS: release v{version} verified "
        f"({', '.join(sorted(modes))}; profile/registry/docs consistent)"
    )


if __name__ == "__main__":
    main()
