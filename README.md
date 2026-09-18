
# BAISOUND Voice Model V1

BAISOUND向け GPT-SoVITS v2Pro ファインチューニング成果物を、学習用作業ツリーから分離して管理するためのモデル・リポジトリです。

## Repository status

- Fine-tuning run: `TASK-097`
- Engine family: GPT-SoVITS v2Pro
- Current state: **candidate checkpoints preserved / final V1 pair not yet designated**
- Raw voice/audio dataset: **NOT stored in this repository**
- Upstream GPT-SoVITS source tree: **NOT vendored in this repository**
- Large model files: **Git LFS**

## Why this repository starts here

このリポジトリのGit管理ルートは、既存の

```text
/home/baisound/BAI_AI/task097_gptsovits/GPT-SoVITS/
```

ではありません。

既存フォルダはGPT-SoVITS本体の作業ツリーなので、その上から別Gitを被せると、上流ソース、仮想環境、pretrained model、training log、private datasetまで混入しやすくなります。

推奨Gitルート:

```text
/home/baisound/BAI_AI/BAISOUND_VOICE_MODEL_V1/
```

元チェックポイントは以下から取り込みます。

```text
/home/baisound/BAI_AI/task097_gptsovits/GPT-SoVITS/SoVITS_weights_v2Pro/
/home/baisound/BAI_AI/task097_gptsovits/GPT-SoVITS/GPT_weights_v2Pro/
```

## Candidate checkpoint layout

```text
models/
  candidates/
    sovits/
      BAISOUND_TASK097_V1_e2_s100.pth
      BAISOUND_TASK097_V1_e4_s200.pth
      BAISOUND_TASK097_V1_e6_s300.pth
      BAISOUND_TASK097_V1_e8_s400.pth
    gpt/
      BAISOUND_TASK097_V1-e5.ckpt
      BAISOUND_TASK097_V1-e10.ckpt
      BAISOUND_TASK097_V1-e15.ckpt
  release/
    v1/
      selection.json
```

`models/release/v1/` にモデルバイナリを重複コピーしません。正式採用後は `selection.json` から採用候補を参照します。

## Initial setup

スターターパックを次の場所へ展開します。

```bash
mkdir -p /home/baisound/BAI_AI/BAISOUND_VOICE_MODEL_V1
cd /home/baisound/BAI_AI/BAISOUND_VOICE_MODEL_V1
```

その後:

```bash
bash scripts/init_repository.sh
bash scripts/import_task097_checkpoints.sh
python3 scripts/generate_manifest.py
bash scripts/verify_repository.sh
```

確認後:

```bash
git status
git add .
git commit -m "chore: initialize BAISOUND Voice Model V1 repository"
```

GitHubに空のPrivate repositoryを作った後:

```bash
git remote add origin git@github.com:<OWNER>/<REPOSITORY>.git
git push -u origin main
```

HTTPSを使う場合はremote URLだけ置き換えてください。

## Git LFS

`.pth` / `.ckpt` / `.safetensors` / `.onnx` / `.bin` は `.gitattributes` でGit LFS対象です。

確認:

```bash
git lfs ls-files
```

モデルファイルが通常Git objectとして追加されていないか、push前に必ず `scripts/verify_repository.sh` を通してください。

## Privacy

このrepositoryには原則として次を入れません。

- raw WAV
- BAI Voice Captureの録音本体
- private transcript
- private training dataset
- Whisper/ASR model
- GPT-SoVITS pretrained model
- virtualenv / cache / feature files
- secrets / tokens

Dataset provenanceは `DATA_PROVENANCE.md` と安全なmanifest/digestだけで管理します。

## Licensing

`LICENSE.md` はBAISOUND固有のrepository contentに対するデフォルト方針です。
モデル重みについては `MODEL_LICENSE.md` を参照してください。
GPT-SoVITSおよびpretrained componentsの情報は `THIRD_PARTY_NOTICES.md` に分離しています。

この初期状態では、モデル重みの公開再配布権を自動的には付与していません。Public repositoryへ変更する前にライセンス方針を明示的に確定してください。

## Files

- `MODEL_CARD.md` — model card
- `DATA_PROVENANCE.md` — training-data provenance boundary
- `MODEL_LICENSE.md` — weights licensing status
- `THIRD_PARTY_NOTICES.md` — upstream notices
- `SECURITY.md` — security/reporting
- `CONTRIBUTING.md` — contribution policy
- `CHANGELOG.md` — release history
- `CITATION.cff` — citation metadata
- `manifests/` — hashes and checkpoint inventory
- `scripts/` — import / hash / verify / release-selection helpers
