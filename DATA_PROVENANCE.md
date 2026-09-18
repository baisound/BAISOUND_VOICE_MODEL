
# Data Provenance

## TASK-097 first fine-tuning run

The first TASK-097 training dataset was built from an owner-reviewed canonical approved
subset.

Known canonical scope:

- approved clips: 206
- approved duration: 1965.79 seconds
- approved duration: approximately 00:32:45.790

The raw/private audio and transcripts are intentionally not stored in this model
repository.

## Repository boundary

Allowed provenance artifacts:

- public-safe or private-safe canonical manifest identifiers;
- source/checkpoint SHA-256 hashes;
- counts and durations;
- training configuration;
- evaluation summaries;
- upstream model revision identifiers.

Excluded by default:

- raw WAV;
- private transcripts;
- correction text containing private content;
- full feature caches;
- speaker embeddings unless specifically approved;
- secrets and local paths that are not needed for reproducibility.

## Future runs

Each additional fine-tuning run should receive a new immutable run ID and a separate
manifest under `manifests/runs/`.
