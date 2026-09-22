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
bash install/wsl/install-model.sh /path/to/model-directory stable
```

Experimental profileを明示的に使う場合:

```bash
bash install/wsl/install-model.sh /path/to/model-directory signature-preview
```

## Windows PowerShell

```powershell
git lfs pull
powershell -ExecutionPolicy Bypass -File .\install\windows\Install-Model.ps1 `
  -Destination C:\Models\BAISOUND `
  -Profile stable
```

Installerは現在のclone内の検証済みmodel bytesをコピーします。Runtimeや第三者依存は自動取得しません。
