import fetch from "node-fetch";
import { SYSTEM, ideaUser, openingUser, continueUser } from "./promptBuilders";
import { IdeaSchema, OpeningSchema, ContinueSchema, assertValid, validateIdea, validateOpen, validateTurn } from "./schemas";
import { buildRepair } from "./repair";

type RoleMsg = { role: "system"|"user"; content: string };

async function chat(body: any) {
  const res = await fetch("https://api.signullrift.com/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${process.env.OPENAI_API_KEY!}`,
    },
    body: JSON.stringify(body)
  });
  const j = await res.json();
  return j.choices?.[0]?.message?.content ?? "";
}

async function strictJson(messages: RoleMsg[]) {
  return chat({
    model: "gpt-5-mini-2025-08-07",
    temperature: 0.8, top_p: 0.9, presence_penalty: 0.8, frequency_penalty: 0.3,
    response_format: { type: "json_object" },
    messages
  });
}

async function onceWithRepair(schema: any, validate: (v:any)=>boolean, sys: string, usr: string) {
  const raw = await strictJson([{ role: "system", content: sys }, { role: "user", content: usr }]);
  let parsed: any;
  try { parsed = JSON.parse(raw); } catch { parsed = null; }
  if (parsed && validate(parsed)) return parsed;

  const repaired = await strictJson([
    { role: "system", content: sys },
    { role: "user", content: buildRepair(schema, parsed ?? raw, "Make minimal edits to pass the schema; keep content.") }
  ]);
  const reparsed = JSON.parse(repaired);
  if (validate(reparsed)) return reparsed;
  throw new Error("LLM_REPAIR_FAILED: " + JSON.stringify(reparsed));
}

export async function genIdea(brief: string) {
  return onceWithRepair(IdeaSchema, validateIdea, SYSTEM, ideaUser(brief));
}

export async function genOpening(brief: string, ctx?: string) {
  return onceWithRepair(OpeningSchema, validateOpen, SYSTEM, openingUser(brief, ctx));
}

export async function genContinue(playerInput: string, tail: string) {
  return onceWithRepair(ContinueSchema, validateTurn, SYSTEM, continueUser(playerInput, tail));
}
