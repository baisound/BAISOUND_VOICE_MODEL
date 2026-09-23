#!/usr/bin/env python3
"""Minimal local GPT-SoVITS API double for the Windows client smoke test."""

from __future__ import annotations

import argparse
import io
import json
import wave
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse


def make_wav() -> bytes:
    buffer = io.BytesIO()
    with wave.open(buffer, "wb") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(32000)
        wav_file.writeframes(b"\x00\x00" * 3200)
    return buffer.getvalue()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--receipt", type=Path, required=True)
    args = parser.parse_args()

    events: list[dict[str, object]] = []

    def write_receipt() -> None:
        args.receipt.write_text(
            json.dumps({"events": events}, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, _format: str, *_args: object) -> None:
            return

        def send_bytes(self, status: int, content_type: str, data: bytes) -> None:
            self.send_response(status)
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def do_GET(self) -> None:  # noqa: N802 - BaseHTTPRequestHandler API
            parsed = urlparse(self.path)
            if parsed.path == "/health":
                self.send_bytes(200, "application/json", b'{"status":"ok"}')
                return

            if parsed.path not in {"/set_gpt_weights", "/set_sovits_weights"}:
                self.send_bytes(404, "application/json", b'{"error":"not found"}')
                return

            query = parse_qs(parsed.query)
            events.append(
                {
                    "method": "GET",
                    "path": parsed.path,
                    "weights_path": query.get("weights_path", [""])[0],
                }
            )
            write_receipt()
            self.send_bytes(200, "application/json", b'{"message":"success"}')

        def do_POST(self) -> None:  # noqa: N802 - BaseHTTPRequestHandler API
            if self.path != "/tts":
                self.send_bytes(404, "application/json", b'{"error":"not found"}')
                return

            length = int(self.headers.get("Content-Length", "0"))
            payload = json.loads(self.rfile.read(length).decode("utf-8"))
            events.append({"method": "POST", "path": "/tts", "payload": payload})
            write_receipt()
            self.send_bytes(200, "audio/wav", make_wav())

    server = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f"READY http://{args.host}:{args.port}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
