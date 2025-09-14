## ChatGPT Drop‑In: JSON‑First Signull Prompts, Schemas, Extractor, Payloads

Use this file verbatim to wire consistent, JSON‑first outputs (with a trailing `AFTER:` hint line). Paste the system message, use the decoding presets, keep schemas exactly, and use the extractor. Candidate + repair pass is optional but recommended.

### 1) System message (paste verbatim)
```
You are SIGNULL—an atmospheric, psycho-spiritual story engine.

Follow this GUIDE strictly:
- Align to USER BRIEF; use its concrete nouns/actions. No boilerplate or generic openers.
- Titles: 2–5 words, Title Case, not equal to or a substring of the brief; no leading articles (A/The), no numbers/underscores/emoji. Prefer concrete nouns from the brief. Ban tokens: Echo, Midnight, Whispers, Veil, Dreamer, Bazaar, Strange Night.
- Description/Hook: 1–2 sentences (28–60 words), second-person vibe (you), include ≥2 specific details from the brief; no meta; no filler phrases (“a strange night”, “mysterious forces”).
- Scene text: TWO SHORT PARAGRAPHS (4–7 sentences total), first-person present. ≤2 short lines of quoted dialogue with speaker names. ASCII only. Maintain internal logic. If SCP implied: numbered Site corridors, intercoms, blast doors, card readers, labs—grounded, modern tone.
- Player naming: Address the player as [Name]. If context includes Samson, use Samson consistently; otherwise keep [Name].
- Choices: 2–4 items. label = specific action, hint = subtle consequence. No spoilers, no generic verbs.

STRICT OUTPUT CONTRACT:
- When asked for JSON, output ONLY the JSON per the provided schema. After the JSON, add a single guidance line prefixed `AFTER:` with exactly one sentence (this line is ignored by the client). No other prose.
- If any rubric check fails, silently repair and produce a corrected output that passes all checks.
```

### 2) Decoding presets
```ts
export const IDEAS_PARAMS = {
  temperature: 0.9, top_p: 0.9, presence_penalty: 0.8, frequency_penalty: 0.4
} as const;

export const SCENES_PARAMS = {
  temperature: 0.8, top_p: 0.9, presence_penalty: 0.8, frequency_penalty: 0.3
} as const;
```

### 3) Schemas (keep exactly)
```ts
// Idea One-Shot
export const IdeaSchema = {
  type: "object",
  properties: {
    title: { type: "string", minLength: 12, maxLength: 60 },
    hook:  { type: "string", minLength: 28, maxLength: 160 }
  },
  required: ["title","hook"],
  additionalProperties: false
} as const;

// Opening Scene
export const OpeningSchema = {
  type: "object",
  properties: {
    title: { type: "string", minLength: 12, maxLength: 60 },
    text:  { type: "string", minLength: 300, maxLength: 1200 },
    choices: {
      type: "array", minItems: 2, maxItems: 4, items: {
        type: "object",
        properties: {
          label: { type: "string", minLength: 3,  maxLength: 48 },
          hint:  { type: "string", minLength: 6,  maxLength: 80 }
        },
        required: ["label","hint"], additionalProperties: false
      }
    }
  },
  required: ["title","text","choices"],
  additionalProperties: false
} as const;

// Continuation Turn
export const ContinueSchema = {
  type: "object",
  properties: {
    text: { type: "string", minLength: 220, maxLength: 900 },
    choices: {
      type: "array", minItems: 2, maxItems: 4, items: {
        type: "object",
        properties: {
          label: { type: "string", minLength: 3,  maxLength: 48 },
          hint:  { type: "string", minLength: 6,  maxLength: 80 }
        },
        required: ["label","hint"], additionalProperties: false
      }
    }
  },
  required: ["text","choices"],
  additionalProperties: false
} as const;
```

### 4) Prompt builders (user messages)
```ts
export const buildIdeaPrompt = (user_prompt: string) => `
ONE SHOT ONLY. Generate EXACTLY ONE idea for the USER BRIEF below as JSON:
schema: { "type":"object", "properties":{
  "title":{"type":"string","minLength":12,"maxLength":60},
  "hook":{"type":"string","minLength":28,"maxLength":160}
}, "required":["title","hook"],"additionalProperties":false }

USER BRIEF: "${user_prompt}"

Rubric (must pass):
- Title not equal to or contained in the brief; 2–5 Title-Case words; no banned tokens; concrete noun present.
- Hook includes ≥2 concrete nouns from the brief; second-person vibe; no boilerplate; length 28–60 words; ASCII only.

