# Changelog

All notable BAISOUND Voice Model repository changes are recorded here.

## [Unreleased]

## [2.0.1] - 2026-09-24

### Documentation

- expanded the README with a product overview and software-integration map;
- added separate Japanese guides for first-time users and developers;
- documented GPT-SoVITS WebUI, local API, video, streaming, Stream Deck, and game integration boundaries.
- added a Windows v2Pro API launcher, PowerShell API client, and local settings template;
- added mandatory YouTube credit and prohibited-misuse guidance, including civil and criminal enforcement policy.
- documented the automated Windows API client validation boundary.

### Added

- added an owner-approved Stable v2.0.0 narration sample with public-safe metadata and checksum.
- added a Windows CI smoke test for model switching, UTF-8 Japanese requests, reference inputs, and WAV output validation.

### Compatibility

- kept the Stable GPT and SoVITS model binaries, filenames, sizes, and SHA-256 values unchanged from v2.0.0.

## [2.0.0] - 2026-09-22

### Added

- stable GPT-SoVITS v2Pro SoVITS and GPT model pair;
- experimental signature-preview SoVITS model profile;
- release profiles, model registry, release manifest, checksums, and install documentation;
- WSL source inventory and public-release mapping evidence.

### Changed

- renamed all preserved v1 candidates to public, descriptive filenames;
- reorganized candidates, stable releases, and experimental models by channel;
- replaced machine-specific import instructions with generic source-path inputs;
- updated repository verification for LFS, privacy, manifests, profiles, and public naming.

### Security

- confirmed that private audio, hidden evaluation data, environments, caches, logs, and upstream source are not included.

## [0.0.0] - 2026-09-19

- Initial repository bootstrap.
- Seven v1 candidate checkpoints preserved.
