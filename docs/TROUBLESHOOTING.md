# Troubleshooting

## Model file is about 130 bytes

Git LFS pointerだけがcheckoutされています。

```bash
git lfs install
git lfs pull
```

## Checksum mismatch

ファイルを使用せず、`git status`と`git lfs status`を確認してください。その後、対象LFS objectを再取得して`bash scripts/verify_repository.sh`を実行します。

## Runtime cannot load the model

Stable profileが指定するSoVITS/GPTの両方を取得し、GPT-SoVITS v2Pro互換Runtimeを使用しているか確認してください。

## Experimental model was loaded as stable

`profiles/stable.json`を正本として設定し直してください。Signature previewはExperimental channelであり、一般用途の既定値ではありません。
