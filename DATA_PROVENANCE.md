# Data Provenance

## Public-safe summary

The BAISOUND models were fine-tuned from an owner-reviewed voice dataset. The initial approved subset contained 206 clips totaling 1,965.79 seconds.

The current stable v2 pair was promoted from an already approved model identity. The repository modernization process did not retrain or reselect the model.

## Repository boundary

Allowed provenance records include public model hashes, public filenames, source artifact names, counts and durations, engine revisions, and public-safe evaluation summaries.

The following remain outside this repository:

- raw and reference voice audio;
- private transcripts or corrections;
- training, validation, and hidden test datasets;
- blind-review mappings and private pair keys;
- feature caches, embeddings, logs, and crash dumps;
- credentials and unnecessary machine-local paths.

Source artifact names are retained only as provenance metadata in manifests and profiles. They are not used as public model filenames.
