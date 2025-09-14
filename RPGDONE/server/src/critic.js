const BANNED = /\b(Echo|Midnight|Whispers|Veil|Dreamer|Bazaar|Strange Night)\b/i;
const STOP = new Set(["the","a","an","and","or","of","to","in","on","for","with","you","your","i","my","me","is","are","was","were","it","at","as","by","from","that","this","these","those"]);

export function extractKeywords(src = "", extra = "") {
  const BASE = (src + " " + extra)
    .replace(/[^a-z0-9\s\-]/gi, " ")
    .split(/\s+/)
    .map(w => w.trim())
    .filter(w => w.length >= 3 && !STOP.has(w.toLowerCase()));
  const uniq = Array.from(new Set(BASE.map(w => w.toLowerCase())));
  const bias = ["camera","cameras","badge","level","door","blast","intercom","vent","corridor","lab","reader","site","pressure","coolant","lens"];
  const out = Array.from(new Set([...bias, ...uniq]));
  return out.slice(0, 30);
}

function containsAtLeastN(str, words, n) {
  let count = 0;
  const set = new Set(words.map(w => w.toLowerCase()));
  for (const w of str.toLowerCase().split(/\W+/)) {
    if (set.has(w)) count++;
    if (count >= n) return true;
  }
  return false;
}

export function critiqueIdea(out, seed, keywords) {
  const reasons = []; const wantRepair = [];
  const title = (out?.title || "").toString().trim();
  const hook  = (out?.hook  || "").toString().trim();
  const seedLC = (seed || "").toString().toLowerCase();
  if (!title || title.toLowerCase() === seedLC || /\bscp\b/i.test(title)) {
    reasons.push("Title equals/contains seed token.");
    wantRepair.push({ field: "title", hint: "Rewrite title: 2–5 words, Title Case, include a concrete keyword, do not use the seed token." });
  }
  if (BANNED.test(title)) { reasons.push("Title uses banned token."); wantRepair.push({ field: "title", hint: "Remove banned tokens." }); }
  if (!containsAtLeastN(title, keywords, 1)) { reasons.push("Title missing keyword."); wantRepair.push({ field: "title", hint: "Include at least one concrete keyword." }); }
  if (hook.length < 28 || hook.length > 160) { reasons.push("Hook length invalid."); wantRepair.push({ field: "hook", hint: "Rewrite hook to 28–60 words." }); }
  if (!containsAtLeastN(hook, keywords, 2)) { reasons.push("Hook missing ≥2 keywords."); wantRepair.push({ field: "hook", hint: "Include at least two keywords naturally." }); }
  return { ok: reasons.length === 0, reasons, wantRepair };
}

export function critiqueOpen(out, brief, ctx, keywords) {
  const reasons = []; const wantRepair = [];
  const title = (out?.title || "").toString().trim();
  const text  = (out?.text  || "").toString().trim();
  const choices = Array.isArray(out?.choices) ? out.choices : [];
  if (!title || /\bscp\b/i.test(title) || title.toLowerCase() === (brief||"").toString().toLowerCase()) {
    reasons.push("Title equals/contains seed/brief token or equals brief.");
    wantRepair.push({ field: "title", hint: "Rewrite title: 2–5 words, include ≥1 keyword, avoid seed token." });
  }
  if (BANNED.test(title)) { reasons.push("Title uses banned token."); wantRepair.push({ field: "title", hint: "Remove banned tokens." }); }
  if (!containsAtLeastN(title, keywords, 1)) { reasons.push("Title missing keyword."); wantRepair.push({ field: "title", hint: "Include a concrete keyword." }); }
  const paras = text.split(/\n{2,}/);
  if (paras.length < 2) { reasons.push("Text must be two short paragraphs."); wantRepair.push({ field: "text", hint: "Two short paragraphs (4–7 sentences total), first-person present, ≤2 dialogue lines." }); }
  if (!containsAtLeastN(text, keywords, 2)) { reasons.push("Text missing ≥2 keywords."); wantRepair.push({ field: "text", hint: "Weave at least two concrete keywords (camera, badge, blast door, intercom, corridor, etc.)." }); }
  if (choices.length < 2 || choices.length > 4) { reasons.push("Choices count invalid."); wantRepair.push({ field: "choices", hint: "Return 2–4 specific action choices with subtle hints." }); }
  return { ok: reasons.length === 0, reasons, wantRepair };
}

export function critiqueTurn(out, playerInput) {
  const reasons = []; const wantRepair = [];
  const text = (out?.text || "").toString();
  const pi = (playerInput || "").toString();
  if (pi.trim().length > 0) {
    const esc = pi.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    const occurrences = (text.match(new RegExp(esc, "g")) || []).length;
    if (occurrences === 0) { reasons.push("Player input missing."); wantRepair.push({ field: "text", hint: "Include the player's words verbatim once, naturally." }); }
    if (occurrences > 1) { reasons.push("Player input repeated."); wantRepair.push({ field: "text", hint: "Use the player's words exactly once." }); }
  }
  const paras = text.split(/\n{2,}/);
  if (paras.length < 2) { reasons.push("Text must be two short paragraphs."); wantRepair.push({ field: "text", hint: "Two short paragraphs (4–7 sentences total)." }); }
  const choices = Array.isArray(out?.choices) ? out.choices : [];
  if (choices.length < 2 || choices.length > 4) { reasons.push("Choices count invalid."); wantRepair.push({ field: "choices", hint: "Return 2–4 choices, specific action labels + subtle hints." }); }
  return { ok: reasons.length === 0, reasons, wantRepair };
}