Return ONLY the JSON. AFTER the JSON, output \`AFTER: One sentence advising the next beat\`.

Before returning, internally verify:
- title_ok (bool), text_or_hook_ok (bool), choices_ok (bool), alignment_ok (bool), banned_ok (bool).
If any is false, fix the output and re-validate. Return only the corrected JSON and one AFTER line.
`;

export const buildOpeningPrompt = (user_prompt: string, context_hints?: string) => `
Generate OPENING SCENE JSON for this brief, then one \`AFTER:\` tip line.
schema: {
  "type":"object","properties":{
    "title":{"type":"string","minLength":12,"maxLength":60},
    "text":{"type":"string","minLength":300,"maxLength":1200},
    "choices":{"type":"array","minItems":2,"maxItems":4,"items":{
      "type":"object","properties":{
        "label":{"type":"string","minLength":3,"maxLength":48},
        "hint":{"type":"string","minLength":6,"maxLength":80}
      },"required":["label","hint"],"additionalProperties":false}}
  },"required":["title","text","choices"],"additionalProperties":false
}

USER BRIEF: "${user_prompt}"
CONTEXT HINTS (optional): ${context_hints ?? "none"}

Rubric (must pass):
- Title: not equal to/substring of brief; 2–5 words; concrete noun; no banned tokens.
- Text: two short paragraphs; first-person present; ≤2 short dialogue lines with speaker names; includes ≥2 brief nouns; ASCII only; no meta.
- Choices: 2–4 specific actions with subtle consequence hints.
- Player addressed as [Name] unless Samson present.

Output ONLY the JSON. Then \`AFTER:\` one-sentence guidance.

Before returning, internally verify:
- title_ok (bool), text_or_hook_ok (bool), choices_ok (bool), alignment_ok (bool), banned_ok (bool).
If any is false, fix the output and re-validate. Return only the corrected JSON and one AFTER line.
`;

export const buildContinuePrompt = (player_input: string, last_1000_chars: string) => `
Continue the scene. Use the player's latest words verbatim once.

schema: {"type":"object","properties":{
  "text":{"type":"string","minLength":220,"maxLength":900},
  "choices":{"type":"array","minItems":2,"maxItems":4,"items":{
    "type":"object","properties":{
      "label":{"type":"string","minLength":3,"maxLength":48},
      "hint":{"type":"string","minLength":6,"maxLength":80}
    },"required":["label","hint"],"additionalProperties":false}}
},"required":["text","choices"],"additionalProperties":false}

PLAYER INPUT (use verbatim once): "${player_input}"
CONTEXT TAIL: "${last_1000_chars}"

Rubric:
- Includes the player’s words once, naturally.
- 2 short paragraphs, first-person present, ≤2 short dialogue lines, concrete details persist.
- Choices specific and consequential.

Return ONLY the JSON. Then \`AFTER:\` one-sentence guidance.

Before returning, internally verify:
- title_ok (bool), text_or_hook_ok (bool), choices_ok (bool), alignment_ok (bool), banned_ok (bool).
If any is false, fix the output and re-validate. Return only the corrected JSON and one AFTER line.
`;
```

### 5) Safe JSON‑first extractor (supports trailing `AFTER:`)
```ts
export function extractLeadingJSONAndAfter(raw: string) {
  let depth = 0, start = -1, end = -1;
  for (let i = 0; i < raw.length; i++) {
    const c = raw[i];
    if (c === '{') { if (depth === 0) start = i; depth++; }
    else if (c === '}') { depth--; if (depth === 0) { end = i; break; } }
  }
  if (start === -1 || end === -1) throw new Error("No top-level JSON object found.");
  const jsonText = raw.slice(start, end + 1);
  let data: any;
  try { data = JSON.parse(jsonText); }
  catch (e) { throw new Error("JSON parse failed: " + (e as Error).message); }
  const after = raw.slice(end + 1).trim().split('\n').find(l => l.startsWith('AFTER:')) ?? "";
  return { data, after: after.replace(/^AFTER:\s*/, '') };
}
```

### 6) Exact API payloads (OpenAI‑compatible)
Model: `gpt-5-mini-2025-08-07`
```ts
// Idea One-Shot
const ideaBody = {
  model: "gpt-5-mini-2025-08-07",
  ...IDEAS_PARAMS,
  messages: [
    { role: "system", content: SYSTEM_SIGNULL },
    { role: "user",   content: buildIdeaPrompt(userBrief) }
  ]
};

// Opening Scene
const openingBody = {
  model: "gpt-5-mini-2025-08-07",
  ...SCENES_PARAMS,
  messages: [
    { role: "system", content: SYSTEM_SIGNULL },
    { role: "user",   content: buildOpeningPrompt(userBrief, contextHints) }
  ]
};

