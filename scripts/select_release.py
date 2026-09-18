#!/usr/bin/env python3
from __future__ import annotations
import argparse
import json
from pathlib import Path
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
manifest_path = ROOT / "manifests" / "checkpoints.json"
selection_path = ROOT / "models" / "release" / "v1" / "selection.json"

ap = argparse.ArgumentParser()
ap.add_argument("--sovits", required=True, help="SoVITS candidate basename")
ap.add_argument("--gpt", required=True, help="GPT candidate basename")
ap.add_argument("--evaluation-reference", required=True)
ap.add_argument("--selected-by", default="OWNER")
args = ap.parse_args()

manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
by_name = {Path(x["file"]).name: x for x in manifest["checkpoints"]}

if args.sovits not in by_name or by_name[args.sovits]["family"] != "sovits":
    raise SystemExit(f"Unknown SoVITS candidate: {args.sovits}")
if args.gpt not in by_name or by_name[args.gpt]["family"] != "gpt":
    raise SystemExit(f"Unknown GPT candidate: {args.gpt}")

selection = {
    "schema": "baisound.voice-model.release-selection.v1",
    "release": "v1",
    "status": "DESIGNATED",
    "sovits_checkpoint": by_name[args.sovits],
    "gpt_checkpoint": by_name[args.gpt],
    "evaluation_reference": args.evaluation_reference,
    "selected_at": datetime.now(timezone.utc).isoformat(),
    "selected_by": args.selected_by,
}

selection_path.write_text(json.dumps(selection, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"WROTE: {selection_path}")
