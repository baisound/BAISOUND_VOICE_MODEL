# Copy this file to BAISOUND-API-SETTINGS.local.ps1 and fill in local values.
# The local file is ignored by Git. Do not commit reference-audio paths or text.

$env:BAISOUND_GPTSOVITS_ROOT = ""
$env:BAISOUND_GPTSOVITS_PYTHON = ""
$env:BAISOUND_VOICE_MODEL_ROOT = ""
$env:BAISOUND_REFERENCE_WAV = ""
$env:BAISOUND_REFERENCE_TEXT = ""

$env:BAISOUND_API_HOST = "127.0.0.1"
$env:BAISOUND_API_PORT = "9880"
$env:BAISOUND_DEVICE = "cuda"
$env:BAISOUND_IS_HALF = "true"
