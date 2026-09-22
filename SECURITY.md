
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

Do not publish sensitive evidence, personal information, private audio, or exploit
details in a public GitHub Issue. Use GitHub private vulnerability reporting when it is
available, or contact the repository owner through an official private BAISOUND channel.

Suspected model or generated-audio misuse is handled under
`docs/USAGE_POLICY_JP.md`. Preserve the public URL, account name, observed date and time,
and unmodified screenshots or media. Do not organize retaliation, harassment, or public
disclosure of unrelated personal information.
