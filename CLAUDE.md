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
    { "id": "w001", "type": "tcf", "tcf_tache": 1, "message_from": "Lina", "message_text": "Salut! ...", "instruction": "Répondez...", "word_min": 60, "word_max": 120 },
    { "id": "w002", "type": "tcf", "tcf_tache": 2, "context": "Newsletter...", "instruction": "Rédigez...", "word_min": 120, "word_max": 150 },
    { "id": "w003", "type": "tcf", "tcf_tache": 3, "view_a": "Opinion A...", "view_b": "Opinion B...", "topic": "Technology", "instruction": "Summarize both views...", "word_min": 120, "word_max": 180 }
  ],
  "dictation": [
    { "id": "d001", "sentence_fr": "...", "sentence_en": "...", "level": "A1", "tags": [...], "alternates": ["..."] }
  ],
  "listening": [
    { "id": "l001", "tier": 1, "tier_name": "Repérage", "audio": "audio/l001.mp3", "passage_text": "...", "situation": "...", "statements": ["A", "B", "C", "D"], "correct": 2, "level": "A1" },
    { "id": "l002", "tier": 3, "tier_name": "Reportages", "audio": "audio/l002.mp3", "passage_text": "...", "question": "...", "options": ["A", "B", "C", "D"], "correct": 0, "level": "B1" }
  ],
  "speaking": [
    { "id": "sp001", "tache": 1, "questions": ["Question 1?", "Question 2?", "Question 3?", "Question 4?"] },
    { "id": "sp002", "tache": 2, "topic": "Logement", "scenario": "Vous téléphonez...", "prep_time_seconds": 120 },
    { "id": "sp003", "tache": 3, "topic": "Technologie", "prompt": "Selon vous, les réseaux sociaux..." }
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
- Writing (TCF format): 3 per batch, one per tâche. `type`: "tcf", `tcf_tache`: 1/2/3.
  - Tâche 1: `message_from`, `message_text`, `instruction`, `word_min: 60`, `word_max: 120`
  - Tâche 2: `context`, `instruction`, `word_min: 120`, `word_max: 150`
  - Tâche 3: `view_a`, `view_b`, `topic`, `instruction`, `word_min: 120`, `word_max: 180`
- Legacy writing (backward compatible): `type`: essay/micro/translate still works
- Writing feedback: include `rubric: { vocabulary: N, grammar: N, coherence: N, organization: N }` (each 1-5) and categorized errors with `category` field.
- Listening: exercises with audio. `id`, `tier` (1-5), `tier_name`, `audio` (path to MP3), `passage_text`, `question`, `options` (array of 4), `correct` (index), `level`. Tier 1 uses `statements` + `situation` instead of `question` + `options`.
- Speaking: prompts displayed on home screen (not in session queue). `id`, `tache` (1/2/3), `questions` (tâche 1), `scenario` + `prep_time_seconds` (tâche 2), `prompt` (tâche 3), `topic`.
- Generate reach exercises for each weak error pattern
- Difficulty 1-5 scale (1=recognition, 5=production with no hints)

## Curriculum Progression System

The app tracks mastery per chapter section and advances through the curriculum automatically.

### Chapter 1 sections (in order):
- `s1-gender` — Gender & Articles
- `s2-adjectives` — Adjective Agreement
- `s3-plurals` — Plurals
- `s4b-colors` — Color Adjectives
- `s4c-precede` — Preceding Adjectives
- `s5-vocab` — Chapter Vocabulary

### How it works:
- Every grammar exercise is mapped to a section via its tags
- Exercises without explicit section tags are inferred from content tags (e.g. `gender` → `s1-gender`)
- The session queue only serves exercises from the current section + completed sections (for spaced review)
- When MCQ mastery is achieved for a section's tag (≥6 attempts, ≥75% accuracy), blank exercises unlock
- When blank mastery is achieved (≥4 attempts, ≥75%), open exercises unlock
- Once blanks are unlocked ("advancing" status), the app auto-advances to the next section
- Progress is tracked in `PROGRESS.json` under the `curriculum` field

### Progress schema (v10):
```json
{
  "curriculum": { "chapter": 1, "currentSection": "s2-adjectives", "completedSections": ["s1-gender"], "chapterPhase": "LEARN" },
  "xp": { "total": 1250, "level": 5 },
  "achievements": { "first-note": { "unlocked": "ISO-date", "fresh": false } },
  "streak": { "current": 3, "best": 5, "lastDate": "2026-09-28", "freezeDays": 2, "freezeUsed": [] },
  "speakingDone": ["sp001"],
  "weeklyQuizzes": [{ "date": "2026-09-29", "score": 8, "total": 10, "pct": 80, "duration": 300, "timedOut": false }],
  "challengesDone": [{ "tag": "gender", "date": "2026-09-29", "passed": true, "score": 5, "total": 5, "timedOut": false }],
  "bossDefeated": [5]
}
```

### Batch generation requirement:
Every grammar exercise MUST include its section tag in the `tags` array. The REFUEL.md includes the section map.

## Stickiness Layer (Phase 3)

### Progressive Session Length (Phase 4)
Sessions ramp based on total sessions completed:
- 0-5 sessions: 5 exercises max, grammar only
- 6-12 sessions: 10 exercises, grammar + vocab
- 13-25 sessions: 15 exercises, + dictation + reading
- 26-50 sessions: 20 exercises, + writing (tâche 1 only) + listening (tier 1-2 only)
- 51+ sessions: 30 exercises, full mix

### Listening Comprehension (Phase 4)
Audio-based MCQ exercises. Audio files stored as MP3s in `batches/audio/`. Generated via Google Cloud TTS Chirp 3 HD with fr-CA voices (`scripts/tts-batch.sh`). Tiers 1-5 match TCF Canada format. Tiers 1-3 allow replay; 4-5 do not. Falls back to transcript if no audio file.

### Speaking Practice (Phase 4)
Prompts displayed on home screen (not in drill session). Tracked via `speakingDone[]`. Actual speaking practice happens in Claude Code sessions.

### Adaptive Session Engine (Phase 5)
The app adjusts mid-session based on real-time performance:
- **Mid-session difficulty**: tracks running accuracy per tag. 3 wrong in a row on same pattern → inserts easier "confidence builder" exercise. 3 right in a row → inserts harder "challenge" exercise. Visual badges show which type.
- **Smart session close**: error rate hits 35% (after min 4 exercises) → session ends early with supportive message. Prevents frustration buildup.
- **Bonus round**: error rate under 10% → offers optional 5-exercise challenge round at higher difficulty.
- **Skill weakness detection**: tracks per-skill accuracy across last 10 sessions (grammar, vocab, reading, listening, writing, dictation). Shows skill accuracy bars on home screen (red/yellow/green). Weakest skill (under 70%) gets highlighted as session focus with increased exercise allocation.
- Session records include `skills` field with per-skill breakdown: `{ grammar: { a: attempts, c: correct }, ... }`
- **Error diagnosis**: stores actual wrong answers per tag. Detects repeated misconceptions ("You keep choosing X"), accent-only errors, and near-miss confusions. Diagnostic messages shown in confidence builders.
- **Cross-session memory**: `progress.weakTags` persists struggling patterns across sessions. Tags with >50% errors get flagged; <25% clears them. Persistent weak tags shown on home screen and front-loaded in session queue.
- **Adaptive thresholds**: consecutive trigger scales with experience (2 for sessions 1-10, 3 for 11-30, 4 for 31+).
- **Multi-skill escalation**: vocab escalation pushes recognition → production. Listening escalation jumps to higher tier. Grammar uses difficulty-based escalation.
- Functions: `exerciseSkill()`, `trackAnswer()`, `checkSmartClose()`, `insertConfidenceBuilder()`, `tryEscalation()`, `checkAdaptiveTriggers()`, `adaptiveThreshold()`, `diagnoseErrors()`, `updateWeakTags()`, `persistentWeakTags()`, `skillAccuracy()`, `weakestSkill()`

### XP & Levels
- XP earned per correct answer: MCQ 10, blank 20, open 30, vocab recognition 10, vocab production 20, reading 15, writing 50, dictation 20, listening 15, REACH bonus +5
- 15% chance of double XP on any correct answer (variable reward)
- Level = floor(sqrt(totalXP / 50)) + 1
- XP for next level = (level)^2 * 50

### Mini Quizzes & Skill Progress (Phase 7)
- **Skill progress bars**: per-skill accuracy bars (red/yellow/green) promoted as primary progress indicator on home screen
- **Weekly checkpoint quiz**: unlocks after 7 sessions since last quiz. 10 questions across all practiced skills (4 grammar, 2 vocab, 1 reading, 1 listening, 1 dictation, 1 weakest-skill wildcard). 8-minute timer. Score comparison to previous quiz.
- **Skill challenge rounds**: when a tag or skill has >80% accuracy with enough exercises, offers "go 5/5 in 90 seconds" challenge. Perfect score earns +50 bonus XP. No penalty for failure.
- **Boss battles**: available at chapters 5, 10, 15. 15 exercises at harder difficulty, 10-minute timer, mixed skills. Need 70% to win. +200 bonus XP on victory.
- **Session modes**: `S.sessionMode` flag ('normal', 'quiz', 'challenge', 'boss'). Adaptive triggers disabled in non-normal modes. Timer runs with countdown display (turns red at 30s).
- **Quiz history**: tracked in `progress.weeklyQuizzes[]`, displayed on home screen.
- Functions: `canTakeWeeklyQuiz()`, `sessionsSinceLastQuiz()`, `buildQuizQueue()`, `challengeableSkills()`, `buildChallengeQueue()`, `canBossBattle()`, `buildBossQueue()`, `startWeeklyQuiz()`, `startChallengeRound()`, `startBossBattle()`, `updateTimer()`, `stopTimer()`, `timerDisplay()`

### Instant Writing Feedback (Phase 6)
- **Claude API integration**: when a Claude API key is configured, writing submissions get instant feedback via Claude Opus 4.6
- **Evaluation flow**: submit writing > loading state > rubric scores + corrections + comment displayed inline > "Continue" button
- **Rubric**: vocabulary (1-5), grammar (1-5), coherence (1-5), organization (1-5) using TCF grading criteria
- **Corrections**: up to 8 specific corrections shown with original/corrected text and category
- **Key management**: stored in localStorage (`fdv3_claude_key`), encrypted backup on GitHub as `claude-key.enc`
- **Settings screen**: accessible from home, allows adding/updating/removing the Claude API key
- **Fallback**: if no key configured or API call fails, the old flow continues (submit and wait for batch feedback)
- Functions: `evaluateWriting()`, `renderWritingEvaluation()`, `getClaudeKey()`, `setClaudeKey()`, `saveClaudeKeyEncrypted()`, `loadClaudeKeyEncrypted()`, `renderSettings()`

### Smart Pressure System (Phase 8)
- **Energy detection**: after every 3 exercises, detects energy state from accuracy + response times. Good day (>85% acc, fast responses) → adds 2 bonus exercises + encouraging message. Bad day (<50% acc or slow + <65%) → caps session early + supportive message.
- **Response time tracking**: `sessionStats.responseTimes[]` records ms per exercise. Slow = avg >20s for last 3.
- **Streak risk escalation**: enhanced nudge banner with 3 urgency levels based on streak length + time of day. Moderate (3+ days, after 7 PM) = gentle. High (5+) = loss framing. Critical (7+) = maximum urgency with "longest streak ever" if applicable.
- **Weekly progress report**: shown on home screen every Monday. Sessions count, exercises done, average accuracy, streak length, skill strengths/weaknesses, comparison to previous week with directional arrows.
- Functions: `detectEnergy()`, `checkEnergy()`, `streakRiskLevel()`, `renderNudgeBannerEnhanced()`, `renderWeeklyReport()`

### 28 Achievements
Coyle-specific badges: First Note, Deep Practitioner, Centurion, 500 Club, Sweet Spot, Clarissa Moment, Perfect Session, Streak Starter/Week Warrior/Flame Keeper/Unbreakable, Section Master, Chapter Champion, Word Collector/Vocabulary Vault, Error Hunter, Marathon, Writer, Early Bird, Night Owl, Freeze Frame, Guitar String, Rising Star, Polyglot Path, Checkpoint, Quiz Ace, Challenge Won, Boss Slayer.

### Streak Protection
- Forgiving: freeze days auto-save the streak if you miss 1 day
- Earn 1 freeze day every 7-day streak milestone (max 3 stored)
- Visual indicator on home screen

### Guitar Strings / Ignition Tab
- 8 real stories of South Asian immigrants who learned French
- Accessible from home screen, designed for motivation during gaps

### Stare Content
- French content links from batch `stare` field displayed on home screen
- Shows title, note, duration, and "Watch" link

### Daily Reminder
- Cron job at 8 PM: `notify-send` if no session today
- "Not done today" nudge banner on home screen after 6 PM

### Share Progress
- Text-based shareable progress card (uses Web Share API or clipboard)

## Methodology

The app implements frameworks from:
- `Projects/Ongoing/French 2/SYSTEM.md` — curriculum, session flow
- `Projects/Ongoing/French 2/TEACHING-METHODOLOGY.md` — 14 cognitive science principles
- Coyle's Deep Practice — 20% Rule (aim for 15-25% error rate)
- Coyle's REACH — follow-up exercise after pattern errors
- Coyle's Ignition — Guitar Strings motivation (8 real stories)
- BJ Fogg's Tiny Habits — prompt design (cron reminder + nudge banner)
- Nir Eyal's Hook Model — variable rewards (15% double XP chance)
