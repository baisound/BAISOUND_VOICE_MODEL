
# Contributing

This repository primarily tracks BAISOUND model artifacts and metadata.

Before committing:

```bash
bash scripts/verify_repository.sh
```

Rules:

- do not commit raw/private audio;
- do not commit secrets;
- do not vendor GPT-SoVITS upstream source;
- model binaries must be Git LFS objects;
- update `manifests/checkpoints.json` when checkpoints change;
- keep release selection separate from candidate preservation;
- never rewrite a released model tag to point to different model bytes.

For large-model changes, include SHA-256 and the reason for the change in the commit or
pull request.
