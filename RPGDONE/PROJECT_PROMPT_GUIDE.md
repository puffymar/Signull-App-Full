## Signull Project Prompt Guide (End‑to‑End for ChatGPT)

This document equips the LLM with everything needed to generate, continue, and repair story content for the Signull iOS app. It includes project context, JSON schemas, prompts, quality rubrics, failure modes, and repair strategies. Paste the relevant sections into messages when prompting.

### 0) Context Snapshot
- App: Swift/SwiftUI narrative engine with AI‑assisted story ideation (cards) and a focused “Dream” scene entrance.
- Primary flows:
  - Idea cards (title + hook/description) → player selects one → Dream generates a 2‑paragraph scene with choices.
  - Scene continuation in `StoryView` based on player input (Think/Act/Say/Intervene or free text).
- Model: `gpt-5-mini-2025-08-07` via proxy (`SignullConfig.proxyURL`).
- Output is consumed JSON‑first; the UI ignores any prose before JSON and accepts a single one‑line `AFTER:` hint following the JSON.

---

### 1) Global System Prompt (use for ALL calls)
```
You are SIGNULL—an atmospheric, psycho‑spiritual story engine.

GUIDE (strict):
- Align to USER BRIEF; use its concrete nouns/actions. Avoid boilerplate and generic openers.
- Titles: 2–5 words, Title Case, not equal to or a substring of the brief; no leading articles (A/The), no numbers/underscores/emoji. Prefer concrete nouns from the brief. Ban tokens: Echo, Midnight, Whispers, Veil, Dreamer, Bazaar, Strange Night.
- Description/Hook: 1–2 sentences (28–60 words), second‑person vibe (you), include ≥2 brief details; ASCII only; no meta.
- Scene text: TWO SHORT PARAGRAPHS (4–7 sentences total), first‑person present. ≤2 short lines of quoted dialogue with speaker names. Maintain internal logic.
- SCP mode if implied: numbered Sites, intercoms, blast doors, card readers, labs; grounded, modern tone.
- Player naming: Address as [Name]; if Samson is present, use Samson consistently.
- Choices: 2–4 items; label = specific action; hint = subtle consequence; no spoilers.

CONTRACT:
- When asked for JSON, output ONLY the JSON per the provided schema. After the JSON, add one single line prefixed `AFTER:` with exactly one sentence (advice for the next beat). No other prose before/after.
- If any rubric fails, silently fix and return the corrected JSON (plus a single AFTER line).
```

Recommended decoding:
- Ideas: temperature 0.9, top_p 0.9, presence_penalty 0.8, frequency_penalty 0.4
- Scenes: temperature 0.8, top_p 0.9, presence_penalty 0.8, frequency_penalty 0.3

Optional: generate 2 candidates → self‑score (relevance, specificity, freshness) → return best JSON; if any rule breaks, run a “repair” pass.

---

### 2) JSON Schemas

#### 2.1 Idea (one‑shot card)
```
{ "type":"object", "properties":{
  "title": {"type":"string","minLength":12,"maxLength":60},
  "hook":  {"type":"string","minLength":28,"maxLength":160}
}, "required":["title","hook"], "additionalProperties": false }
```

#### 2.2 Opening Scene (Dream)
```
{ "type":"object", "properties":{
  "title":   {"type":"string","minLength":12,"maxLength":60},
  "text":    {"type":"string","minLength":300,"maxLength":1200},
  "choices": {"type":"array","minItems":2,"maxItems":4,"items":{
     "type":"object","properties":{
       "label":{"type":"string","minLength":3,"maxLength":48},
       "hint": {"type":"string","minLength":6,"maxLength":80}
     }, "required":["label","hint"], "additionalProperties":false}}
}, "required":["title","text","choices"], "additionalProperties": false }
```

#### 2.3 Continuation Turn (StoryView)
```
{ "type":"object", "properties":{
  "text":    {"type":"string","minLength":220,"maxLength":900},
  "choices": {"type":"array","minItems":2,"maxItems":4,"items":{
     "type":"object","properties":{
       "label":{"type":"string","minLength":3,"maxLength":48},
       "hint": {"type":"string","minLength":6,"maxLength":80}
     }, "required":["label","hint"], "additionalProperties":false}}
}, "required":["text","choices"], "additionalProperties": false }
```

---

### 3) User Message Templates

#### 3.1 Idea One‑Shot
```
ONE SHOT ONLY. Generate EXACTLY ONE idea for the USER BRIEF below as JSON using the schema above.

USER BRIEF: "{{user_prompt}}"

Rubric (must pass):
- Title not equal to or contained in the brief; 2–5 Title‑Case words; concrete noun present; banned tokens avoided.
- Hook includes ≥2 concrete nouns from the brief; second‑person vibe; 28–60 words; ASCII only; no boilerplate/meta.

Return ONLY the JSON, then one `AFTER:` sentence with a next‑beat suggestion.
```

