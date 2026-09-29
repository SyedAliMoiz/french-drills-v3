#!/usr/bin/env bash
# One-time setup for Google Cloud TTS API key
# Stores the key at ~/.config/google-tts/api_key
# Tests the connection by generating a short sample

set -euo pipefail

KEY_DIR="$HOME/.config/google-tts"
KEY_FILE="$KEY_DIR/api_key"

echo "=== Google Cloud TTS Setup ==="
echo ""

if [[ -f "$KEY_FILE" ]]; then
  echo "API key already configured at $KEY_FILE"
  read -p "Replace it? (y/N): " REPLACE
  [[ "$REPLACE" != "y" && "$REPLACE" != "Y" ]] && echo "Keeping existing key." && exit 0
fi

echo "To get your API key:"
echo "  1. Go to console.cloud.google.com"
echo "  2. Create a project (or select existing)"
echo "  3. Search 'Cloud Text-to-Speech API' and enable it"
echo "  4. Go to APIs & Services > Credentials"
echo "  5. Click 'Create Credentials' > 'API Key'"
echo "  6. Copy the key and paste it below"
echo ""
read -p "Paste your API key: " API_KEY

if [[ -z "$API_KEY" ]]; then
  echo "ERROR: No key provided." >&2
  exit 1
fi

mkdir -p "$KEY_DIR"
echo -n "$API_KEY" > "$KEY_FILE"
chmod 600 "$KEY_FILE"
echo "Key saved to $KEY_FILE"

echo ""
echo "Testing connection..."

RESPONSE=$(curl -s -X POST \
  "https://texttospeech.googleapis.com/v1/text:synthesize?key=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "input": { "text": "Bonjour, bienvenue au test." },
    "voice": { "languageCode": "fr-CA", "name": "fr-CA-Chirp3-HD-Achernar" },
    "audioConfig": { "audioEncoding": "MP3" }
  }')

ERROR=$(echo "$RESPONSE" | jq -r '.error.message // empty')
if [[ -n "$ERROR" ]]; then
  echo "ERROR: $ERROR" >&2
  echo "Check your API key and make sure the TTS API is enabled." >&2
  rm "$KEY_FILE"
  exit 1
fi

SAMPLE="/tmp/tts-test-sample.mp3"
echo "$RESPONSE" | jq -r '.audioContent' | base64 -d > "$SAMPLE"
echo "Connection works. Sample saved to $SAMPLE ($(du -h "$SAMPLE" | cut -f1))"
echo ""
echo "Setup complete. The french-batch skill will now generate audio for listening exercises."
