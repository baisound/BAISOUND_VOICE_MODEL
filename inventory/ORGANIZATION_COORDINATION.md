# Model File Organization Coordination

この監査では`.pth`、`.ckpt`、`.safetensors`を拡張子だけでprivate asset扱いせず、identity・SHA-256・provenanceで分類した。

## Ownership result

- `PUBLIC_MODEL_RELEASE` → `BAISOUND_VOICE_MODEL/models/stable/`
- `PUBLIC_MODEL_CANDIDATE` → `BAISOUND_VOICE_MODEL/models/candidates/`
- `PUBLIC_MODEL_EXPERIMENTAL` → `BAISOUND_VOICE_MODEL/models/experimental/`
- `INTERNAL_MODEL_ARTIFACT` → Voice Labまたはprivate archiveの管理対象
- `THIRD_PARTY_DEPENDENCY` → 再配布せず、dependencyとして記録

## Coordination rules

- Stable v2とSignature previewはPublic Repoへ承認済みbytesをコピーした。
- 既存v1候補は削除せず、同一LFS objectのままpublic filenameへ`git mv`した。
- WSLの学習source、logs、pretrained models、environment、cacheは移動・削除していない。
- 内部artifactや第三者依存の物理整理は、Voice Lab/private archive側の別作業として扱う。
- 重複判断はmtimeではなくSHA-256とprovenanceを用いる。

Machine-readable evidence:

- `inventory/wsl-home-model-scan.csv`
- `inventory/wsl-public-model-candidates.csv`
- `inventory/wsl-excluded-runtime-files.csv`
- `inventory/public-release-map.csv`
- `inventory/old-downloads-cross-check.csv`