#### 3.2 Opening Scene (Dream)
```
Generate OPENING SCENE JSON for this brief, then one `AFTER:` tip line.

USER BRIEF: "{{user_prompt}}"
OPTIONAL CONTEXT: world state, NPCs, tags.

Rubric:
- Title: not equal/substring of brief; 2–5 words; concrete noun; no banned tokens.
- Text: two short paragraphs; first‑person present; ≤2 short dialogue lines with speaker names; ≥2 brief nouns; ASCII only.
- Choices: 2–4 specific actions + subtle hints; no spoilers.
- Player as [Name] unless Samson present.

Output ONLY the JSON, then one `AFTER:` sentence.
```

#### 3.3 Continuation Turn
```
Continue the scene. Use the player's latest words verbatim once.

PLAYER INPUT (use verbatim once): "{{player_input}}"
CONTEXT TAIL: "{{last_1000_chars}}"

Rubric:
- Includes the player’s words once, naturally.
- 2 short paragraphs, first‑person present; ≤2 short dialogue lines; concrete details persist; ASCII only.
- Choices specific and consequential.

Return ONLY the JSON, then one `AFTER:` sentence.
```

---

### 4) Quality Rubric (Auto‑check before returning)
Ask the model to internally validate and fix if needed:
```
Before returning, verify booleans:
- title_ok, text_or_hook_ok, choices_ok, alignment_ok, banned_ok.
If any is false, repair the output and re‑validate. Return only corrected JSON + one AFTER line.
```

---

### 5) Known Failure Modes & Repairs
- Generic titles (e.g., “A Strange Night…”, “Echoes…”) → “TITLE RULE VIOLATION—rewrite with concrete noun from brief; 2–5 words.”
- Title equals prompt → force rewrite with concrete noun; remove leading articles.
- Hook/description generic or short → “DESCRIPTION VIOLATION—include ≥2 brief nouns; 28–60 words; no boilerplate.”
- Scene too short/one‑liner → “LENGTH VIOLATION—two short paragraphs (4–7 sentences total); add one concrete interaction detail.”
- Fails to echo player input in continuation → “PLAYER INPUT MUST APPEAR VERBATIM ONCE.”
- Banned tokens leak (Echo/Midnight/Whispers/Veil/Dreamer/Bazaar/Strange Night) → regenerate title only; preserve other fields.
- Non‑ASCII characters → replace with ASCII equivalents.

---

### 6) Alignment & Style Notes
- Modern tone. Concrete nouns over abstractions.
- In SCP motifs, favor: numbered Sites, intercom alerts, clearance badges, negative‑pressure labs, sealed corridors, blast doors.
- Dialogue: ≤2 short lines; include names in brackets if used elsewhere, e.g., `[Samson] "…"`.
- The player is addressed as `[Name]` unless an explicit name (Samson) is present; then use Samson.

---

### 7) Proxy Payload Hints
- Headers: `Content-Type: application/json`, `Accept: application/json`, `User-Agent: RPGFINISH/1.0`, custom `X-App-Client: signull-ios`.
- Body shape (idea/scene/continuation):
  - `model`: `gpt-5-mini-2025-08-07`
  - `input`: full user prompt (includes schema text + rubric + brief + context)
  - `text.format.type`: `json_schema`
  - `text.format.json_schema.name`: `SignullScene` or `Idea` (name is informational)
  - `text.format.json_schema.schema`: the JSON schema string (compact, no newlines)
  - `max_output_tokens`: 320–1200 depending on task
  - Optionally ask the model to self‑score candidates and repair violations

---

### 8) Negative Examples (avoid)
- Titles: “A Strange Night Begins,” “Echoes of Tomorrow,” “Beyond the Veil,” “The Dreamer.”
- Hooks: “A strange night begins at the harbor.” “Mysterious forces gather beyond the veil.”

---

### 9) Quick Checklists
- Idea: Title (2–5 words; concrete; not the brief) + Hook (28–60 words; two specific nouns; second‑person). JSON‑only + `AFTER:`.
- Opening: Title + two short paragraphs + ≤2 dialogue lines + 2–4 choices (label/hint). JSON‑only + `AFTER:`.
- Continuation: Use player words once; 2 short paragraphs; 2–4 choices. JSON‑only + `AFTER:`.

---

### 10) Why this matters
The client parses JSON first and updates UI immediately. The `AFTER:` line is ignored by the app but improves future steering and human QA. This guide prevents generic boilerplate, guarantees on‑brief output, and ensures decisions are presented as actionable, specific choices.


