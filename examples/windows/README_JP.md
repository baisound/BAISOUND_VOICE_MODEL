# Windows向けGPT-SoVITS API起動例

この例は、BAISOUND Voice ModelのStableモデルを、Windows上のGPT-SoVITS公式`api_v2.py`でローカル実行するための補助ファイルです。GPT-SoVITS本体、v2Pro用pretrained model、Python環境、利用許諾のある参照音声は別途必要です。

## 1. 設定ファイルを作る

PowerShellでこのディレクトリへ移動し、設定例をローカル設定へコピーします。

```powershell
Copy-Item .\BAISOUND-API-SETTINGS.example.ps1 .\BAISOUND-API-SETTINGS.local.ps1
```

`BAISOUND-API-SETTINGS.local.ps1`を開き、次の値を設定します。

| 設定 | 内容 |
|---|---|
| `BAISOUND_GPTSOVITS_ROOT` | GPT-SoVITSリポジトリのルート |
| `BAISOUND_GPTSOVITS_PYTHON` | GPT-SoVITS環境の`python.exe` |
| `BAISOUND_VOICE_MODEL_ROOT` | このリポジトリのルート |
| `BAISOUND_REFERENCE_WAV` | 利用許諾のある参照音声 |
| `BAISOUND_REFERENCE_TEXT` | 参照音声の内容と完全に一致する文字列 |

ローカル設定はGitの対象外です。参照音声や個人環境のパスをcommitしないでください。

## 2. APIを起動する

`START_BAISOUND_API.bat`をダブルクリックするか、PowerShellから実行します。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\Start-BAISoundApi.ps1
```

起動スクリプトはStableモデル、v2Pro、BERT、CNHuBERTを検証し、一時ディレクトリへ実行用YAMLを作成して、公式`api_v2.py`を`127.0.0.1:9880`で起動します。

## 3. WAVを生成する

APIを起動したまま、別のPowerShellで実行します。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\Invoke-BAISoundTts.ps1 `
  -Text "朝の光が静かな街をやさしく照らします。" `
  -Output "$env:USERPROFILE\Downloads\baisound-voice.wav" `
  -Play
```

クライアントはStableモデルを明示的に選択し、参照音声と参照文字列を使って`POST /tts`を呼びます。出力がRIFF/WAVEであることを検証し、SHA-256を表示します。同じAPIプロセスで繰り返し生成し、モデルの再選択を省略する場合は`-SkipModelSwitch`を指定できます。

## 自動検証の範囲

GitHub ActionsのWindowsジョブでは、ローカルの模擬APIを使い、モデル切替リクエスト、UTF-8の日本語本文、参照音声パス、参照文、WAV保存とRIFF/WAVE検証を実際に通します。これにより、Windowsクライアントの通信仕様とファイル出力の破損を検出します。

このスモークテストはGPU推論品質を判定するものではありません。実モデルによる生成結果は、公開サンプルとリリース前の実機検証で別途確認します。

## セキュリティ

- この例はloopbackアドレスだけを許可します。
- GPT-SoVITSの上流APIをインターネットへ直接公開しないでください。
- 参照音声、文字起こし、生成音声をGitへcommitしないでください。
- 公開物には[利用・悪用防止ガイドライン](../../docs/USAGE_POLICY_JP.md)と、必要なクレジットを適用してください。

## 公式仕様

- [GPT-SoVITS](https://github.com/RVC-Boss/GPT-SoVITS)
- [GPT-SoVITS `api_v2.py`](https://github.com/RVC-Boss/GPT-SoVITS/blob/main/api_v2.py)
