# French Drills V3

All-in-one French learning app. Replaces V1 (grammar) and V2 (vocab SRS).

## Architecture

**Batch model:** Claude Code generates exercise batches as JSON. The app serves them. Zero API cost. Zero Claude Code required for daily use.

**REFUEL loop:** When exercises run low, the app generates REFUEL.md with all progress context. Ali pastes it into any Claude Code session, which generates the next batch and pushes it to this repo.

## Files

- `index.html` — Single-file app (CSS + JS inline)
- `batches/current.json` — Active exercise batch
- `PROGRESS.json` — User progress (synced from app via GitHub API)
- `config.enc` — Encrypted PAT (AES-256-GCM)

## Tech Stack

- Pure HTML/CSS/JS, no frameworks
- GitHub Pages hosting at `syedalimoiz.com/french-drills-v3/`
- localStorage for offline persistence, GitHub API for sync
- SM-2 spaced repetition for vocabulary

## Batch JSON Format

```json
{
  "batch_id": "b-YYYY-MM-DD",
  "generated": "YYYY-MM-DD",
  "curriculum": { "chapter": 1, "section": "s3-elision", "phase": "LEARN" },
  "grammar": [
    { "id": "g001", "type": "mcq|blank|open|why", "stem": "...", "options": [...], "correct": 0, "rule": "...", "tags": [...], "difficulty": 2 }
  ],
  "reach": { "tag": [exercises for follow-up after errors] },
  "vocabulary": [
    { "id": "v001", "word": "...", "gender": "m|f", "meaning": "...", "pronunciation": "...", "sentence_fr": "...", "sentence_en": "...", "sentence_blank_en": "...", "distractors": ["meaning1", "meaning2"], "tags": [...] }
  ],
  "reading": [
    { "id": "r001", "title": "...", "passage": "...", "level": "A1", "questions": [...], "vocab_highlights": {...} }
  ],
  "writing": [
    { "id": "w001", "prompt": "...", "guidelines": "...", "level": "A1" }
  ],
  "writing_feedback": [],
  "spaced_retrieval": ["section-ids-to-review"],
  "stare": { "type": "youtube", "title": "...", "url": "...", "note": "..." }
}
```

## Generating a Batch

When you receive a REFUEL.md, generate `batches/current.json` following the format above. Push it to this repo. The app will load it on next open.

Key rules:
- Exercise IDs must be unique and never reuse exhausted IDs (listed in REFUEL.md)
- Grammar exercises need `id`, `type`, `stem`, `correct`, `rule`, `tags`
- Vocab needs `id`, `word`, `meaning`, `gender` (for nouns)
- Generate reach exercises for each weak error pattern
- Difficulty 1-5 scale (1=recognition, 5=production with no hints)

## Methodology

The app implements frameworks from:
- `Projects/Ongoing/French 2/SYSTEM.md` — curriculum, session flow
- `Projects/Ongoing/French 2/TEACHING-METHODOLOGY.md` — 14 cognitive science principles
- Coyle's Deep Practice — 20% Rule (aim for 15-25% error rate)
- Coyle's REACH — follow-up exercise after pattern errors
