# クイックスタート

このページはモデルの取得と検証だけを短くまとめています。初めての方は[初心者向け利用ガイド](BEGINNER_GUIDE_JP.md)、RuntimeやAPIへ組み込む方は[開発者向け統合ガイド](DEVELOPER_GUIDE_JP.md)を先に確認してください。

## 1. 取得

Git LFSを有効化してリポジトリをcloneします。

```bash
git lfs install
git clone https://github.com/baisound/BAISOUND_VOICE_MODEL.git
cd BAISOUND_VOICE_MODEL
git lfs pull
```

リポジトリへのアクセス権と、モデル利用・再配布に必要な許諾は別です。利用前に`MODEL_LICENSE.md`を確認してください。

## 2. 検証

```bash
bash scripts/verify_repository.sh
python3 scripts/verify_profile.py profiles/stable.json
```

## 3. Stableモデル

```text
models/stable/v2/baisound-voice-v2-sovits.pth
models/stable/v2/baisound-voice-v2-gpt.ckpt
```

GPT-SoVITS v2Pro互換Runtimeで上記2ファイルを指定します。Runtime本体、pretrained model、Python環境はこのリポジトリに含まれません。

音声生成には、利用許諾のある参照音声と、その内容に一致する正確な文字起こしも必要です。
