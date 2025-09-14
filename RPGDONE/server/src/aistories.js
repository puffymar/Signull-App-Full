import { Router } from "express";
import Ajv from "ajv";
import { OpeningSchema, ContinueSchema, IdeaSchema } from "./schemas.js";
import { SYSTEM, ideaUser, openingUser, continueUser } from "./promptBuilders.js";
import { strictJson } from "./llmClient.js";
import { extractKeywords, critiqueIdea, critiqueOpen, critiqueTurn } from "./critic.js";

const ajv = new Ajv({ allErrors: true, removeAdditional: "failing" });
const vOpen = ajv.compile(OpeningSchema);
const vTurn = ajv.compile(ContinueSchema);
const vIdea = ajv.compile(IdeaSchema);

const r = Router();

async function repairOnce(schema, bad, hint) {
  return strictJson([
    { role: "system", content: SYSTEM },
    { role: "user", content: `FIX ONLY to satisfy this JSON schema. Preserve valid content. JSON ONLY.\nSCHEMA: ${JSON.stringify(schema)}\nBROKEN_JSON: ${JSON.stringify(bad)}\nHINT: ${hint}` }
  ]);
}

r.post("/opening", async (req, res) => {
  const { brief, context_hints } = req.body ?? {};
  try {
    const usr = openingUser((brief ?? "").toString(), (context_hints ?? "").toString());
    let out = await strictJson([{ role: "system", content: SYSTEM }, { role: "user", content: usr }]);
    if (!vOpen(out)) out = await repairOnce(OpeningSchema, out, "Fix to OpeningSchema.");

    // critic loop
    const kw = extractKeywords(brief ?? "", context_hints ?? "");
    let crit = critiqueOpen(out, brief ?? "", context_hints ?? "", kw);
    for (let i = 0; i < 2 && !crit.ok; i++) {
      out = await repairOnce(OpeningSchema, out, crit.wantRepair.map(w => `${w.field.toUpperCase()}: ${w.hint}`).join("\n"));
      crit = critiqueOpen(out, brief ?? "", context_hints ?? "", kw);
    }
    if (!crit.ok) return res.status(422).json({ error: "critic_open_failed", reasons: crit.reasons });

    res.json(out);
  } catch (e) {
    res.status(500).json({ error: "proxy_opening_failed", message: String(e) });
  }
});

r.post("/continue", async (req, res) => {
  const { player_input, last_1000 } = req.body ?? {};
  try {
    const usr = continueUser((player_input ?? "").toString(), (last_1000 ?? "").toString());
    let out = await strictJson([{ role: "system", content: SYSTEM }, { role: "user", content: usr }]);
    if (!vTurn(out)) out = await repairOnce(ContinueSchema, out, "Fix to ContinueSchema.");

    let crit = critiqueTurn(out, player_input ?? "");
    for (let i = 0; i < 2 && !crit.ok; i++) {
      out = await repairOnce(ContinueSchema, out, crit.wantRepair.map(w => `${w.field.toUpperCase()}: ${w.hint}`).join("\n"));
      crit = critiqueTurn(out, player_input ?? "");
    }
    if (!crit.ok) return res.status(422).json({ error: "critic_continue_failed", reasons: crit.reasons });

    res.json(out);
  } catch (e) {
    res.status(500).json({ error: "proxy_continue_failed", message: String(e) });
  }
});

r.post("/idea", async (req, res) => {
  const { seed, extraHints } = req.body ?? {};
  try {
    const usr = ideaUser((seed ?? "").toString(), (extraHints ?? "").toString());
    let out = await strictJson([{ role: "system", content: SYSTEM }, { role: "user", content: usr }]);
    if (!vIdea(out)) out = await repairOnce(IdeaSchema, out, "Fix to IdeaSchema.");

    const kw = extractKeywords(seed ?? "", extraHints ?? "");
    let crit = critiqueIdea(out, seed ?? "", kw);
    for (let i = 0; i < 2 && !crit.ok; i++) {
      out = await repairOnce(IdeaSchema, out, crit.wantRepair.map(w => `${w.field.toUpperCase()}: ${w.hint}`).join("\n"));
      crit = critiqueIdea(out, seed ?? "", kw);
    }
    if (!crit.ok) return res.status(422).json({ error: "critic_idea_failed", reasons: crit.reasons });

    res.json(out);
  } catch (e) {
    res.status(500).json({ error: "proxy_idea_failed", message: String(e) });
  }
});

export default r;
