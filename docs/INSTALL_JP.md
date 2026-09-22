# インストール

## 必要条件

- Git
- Git LFS
- SHA-256を計算できる環境
- GPT-SoVITS v2Pro互換Runtime

## WSL / Linux

clone後にLFS objectを取得し、ローカルRuntime用ディレクトリへコピーできます。

```bash
git lfs pull
export BAISOUND_MODEL_DESTINATION="${BAISOUND_MODEL_DESTINATION:?set BAISOUND_MODEL_DESTINATION}"
bash install/wsl/install-model.sh "$BAISOUND_MODEL_DESTINATION" stable
```

Experimental profileを明示的に使う場合:

```bash
bash install/wsl/install-model.sh "$BAISOUND_MODEL_DESTINATION" signature-preview
```

## Windows PowerShell

```powershell
git lfs pull
if (-not $env:BAISOUND_MODEL_DESTINATION) { throw "Set BAISOUND_MODEL_DESTINATION" }
powershell -ExecutionPolicy Bypass -File .\install\windows\Install-Model.ps1 `
  -Destination $env:BAISOUND_MODEL_DESTINATION `
  -Profile stable
```

Installerは現在のclone内の検証済みmodel bytesをコピーします。Runtimeや第三者依存は自動取得しません。
