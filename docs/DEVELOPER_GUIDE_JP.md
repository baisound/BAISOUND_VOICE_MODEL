# BAISOUND Voice Model 開発者向け統合ガイド

このページは、BAISOUND Voice ModelをGPT-SoVITSへ組み込み、ローカルAPI、制作ツール、配信ツール、自作アプリから利用する開発者向けです。一般利用者向けの説明は[初心者向け利用ガイド](BEGINNER_GUIDE_JP.md)を参照してください。

## 統合対象と責務

このリポジトリが提供するのは、モデル重みと、その組み合わせを機械可読にするメタデータです。推論サーバー、参照音声、音声再生、キュー、認証、公開APIは提供しません。

```text
Client / Editor / Stream Deck / Game
                 ↓ text
       Integration or Queue Layer
                 ↓
     Local GPT-SoVITS v2Pro Runtime
        ├─ BAISOUND GPT checkpoint
        ├─ BAISOUND SoVITS checkpoint
        ├─ authorized reference audio
        └─ exact reference transcript
                 ↓ audio/wav
        Save / Play / Import / Cache
```

## Compatibility baseline

| 項目 | 値 |
|---|---|
| Model ID | `baisound-voice` |
| Stable release | `2.0.0` |
| Engine | GPT-SoVITS |
| Engine line | `v2Pro` |
| Recorded upstream commit | `48b1a0169a28582a8984402f82cf438d3bfa6aca` |
| Distribution | Git LFS managed `.ckpt` + `.pth` |

学習時の基準は[training-basis.json](../manifests/training-basis.json)に記録されています。GPT-SoVITSの`main`は更新されるため、導入時は記録済みコミットを基準に互換性を確認し、別revisionを採用する場合はモデルロードと代表文章の回帰テストを実施してください。

## 1. 取得と検証

```bash
git lfs install
git clone https://github.com/baisound/BAISOUND_VOICE_MODEL.git
cd BAISOUND_VOICE_MODEL
git lfs pull
bash scripts/verify_repository.sh
python3 scripts/verify_profile.py profiles/stable.json
```

CIやコンテナでLFSを取得しない場合、checkoutされるモデルファイルはpointerです。推論を行うジョブだけでLFS objectをhydrateしてください。

## 2. Stable profileを統合契約にする

ファイル名や旧学習時のartifact名をコードへ直接埋め込まず、`profiles/stable.json`を読みます。

```python
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path

repo = Path(os.environ["BAISOUND_VOICE_MODEL_ROOT"]).expanduser().resolve()
profile = json.loads((repo / "profiles/stable.json").read_text(encoding="utf-8"))


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


resolved = {}
for component in ("gpt", "sovits"):
    entry = profile["models"][component]
    path = (repo / entry["path"]).resolve()
    if not path.is_relative_to(repo):
        raise RuntimeError(f"model path escapes repository: {path}")
    if sha256(path) != entry["sha256"]:
        raise RuntimeError(f"checksum mismatch: {path}")
    resolved[component] = path

print(resolved)
```

WindowsでPython 3.8以前を使用する場合は、`Path.is_relative_to()`相当の親子関係チェックへ置き換えてください。

## 3. GPT-SoVITSへロードする

### WebUIを使う場合

