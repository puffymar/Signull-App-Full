export const buildDynamicOpening = (user_prompt: string, context_hints?: string) => `
Generate OPENING SCENE JSON for this brief, then one \`AFTER:\` line.
schema: ${JSON.stringify(require("./templates/aistory_turn.schema.json"))}

USER BRIEF: "${user_prompt}"
OPTIONAL CONTEXT: ${context_hints ?? "none"}

Rubric:
- Title: 2–5 words, Title Case, not equal/substring of brief; concrete noun; no banned tokens.
- Text: two short paragraphs (4–7 sentences total), first-person present; ≤2 short dialogue lines with [Name] or [Reed] if given; must weave ≥2 nouns/details from brief/context; ASCII only.
- Choices: 2–4 specific action labels with subtle consequence hints.

Output ONLY the JSON, then one \`AFTER:\` line.
`;

export const buildDynamicContinue = (player_input: string, last_1000_chars: string) => `
Continue the scene in JSON format using schema: ${JSON.stringify(require("./templates/aistory_turn.schema.json"))}

PLAYER INPUT (use verbatim once): "${player_input}"
CONTEXT TAIL: "${last_1000_chars}"

Rubric:
- Includes PLAYER INPUT verbatim once, naturally in text.
- Text: two short paragraphs (4–7 sentences total); may include ≤2 short lines of dialogue with [Name] or [Reed]; concrete details from context preserved; ASCII only; no meta.
- Choices: 2–4 specific action labels with subtle hints; no spoilers.

Output ONLY the JSON, then one \`AFTER:\` line.
`;
