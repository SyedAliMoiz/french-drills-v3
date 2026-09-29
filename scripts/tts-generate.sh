#!/usr/bin/env bash
# Generate MP3 audio from French text using Google Cloud TTS (Chirp 3 HD, fr-CA)
# Usage: ./tts-generate.sh "French text here" output.mp3 [voice_name]
#
# Voices (fr-CA Chirp 3 HD):
#   fr-CA-Chirp3-HD-Achernar  (female, default)
#   fr-CA-Chirp3-HD-Alnilam   (male)
#   fr-CA-Chirp3-HD-Sulafat   (female)
#   fr-CA-Chirp3-HD-Charon    (male)
# Run ./tts-list-voices.sh to see all available fr-CA voices

set -euo pipefail

TEXT="$1"
OUTPUT="$2"
VOICE="${3:-fr-CA-Chirp3-HD-Achernar}"

KEY_FILE="$HOME/.config/google-tts/api_key"
if [[ ! -f "$KEY_FILE" ]]; then
  echo "ERROR: No API key found. Run ./tts-setup.sh first." >&2
  exit 1
fi
API_KEY="$(cat "$KEY_FILE")"

RESPONSE=$(curl -s -X POST \
  "https://texttospeech.googleapis.com/v1/text:synthesize?key=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg text "$TEXT" \
    --arg voice "$VOICE" \
    '{
      input: { text: $text },
      voice: { languageCode: "fr-CA", name: $voice },
      audioConfig: { audioEncoding: "MP3", speakingRate: 1.0 }
    }')")

ERROR=$(echo "$RESPONSE" | jq -r '.error.message // empty')
if [[ -n "$ERROR" ]]; then
  echo "ERROR: $ERROR" >&2
  exit 1
fi

echo "$RESPONSE" | jq -r '.audioContent' | base64 -d > "$OUTPUT"
echo "Generated: $OUTPUT ($(du -h "$OUTPUT" | cut -f1))"
