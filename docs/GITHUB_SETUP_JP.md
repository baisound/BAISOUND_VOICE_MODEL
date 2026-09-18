
# GitHub初期設定

## 1. Git管理する場所

推奨:

```text
/home/baisound/BAI_AI/BAISOUND_VOICE_MODEL_V1/
```

ここを新規Git repository rootにします。

次を直接Git repository rootにはしません。

```text
NG: /home/baisound/BAI_AI/task097_gptsovits/GPT-SoVITS/
NG: /home/baisound/BAI_AI/task097_gptsovits/GPT-SoVITS/GPT_weights_v2Pro/
NG: /home/baisound/BAI_AI/task097_gptsovits/GPT-SoVITS/SoVITS_weights_v2Pro/
```

理由:

- GPT側だけではモデル一式にならない。
- GPT-SoVITS upstream cloneそのものをBAISOUND model repositoryへ混ぜない。
- private dataset / logs / pretrained assets / venvを誤pushしにくくする。
- BAISOUND独自のversion/tag/historyをupstream source historyから分離できる。

## 2. GitHub repository

初期状態は **Private** を推奨します。

例:

```text
baisound/BAISOUND-Voice-Model
```

GitHub側ではREADME/.gitignore/LICENSEを自動生成せず、空repositoryとして作成してください。
このstarter側のファイルを正本として最初のcommitにします。

## 3. Git LFS

```bash
git lfs install
```

本starterでは `.gitattributes` により `.pth` と `.ckpt` がLFS対象です。

## 4. Initial commit

```bash
bash scripts/init_repository.sh
bash scripts/import_task097_checkpoints.sh
python3 scripts/generate_manifest.py
bash scripts/verify_repository.sh

git add .
git status
git commit -m "chore: initialize BAISOUND Voice Model V1 repository"
```

## 5. Remote

SSH:

```bash
git remote add origin git@github.com:<OWNER>/<REPOSITORY>.git
git push -u origin main
```

## 6. GitHub Settings推奨

Private repositoryで:

- Default branch: `main`
- Require pull request before merge: 任意（1人運用なら後からでもよい）
- Require status checks: `Metadata CI`
- Disable force pushes on `main`
- Disable branch deletion on `main`
- Secret scanning: 利用可能ならON
- Dependabot: source code依存を追加した場合にON
- Git LFS budget: 意図しない課金を避けるなら最初はbudget上限を設定

## 7. Release

正式V1ペアが決まるまでは `v1.0.0` tagを作成しません。

選定後:

```bash
python3 scripts/select_release.py \
  --sovits BAISOUND_TASK097_V1_e8_s400.pth \
  --gpt BAISOUND_TASK097_V1-e15.ckpt \
  --evaluation-reference docs/evaluation-v1.md

git add models/release/v1/selection.json
git commit -m "release: designate BAISOUND Voice Model V1 pair"
git tag -a v1.0.0 -m "BAISOUND Voice Model v1.0.0"
git push origin main --follow-tags
```

上記のcheckpoint名は使用例であり、現時点の推奨・選定結果ではありません。
