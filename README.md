# BAISOUND Voice Model

## このプロダクトは何？

**BAISOUND Voice Model**は、入力した文章をBAISOUNDの声で読み上げるために、GPT-SoVITS v2Pro向けにファインチューニングされた音声合成モデルです。

Stable版は、文章の読み方や流れを組み立てるGPTモデル（`.ckpt`）と、音声を生成するSoVITSモデル（`.pth`）の2ファイルを1組として使用します。このリポジトリは、そのモデル本体に加えて、バージョン情報、チェックサム、互換性情報、導入用スクリプトを配布します。

このリポジトリだけでは音声を再生できません。画面や読み上げボタンを備えた単体アプリではなく、次のように**GPT-SoVITS v2Pro互換Runtime**と組み合わせて使う製品です。

```text
文章 + 利用許諾のある参照音声 + 正確な文字起こし
                         ↓
             GPT-SoVITS v2Pro Runtime
                 ├─ GPTモデル（.ckpt）
                 └─ SoVITSモデル（.pth）
                         ↓
                      WAV音声
                         ↓
        再生 / 動画編集 / 配信 / 自作アプリ
```

参照音声、参照音声の文字起こし、GPT-SoVITS本体、第三者のpretrained model、再生アプリは、このリポジトリには含まれません。

## どこから読めばよい？

- **初めて音声AIモデルを使う方**：[初心者向け利用ガイド](docs/BEGINNER_GUIDE_JP.md)
- **組み込み・API連携を行う開発者**：[開発者向け統合ガイド](docs/DEVELOPER_GUIDE_JP.md)
- **モデルをすぐ取得したい方**：[クイックスタート](docs/QUICK_START_JP.md)
- **詳しい導入条件を確認したい方**：[インストール](docs/INSTALL_JP.md) / [互換性](docs/COMPATIBILITY.md)
- **モデルの用途・制約を確認したい方**：[Model Card](MODEL_CARD.md)

## ほかのソフトとの組み合わせ方

モデルファイルを各ソフトへ直接読み込ませるのではなく、GPT-SoVITS互換RuntimeでWAVを生成してから渡すか、ローカルAPIを介して接続します。

| やりたいこと | 組み合わせ方 |
|---|---|
| 画面から文章を読み上げる | GPT-SoVITSの推論WebUIで2つのモデルと参照音声を読み込み、文章を入力する |
| DaVinci Resolve、Premiere Pro、DAWで使う | RuntimeでWAVを書き出し、通常の音声素材として読み込む |
| OBSやStream Deckから読み上げる | ボタンやスクリプトからローカルTTS Runtime/APIを呼び、生成WAVを再生する |
| Webアプリ、Bot、自作ツールへ組み込む | アプリからローカルのGPT-SoVITS APIへ文章を送り、返されたWAVを保存または再生する |
| ゲームへ組み込む | 事前生成したWAVを音声アセットにするか、許諾範囲内でバックエンドのTTS Runtimeと接続する |

具体的な操作は[初心者向け利用ガイド](docs/BEGINNER_GUIDE_JP.md)、構成例とAPIコードは[開発者向け統合ガイド](docs/DEVELOPER_GUIDE_JP.md)を参照してください。

> [!IMPORTANT]
> リポジトリを閲覧・cloneできることと、モデルを利用・再配布・製品搭載できることは別です。作業前に[LICENSE.md](LICENSE.md)、[MODEL_LICENSE.md](MODEL_LICENSE.md)、[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)を確認してください。

## Latest stable release

Stable release: **v2.0.0**

| Component | File | Bytes | SHA-256 |
|---|---|---:|---|
| SoVITS | `models/stable/v2/baisound-voice-v2-sovits.pth` | 134,946,675 | `76a492931f97cd349c6d7d6f04bab4f2442fa9890a5a40708a1d49f919f8e0ff` |
| GPT | `models/stable/v2/baisound-voice-v2-gpt.ckpt` | 155,312,966 | `4dd990db49d56bdaff6c4988635c46b58f73e1d719297570f0d361184fd60745` |

Engine compatibility: **GPT-SoVITS v2Pro**. The upstream source tree and pretrained dependencies are not vendored here.

## モデルを取得する

Git LFSをインストールしてからcloneし、実体ファイルを取得します。

```bash
git lfs install
git clone https://github.com/baisound/BAISOUND_VOICE_MODEL.git
cd BAISOUND_VOICE_MODEL
git lfs pull
bash scripts/verify_repository.sh
```

Stable版で使うファイルは次の2つです。

```text
models/stable/v2/baisound-voice-v2-sovits.pth
models/stable/v2/baisound-voice-v2-gpt.ckpt
```

この手順はモデルを取得・検証するところまでです。音声の生成には、別途GPT-SoVITS v2Pro互換Runtimeと、利用許諾のある参照音声および正確な文字起こしが必要です。

Machine-readable entry points:

- `profiles/stable.json`
- `manifests/model-registry.json`
- `manifests/releases/v2.0.0.json`
- `checksums/SHA256SUMS.txt`

## Experimental profile

`profiles/signature-preview.json` is an experimental profile. It combines the stable GPT component with:

`models/experimental/signature-preview-v2/baisound-voice-v2-signature-preview-sovits.pth`

This preview is not the general-purpose stable recommendation. Exact greeting playback and routing policy belong to a separate TTS Runtime, not to this model repository.

## Preserved v1 candidates

The seven previously published v1 candidate checkpoints remain under:

```text
models/candidates/v1/
├─ sovits/
└─ gpt/
```

They were renamed in Git history with `git mv`; their bytes and LFS object identities are unchanged.

## Repository boundary

This repository contains approved public model weights, public-safe manifests, profiles, checksums, and helper scripts. It intentionally excludes:

- raw or reference voice audio;
- private training, validation, and test data;
- private transcripts and blind-review mappings;
- GPT-SoVITS source code and pretrained dependencies;
- Conda/Python environments, caches, logs, and generated WAV files;
- TTS server, queue, playback, and product integration code.

## Git LFS

Model binaries are managed by Git LFS. Verify with:

```bash
git lfs ls-files
```

モデルファイルが約130バイトしかない場合は、実体ではなくLFS pointerだけが取得されています。`git lfs pull`を実行してください。

## Licensing

Repository content and model weights are not automatically granted an open-source or public-redistribution license. Read [LICENSE.md](LICENSE.md), [MODEL_LICENSE.md](MODEL_LICENSE.md), and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) before use or redistribution.
