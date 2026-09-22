#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
METADATA_PATH = ROOT / "samples/public/baisound-narration-sample-v2.json"
EXPECTED_AUDIO_PATH = "samples/public/baisound-narration-sample-v2.wav"
POINTER_PATTERN = re.compile(
    rb"\Aversion https://git-lfs.github.com/spec/v1\n"
    rb"oid sha256:([0-9a-f]{64})\n"
    rb"size ([0-9]+)\n?\Z"
)


def fail(message: str) -> None:
    raise SystemExit(f"FAIL: {message}")


def main() -> None:
    data = json.loads(METADATA_PATH.read_text(encoding="utf-8"))

    if data.get("schema") != "baisound.voice-model.public-sample.v1":
        fail("unexpected public sample schema")
    if data.get("publication_authorization", {}).get("status") != "owner-approved":
        fail("public sample is not owner-approved")
    if data.get("contains_reference_audio") is not False:
        fail("public sample must declare contains_reference_audio=false")

    audio = data.get("audio", {})
    if audio.get("path") != EXPECTED_AUDIO_PATH:
        fail("unexpected public sample audio path")

    audio_path = (ROOT / EXPECTED_AUDIO_PATH).resolve()
    if ROOT not in audio_path.parents:
        fail("public sample path escapes repository")
    if not audio_path.is_file():
        fail("public sample WAV is missing")

    payload = audio_path.read_bytes()
    pointer = POINTER_PATTERN.fullmatch(payload)

    if pointer:
        actual_sha256 = pointer.group(1).decode("ascii")
        actual_bytes = int(pointer.group(2))
        mode = "lfs-pointer"
    else:
        actual_sha256 = hashlib.sha256(payload).hexdigest()
        actual_bytes = len(payload)
        mode = "hydrated-wav"
        if len(payload) < 44 or payload[:4] != b"RIFF" or payload[8:12] != b"WAVE":
            fail("hydrated public sample is not RIFF/WAVE")

    if actual_sha256 != audio.get("sha256"):
        fail("public sample SHA-256 mismatch")
    if actual_bytes != audio.get("bytes"):
        fail("public sample byte size mismatch")

    print(f"PASS: public sample metadata ({mode})")


if __name__ == "__main__":
    main()
