
# Security Policy

## Sensitive assets

Treat the following as sensitive:

- unpublished voice model checkpoints;
- private raw recordings;
- private transcripts;
- authentication tokens;
- local/private infrastructure paths where disclosure creates risk.

Do not report secrets in public GitHub Issues.

## Model files

PyTorch `.pth` and `.ckpt` files may use pickle-based serialization. Only load model
files from trusted provenance. Verify SHA-256 before use.

## Reporting

For a private repository, report security concerns directly to the repository owner or
through the private project communication channel.
