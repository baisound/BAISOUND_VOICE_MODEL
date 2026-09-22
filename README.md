# BAISOUND Voice Model

BAISOUND向けにファインチューニングされたGPT-SoVITSモデルを、一般利用向けの名前・バージョン・チェックサムとともに管理する配布リポジトリです。

## Latest stable release

Stable release: **v2.0.0**

| Component | File | Bytes | SHA-256 |
|---|---|---:|---|
| SoVITS | `models/stable/v2/baisound-voice-v2-sovits.pth` | 134,946,675 | `76a492931f97cd349c6d7d6f04bab4f2442fa9890a5a40708a1d49f919f8e0ff` |
| GPT | `models/stable/v2/baisound-voice-v2-gpt.ckpt` | 155,312,966 | `4dd990db49d56bdaff6c4988635c46b58f73e1d719297570f0d361184fd60745` |

Engine compatibility: **GPT-SoVITS v2Pro**. The upstream source tree and pretrained dependencies are not vendored here.

Machine-readable entry points:

- `profiles/stable.json`
- `manifests/model-registry.json`
- `manifests/releases/v2.0.0.json`
- `checksums/SHA256SUMS.txt`

## Experimental profile

`profiles/signature-preview.json` is an experimental profile. It combines the stable GPT component with:

`models/experimental/signature-preview-v2/baisound-voice-v2-signature-preview-sovits.pth`

This preview is not the general-purpose stable recommendation. Exact greeting playback and routing policy belong to `baisound-tts-runtime`, not to this model repository.

## Preserved v1 candidates

The seven previously published v1 candidate checkpoints remain under:

```text
models/candidates/v1/
├─ sovits/
└─ gpt/
```

They were renamed in Git history with `git mv`; their bytes and LFS object identities are unchanged.

## Quick start

Install Git LFS before cloning, then hydrate the model objects:

```bash
git lfs install
git clone https://github.com/baisound/BAISOUND_VOICE_MODEL.git
cd BAISOUND_VOICE_MODEL
git lfs pull
bash scripts/verify_repository.sh
```

See:

- `docs/QUICK_START_JP.md`
- `docs/INSTALL_JP.md`
- `docs/COMPATIBILITY.md`
- `docs/VERSIONING.md`
- `docs/TROUBLESHOOTING.md`

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

## Licensing

Repository content and model weights are not automatically granted an open-source or public-redistribution license. Read `LICENSE.md`, `MODEL_LICENSE.md`, and `THIRD_PARTY_NOTICES.md` before use or redistribution.