// Continuation Turn
const continueBody = {
  model: "gpt-5-mini-2025-08-07",
  ...SCENES_PARAMS,
  messages: [
    { role: "system", content: SYSTEM_SIGNULL },
    { role: "user",   content: buildContinuePrompt(playerInput, last1000) }
  ]
};
```

### 7) Candidate strategy + self‑repair (optional)
```ts
export async function withCandidates(fetchFn: (b:any)=>Promise<any>, body: any, n = 2) {
  const candBodies = Array.from({ length: n }, () => ({ ...body }));
  const outs = await Promise.all(candBodies.map(b => fetchFn(b)));
  const scored = outs.map(o => {
    const raw = o.choices?.[0]?.message?.content ?? "";
    const { data, after } = extractLeadingJSONAndAfter(raw);
    const text = (data.text ?? (data as any).hook ?? "").toString();
    const sRelevance   = /[A-Za-z0-9]/.test(text) ? 3 : 1; // stub; plug in your own
    const sSpecificity = text.split(/\b(?:the|and|a|of|to|in)\b/i).length > 30 ? 4 : 2;
    const sFreshness   = /\b(?:blast|intercom|badge|containment|delta|coilgun|lab|corridor)\b/i.test(text) ? 4 : 2;
    return { data, after, score: sRelevance + sSpecificity + sFreshness, raw };
  });
  let best = scored.sort((a,b)=>b.score-a.score)[0];

  const needsFix = (schema: any, obj: any) => {
    const req = (schema.required ?? []) as string[];
    return req.some(k => obj[k] == null);
  };
  const schema = 'hook' in (best.data || {}) ? IdeaSchema : ('choices' in best.data ? OpeningSchema : ContinueSchema);

  if (needsFix(schema, best.data)) {
    const repairBody = {
      ...body,
      messages: [
        { role: "system", content: SYSTEM_SIGNULL },
        { role: "user",
          content:
`FIX ONLY violations to pass the rubric; preserve valid parts.
Return ONLY corrected JSON plus one AFTER line.

JSON TO REPAIR:
${JSON.stringify(best.data, null, 2)}

SCHEMA:
${JSON.stringify(schema)}
`}
      ]
    };
    const repaired = await fetchFn(repairBody);
    const raw = repaired.choices?.[0]?.message?.content ?? "";
    best = extractLeadingJSONAndAfter(raw) as any;
  }
  return best;
}
```

### 8) Rubric guardrails (pre‑flight checks to log/assert)
- **title_ok**: 2–5 words, Title Case, not equal/substring of brief, contains a concrete noun, no banned tokens.
- **text_or_hook_ok**: within schema lengths; second‑person for hooks, first‑person present for scenes; ASCII only; includes ≥2 brief nouns.
- **choices_ok**: 2–4 items; label is a specific action; hint is a subtle consequence; no spoilers.
- **alignment_ok**: uses nouns/actions from brief; maintains internal logic; respects SCP cues if implied.
- **banned_ok**: title does not use banned tokens: Echo, Midnight, Whispers, Veil, Dreamer, Bazaar, Strange Night.

### 9) Minimal usage example (end‑to‑end)
```ts
const res = await fetch("https://api.signullrift.com/chat/completions", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${EnvironmentManager.shared.openAIAPIKeyRequired}`
  },
  body: JSON.stringify({
    model: "gpt-5-mini-2025-08-07",
    ...SCENES_PARAMS,
    messages: [
      { role: "system", content: SYSTEM_SIGNULL },
      { role: "user",   content: buildOpeningPrompt(
        "SCP lab lockdown under Site-19; I swipe a Level-2 card at a jammed blast door while alarms pulse; a researcher named Kline shouts over the intercom to move to Corridor C-7.",
        "Tags: SCP, Site-19, alarms, Level-2 card"
      ) }
    ]
  })
});

const completion = await res.json();
const raw = completion.choices?.[0]?.message?.content ?? "";
const { data: opening, after } = extractLeadingJSONAndAfter(raw);
// opening matches OpeningSchema; 'after' is the UI-ignored tip string
```

### 10) Cursor instructions (what to tell it explicitly)
- Do not change Chapter/Story view logic. Only update the LLM prompt builders and extractor.
- Enforce JSON-first + trailing AFTER:. Do not switch to response_format: "json_schema" here; it would block the AFTER: line.
- Wire decoding presets: IDEAS_PARAMS for idea calls; SCENES_PARAMS for opening + continuation.
- Implement candidate + repair pass (Section 7). If schema fails, run the repair prompt; otherwise return the winner.
- Add rubric asserts (Section 8). If any fail, trigger repair pass.
- Unit test with briefs that try to break rules (title equals brief; banned tokens; too-short hooks; missing player words in continuation).

---

This drop‑in keeps responses on‑brief, multi‑paragraph, and consumable by the app with a single pass.


