#!/usr/bin/env bash
# Generate audio files for all listening exercises in a batch JSON
# Usage: ./tts-batch.sh ../batches/b-2026-10-01-ch2.json
#
# Reads the "listening" array from the batch file, generates MP3 for each
# exercise's passage_text, saves to ../batches/audio/{id}.mp3
#
# Voice selection:
#   - Tier 1-3 (single speaker): Achernar (female) or Alnilam (male), alternating
#   - Tier 4 (dialogue): Uses markers in text — lines starting with speaker labels
#   - Tier 5 (monologue): Charon (male, authoritative)

set -euo pipefail

BATCH_FILE="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AUDIO_DIR="$(dirname "$BATCH_FILE")/audio"

mkdir -p "$AUDIO_DIR"

VOICES_FEMALE="fr-CA-Chirp3-HD-Achernar"
VOICES_MALE="fr-CA-Chirp3-HD-Alnilam"
VOICE_FORMAL="fr-CA-Chirp3-HD-Charon"

COUNT=$(jq '.listening | length' "$BATCH_FILE")
if [[ "$COUNT" -eq 0 || "$COUNT" == "null" ]]; then
  echo "No listening exercises in this batch."
  exit 0
fi

echo "Generating audio for $COUNT listening exercises..."

for i in $(seq 0 $((COUNT - 1))); do
  ID=$(jq -r ".listening[$i].id" "$BATCH_FILE")
  TIER=$(jq -r ".listening[$i].tier" "$BATCH_FILE")
  TEXT=$(jq -r ".listening[$i].passage_text" "$BATCH_FILE")
  OUTPUT="$AUDIO_DIR/${ID}.mp3"

  if [[ -f "$OUTPUT" ]]; then
    echo "  [$((i+1))/$COUNT] $ID — already exists, skipping"
    continue
  fi

  # Pick voice based on tier and alternation
  if [[ "$TIER" -ge 5 ]]; then
    VOICE="$VOICE_FORMAL"
  elif [[ $((i % 2)) -eq 0 ]]; then
    VOICE="$VOICES_FEMALE"
  else
    VOICE="$VOICES_MALE"
  fi

  echo "  [$((i+1))/$COUNT] $ID (tier $TIER) — $VOICE"
  "$SCRIPT_DIR/tts-generate.sh" "$TEXT" "$OUTPUT" "$VOICE"
done

echo "Done. Audio files in $AUDIO_DIR/"
