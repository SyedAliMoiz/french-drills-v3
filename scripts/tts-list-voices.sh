#!/usr/bin/env bash
# List all available fr-CA voices from Google Cloud TTS
set -euo pipefail

KEY_FILE="$HOME/.config/google-tts/api_key"
if [[ ! -f "$KEY_FILE" ]]; then
  echo "ERROR: No API key found. Run ./tts-setup.sh first." >&2
  exit 1
fi
API_KEY="$(cat "$KEY_FILE")"

curl -s "https://texttospeech.googleapis.com/v1/voices?key=${API_KEY}&languageCode=fr-CA" \
  | jq -r '.voices[] | "\(.name)\t\(.ssmlGender)\t\(.naturalSampleRateHertz)Hz"' \
  | sort \
  | column -t -s $'\t'
