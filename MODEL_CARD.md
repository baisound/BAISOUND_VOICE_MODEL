# Model Card — BAISOUND Voice Model

## Model details

- Model ID: `baisound-voice`
- Stable release: `2.0.0`
- Architecture family: GPT-SoVITS
- Engine line: v2Pro
- Stable components: one SoVITS checkpoint and one GPT checkpoint
- Distribution format: Git LFS managed `.pth` and `.ckpt`

## Intended use

The stable profile is intended for BAISOUND voice synthesis in compatible GPT-SoVITS v2Pro runtimes. The experimental signature-preview profile is provided separately and is not the default general-synthesis recommendation.

Use is limited to separately authorized users and is subject to `MODEL_LICENSE.md` and `docs/USAGE_POLICY_JP.md`. YouTube use requires the specified credit in every applicable video description.

## Public demo

An owner-approved Stable v2.0.0 narration sample and its public-safe generation metadata are available under `samples/public/`. The demo contains generated audio only; reference and training audio remain excluded.

## Prohibited misuse

Impersonation, deception, fraud, defamation, harassment, illegal activity, rights infringement, unauthorized redistribution, and removal of required attribution are prohibited. See `docs/USAGE_POLICY_JP.md` for the complete rules and enforcement policy.

## Selection status

The stable pair promotes an existing, owner-approved model identity. Repository modernization did not rerun evaluation or select a different checkpoint pair.

Public-safe evaluation summary:

- the stable pair was frozen before final testing;
- final testing did not cause model reselection;
- private prompts, audio, mappings, and owner-only notes are intentionally excluded.

## Limitations

Quality can vary with sentence length, prosody, vocabulary, emotion, speaking rate, reference audio, and runtime parameters. A model filename alone does not prove suitability for a particular use case.

## Privacy and provenance

Raw voice recordings, private transcripts, training datasets, hidden evaluation audio, and blind-review mappings are not distributed here. See `DATA_PROVENANCE.md` and `manifests/training-basis.json`.

## License

See `MODEL_LICENSE.md`. No open redistribution grant should be inferred from repository access.
