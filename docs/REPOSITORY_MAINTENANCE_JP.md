# リポジトリ保守

## Canonical repository

`https://github.com/baisound/BAISOUND_VOICE_MODEL`

## 原則

- 既存モデルを削除・上書きせず、意味のあるpublic filenameへ`git mv`する。
- 新しいpublic filename/pathへ内部Task番号や内部候補IDを入れない。
- source artifact名はmanifest/profileのprovenance fieldにだけ保持する。
- `.pth`、`.ckpt`、`.safetensors`はGit LFSで管理する。
- raw voice、private dataset、hidden evaluation、upstream source、environment、cacheを入れない。
- history rewriteとforce pushを行わない。

## 更新手順

1. `main`、remote、LFS状態を確認する。
2. source bytesのSHA-256と承認済みidentityを確認する。
3. public pathへ配置し、manifest/profile/checksumを更新する。
4. `bash scripts/verify_repository.sh`を実行する。
5. `git diff --check`とLFS一覧を確認する。
6. 意味のあるcorrective/release commitを作る。
7. `main`へ通常pushし、remote SHAを確認する。

GitHub Releaseの作成やrepository visibilityの変更は別のOwner判断です。
