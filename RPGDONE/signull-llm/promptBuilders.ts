import { IdeaSchema, OpeningSchema, ContinueSchema } from "./schemas";

export const SYSTEM = `
You are SIGNULL—an atmospheric, psycho-spiritual story engine.
- Use concrete nouns from BRIEF/CONTEXT; modern tone; ASCII only.
- Scene text: TWO SHORT PARAGRAPHS total (4–7 sentences). First-person present.
- ≤2 short dialogue lines with speaker names when appropriate (e.g., [Reed] "…").
- If SCP implied: Site corridors, intercoms, badges, blast doors, labs—ground it.
- Choices: 2–4, label=specific action, hint=subtle consequence (no spoilers).
- STRICT: Output ONLY JSON per schema. No pre/post text.
`;

const asOneLine = (obj: any) => JSON.stringify(obj);

export const ideaUser = (brief: string) => `
ONE IDEA ONLY. Schema: ${asOneLine(IdeaSchema)}
USER BRIEF: "${brief}"
Title: 2–5 Title-Case words, concrete noun, not equal/substring of brief. No banned tokens: Echo, Midnight, Whispers, Veil, Dreamer, Bazaar, Strange Night.
Hook: 28–60 words, second-person vibe, include ≥2 nouns from brief. JSON ONLY.`;

export const openingUser = (brief: string, ctx?: string) => `
OPENING SCENE. Schema: ${asOneLine(OpeningSchema)}
USER BRIEF: "${brief}"
OPTIONAL CONTEXT: ${ctx ?? "none"}
Two short paragraphs total; include ≤2 dialogue lines if fitting, e.g., [Reed] "Doctor [Name], are you coming?". JSON ONLY.`;

export const continueUser = (playerInput: string, tail: string) => `
CONTINUE SCENE. Schema: ${asOneLine(ContinueSchema)}
PLAYER INPUT (use verbatim once): "${playerInput}"
CONTEXT TAIL: "${tail}"
Two short paragraphs total; preserve concrete details; JSON ONLY.`;
