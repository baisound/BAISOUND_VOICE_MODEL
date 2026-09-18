
# Model Card — BAISOUND Voice Model V1 Candidates

## Model details

- Project: BAISOUND
- Training task: TASK-097
- Architecture family: GPT-SoVITS
- Training line: v2Pro
- Status: candidate checkpoint set
- Final release pair: NOT YET DESIGNATED

## Candidate checkpoints

### SoVITS

- `BAISOUND_TASK097_V1_e2_s100.pth`
- `BAISOUND_TASK097_V1_e4_s200.pth`
- `BAISOUND_TASK097_V1_e6_s300.pth`
- `BAISOUND_TASK097_V1_e8_s400.pth`

### GPT

- `BAISOUND_TASK097_V1-e5.ckpt`
- `BAISOUND_TASK097_V1-e10.ckpt`
- `BAISOUND_TASK097_V1-e15.ckpt`

The current evaluation space therefore contains 12 possible SoVITS/GPT pairings.

## Intended use

BAISOUND voice synthesis and project-internal evaluation.

## Non-goals

- This repository is not an ASR/Whisper model repository.
- The checkpoints are not intended to be loaded as `faster-whisper` models.
- Raw private voice data is not distributed here.

## Evaluation status

A final V1 pair must be selected through comparative evaluation before a release tag is
created. Record the selection in:

```text
models/release/v1/selection.json
```

## Limitations

Model quality may vary by sentence length, prosody, vocabulary, emotion, speaking
tempo, and reference audio. A checkpoint filename alone is not evidence that it is the
best release candidate.

## Provenance

See `DATA_PROVENANCE.md` and `manifests/`.
