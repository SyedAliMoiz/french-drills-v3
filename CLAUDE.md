# French Drills V3

All-in-one French learning app. Replaces V1 (grammar) and V2 (vocab SRS).

## Architecture

**Batch model:** Claude Code generates exercise batches as JSON. The app serves them. Zero API cost. Zero Claude Code required for daily use.

**REFUEL loop:** When exercises run low, the app generates REFUEL.md with all progress context. Ali pastes it into any Claude Code session, which generates the next batch and pushes it to this repo.

## Files

- `index.html` — Single-file app (CSS + JS inline)
- `batches/registry.json` — Batch registry (lists all batch files)
- `batches/current.json` — First batch (Chapter 1, legacy name)
- `batches/b-YYYY-MM-DD-chN.json` — Named batch files
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
    { "id": "w001", "type": "essay", "prompt": "...", "guidelines": "...", "level": "A1", "template": "opinion_essay" },
    { "id": "w002", "type": "micro", "prompt": "Write 2 sentences about...", "guidelines": "...", "level": "A1" },
    { "id": "w003", "type": "translate", "prompt": "Translate to French", "source_en": "English text here.", "guidelines": "...", "level": "A1" }
  ],
  "dictation": [
    { "id": "d001", "sentence_fr": "...", "sentence_en": "...", "level": "A1", "tags": [...], "alternates": ["..."] }
  ],
  "writing_feedback": [],
  "spaced_retrieval": ["section-ids-to-review"],
  "stare": { "type": "youtube", "title": "...", "url": "...", "note": "..." }
}
```

## Multi-Batch System

The app loads ALL batches listed in `batches/registry.json`. Exercises from all batches are merged into one pool. Spaced retrieval pulls from older batches; fresh exercises come from the newest.

### Registry format
```json
{
  "batches": [
    { "id": "b-2026-09-23-ch1", "file": "current.json", "chapter": 1, "generated": "2026-09-23" },
    { "id": "b-2026-10-01-ch2", "file": "b-2026-10-01-ch2.json", "chapter": 2, "generated": "2026-10-01" }
  ]
}
```

Backward compatibility: if no registry.json exists, the app falls back to loading `batches/current.json`.

## Generating a Batch

When you receive a REFUEL.md, generate a new batch file (e.g. `batches/b-2026-10-01-ch2.json`) and add it to `batches/registry.json`. Push both. The app will load all batches on next open.

Key rules:
- Exercise IDs must be unique and never reuse exhausted IDs (listed in REFUEL.md)
- Grammar exercises need `id`, `type`, `stem`, `correct`, `rule`, `tags`
- Vocab needs `id`, `word`, `meaning`, `gender` (for nouns)
- Writing: 3 per batch, mixed types. `type`: essay (with `template`), micro (2-sentence prompt), translate (with `source_en`). Templates: opinion_essay, formal_email, letter_of_complaint, narrative.
- Writing feedback: include `rubric: { vocabulary: N, grammar: N, coherence: N, organization: N }` (each 1-5) and categorized errors with `category` field.
- Generate reach exercises for each weak error pattern
- Difficulty 1-5 scale (1=recognition, 5=production with no hints)

## Methodology

The app implements frameworks from:
- `Projects/Ongoing/French 2/SYSTEM.md` — curriculum, session flow
- `Projects/Ongoing/French 2/TEACHING-METHODOLOGY.md` — 14 cognitive science principles
- Coyle's Deep Practice — 20% Rule (aim for 15-25% error rate)
- Coyle's REACH — follow-up exercise after pattern errors
