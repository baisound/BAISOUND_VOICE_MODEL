# Compatibility

## Stable v2

- Engine: GPT-SoVITS
- Engine family: v2Pro
- Components: SoVITS `.pth` + GPT `.ckpt`
- Upstream source commit used by the recorded training basis: `48b1a0169a28582a8984402f82cf438d3bfa6aca`

The exact Runtime integration can differ by product. Consumers should read `profiles/stable.json` rather than hard-code source artifact names.

This repository does not include:

- GPT-SoVITS source;
- third-party pretrained models;
- Python or Conda environments;
- TTS server and playback integration.