1. [GPT-SoVITS公式リポジトリ](https://github.com/RVC-Boss/GPT-SoVITS)の手順でRuntimeとv2Pro用pretrained modelを用意します。
2. Runtimeのモデルバージョンを`v2Pro`にします。
3. GPT weightへ`profiles/stable.json`の`gpt.path`を指定します。
4. SoVITS weightへ`sovits.path`を指定します。
5. 利用許諾のある参照音声、正確な参照文字列、言語を指定して推論します。

上流のpretrained modelはこのリポジトリに含まれません。必要なv2Pro依存物はGPT-SoVITS公式手順に従って取得してください。

### 公式`api_v2.py`を使う場合

GPT-SoVITS側でAPIをローカルホストへ起動します。コマンドや設定項目は上流revisionで変わり得るため、採用revisionの[`api_v2.py`](https://github.com/RVC-Boss/GPT-SoVITS/blob/main/api_v2.py)も確認してください。

```bash
python api_v2.py -a 127.0.0.1 -p 9880 -c GPT_SoVITS/configs/tts_infer.yaml
```

次は、モデルを切り替えて日本語WAVを取得する最小構成例です。`reference.wav`と`prompt_text`は、同じ音声内容に一致させてください。

```python
import os
from pathlib import Path

import requests

base_url = "http://127.0.0.1:9880"
model_repo = Path(os.environ["BAISOUND_VOICE_MODEL_ROOT"]).expanduser().resolve()
gpt = model_repo / "models/stable/v2/baisound-voice-v2-gpt.ckpt"
sovits = model_repo / "models/stable/v2/baisound-voice-v2-sovits.pth"
reference = Path(os.environ["BAISOUND_REFERENCE_WAV"]).expanduser().resolve()

for endpoint, model in (
    ("set_gpt_weights", gpt),
    ("set_sovits_weights", sovits),
):
    response = requests.get(
        f"{base_url}/{endpoint}",
        params={"weights_path": str(model)},
        timeout=120,
    )
    response.raise_for_status()

payload = {
    "text": "読み上げたい文章です。",
    "text_lang": "ja",
    "ref_audio_path": str(reference),
    "prompt_lang": "ja",
    "prompt_text": "参照音声で実際に話している文章です。",
    "text_split_method": "cut5",
    "media_type": "wav",
    "streaming_mode": False,
}

response = requests.post(f"{base_url}/tts", json=payload, timeout=300)
response.raise_for_status()
Path("baisound-output.wav").write_bytes(response.content)
```

参照音声のパスは、`api_v2.py`を実行している側から読めるパスでなければなりません。クライアントPC上のパスをそのまま渡しても、APIサーバーが別環境なら読み取れません。

## 4. ソフト別の統合パターン

| 連携先 | 推奨パターン | 実装上の注意 |
|---|---|---|
| 動画編集・DAW | 文章ごとにWAVを事前生成 | ファイル名、台本ID、話者、生成設定を対応付ける |
| OBS・配信 | ローカルAPI → 再生キュー → 音声出力 | 同時要求、連打、停止、長文分割をRuntime側で管理する |
| Stream Deck | ボタン → ローカルスクリプト → API | ボタンからモデルファイルを直接起動しない |
| Webアプリ・Bot | Backend → ローカルまたは閉域TTS API | ブラウザへモデルパスを露出しない。認証・rate limitを追加する |
| ゲーム | 固定セリフはWAV asset、動的セリフはTTS service | 配布物へ重みを同梱する場合は別途ライセンス確認が必要 |
| バッチ制作 | 台本JSON/CSV → worker → WAV + receipt | 入力、profile version、checksum、出力hashを記録する |

## 5. Runtime側で実装する項目

継続利用する製品では、モデルロードだけでなく次の境界を実装してください。

- 起動時のprofile schema、ファイル存在、SHA-256検証
- Stable/Experimental channelの明示的な分離
- 1回だけのモデルロードと、生成要求の再利用
- 入力文字数、言語、timeout、同時実行数の制限
- 長文分割、FIFOキュー、重複防止、キャンセル
- WAVの一時保存、期限付き削除、ディスク容量監視
- モデルversion、profile、request IDを含む監査可能なreceipt
- 参照音声、入力文章、生成音声をログへ不用意に残さない設計
- 代表文章によるアップグレード前後の回帰テスト

## 6. ネットワークとセキュリティ

上流の`api_v2.py`は、製品向けの認証・権限管理・rate limitを提供する公開API gatewayではありません。

- 既定は`127.0.0.1`にbindし、インターネットへ直接公開しないでください。
- 別ホストから使う場合は、認証、TLS、接続元制限、request size制限を備えたgatewayを前段に置いてください。
- 参照音声の任意パスを外部利用者に指定させないでください。
- APIエラーへローカルパスや内部構成をそのまま返さないでください。
- 入力文章、参照音声、生成音声は個人情報や機密情報として扱ってください。

## 7. VersioningとExperimental

Stable統合では`profiles/stable.json`を正本にします。`profiles/signature-preview.json`は実験用であり、Stableの代わりに自動選択しないでください。

更新時は次を確認します。

1. `release_version`と`engine_family`
2. GPT/SoVITSの両方のSHA-256
3. GPT-SoVITS Runtime revisionとpretrained dependencies
4. 代表文章、長文、固有名詞、句読点の回帰結果
5. 出力を利用するソフト側の音量、sample rate、再生動作

## 関連資料

- [README](../README.md)
- [Compatibility](COMPATIBILITY.md)
- [Versioning](VERSIONING.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Model Card](../MODEL_CARD.md)
- [Release manifest](../manifests/releases/v2.0.0.json)
- [GPT-SoVITS公式リポジトリ](https://github.com/RVC-Boss/GPT-SoVITS)
- [GPT-SoVITS公式`api_v2.py`](https://github.com/RVC-Boss/GPT-SoVITS/blob/main/api_v2.py)

## ライセンス境界

リポジトリが公開されていても、モデルの利用、再配布、サブライセンス、販売、製品搭載が自動的に許可されるわけではありません。実装・配布前に[LICENSE.md](../LICENSE.md)、[MODEL_LICENSE.md](../MODEL_LICENSE.md)、[THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md)を確認してください。
