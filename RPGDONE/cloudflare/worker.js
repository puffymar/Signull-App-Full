// Model configuration - back to gpt-5-mini
const OPENAI_MODEL_MAIN = "gpt-5-mini";    // back to gpt-5-mini for higher quality
const OPENAI_MODEL_SIDE = "gpt-5-mini";    // consistent model for all operations

// Parse schema once at startup
let SIGNULL_SCHEMA_PARSED = null;

// Safety net function to normalize incoming payloads
function attachSchema(body, env) {
  // Parse schema if not already parsed
  if (!SIGNULL_SCHEMA_PARSED) {
    try {
      SIGNULL_SCHEMA_PARSED = JSON.parse(env.SIGNULL_SCHEMA);
    } catch (e) {
      console.error("Failed to parse SIGNULL_SCHEMA:", e);
      return body;
    }
  }
  
  // Auto-inject schema if missing
  if (!body.response_format || !body.response_format.json_schema?.schema) {
    body.response_format = {
      type: "json_schema",
      json_schema: { name: "SignullStory", schema: SIGNULL_SCHEMA_PARSED }
    };
  }
  
  // Handle format conversion: input <-> messages
  if (body.input && !body.messages) { 
    body.messages = body.input; 
    delete body.input; 
  } else if (body.messages && !body.input) { 
    body.input = body.messages; 
    delete body.messages; 
  }
  
  // Handle token parameter conversion
  if (body.max_tokens && !body.max_output_tokens) { 
    body.max_output_tokens = body.max_tokens; 
    delete body.max_tokens; 
  } else if (body.max_output_tokens && !body.max_tokens) {
    body.max_tokens = body.max_output_tokens;
    delete body.max_output_tokens;
  }
  
  return body;
}

// Helper functions for critic system
function parseMaybeJSON(s) {
  try { return JSON.parse(s) } catch { return null }
}

function looksBad(obj) {
  if (!obj || typeof obj !== "object") return true;
  const title = (obj.title || "").toLowerCase();
  const hook  = (obj.openingHook || obj.fullStory || "").toLowerCase();
  const theme = (obj.theme || "").toLowerCase();
  const setting = (obj.setting || "").toLowerCase();

  // Hard bans / boilerplate
  const bannedPhrases = [
    "your story begins here", 
    "the ai has thought", 
    "in this tale", 
    "the ai has responded", 
    "ai has responded", 
    "responded to your",
    "ai is thinking",
    "the ai is thinking",
    "ai responds to your",
    "the ai responds to your",
    "your mysticism",
    "responds to your mysticism"
  ];
  if (bannedPhrases.some(p => hook.includes(p))) return true;

  // The repeat you keep seeing
  if (title === "mysterious tale") return true;
  if (theme === "mystical" && /liminal space/i.test(setting)) return true;

  // Weak output guards
  if (title.length < 5 || (obj.fullStory || "").length < 300) return true;

  return false;
}

// KV cache for last N titles (avoid cross-run dupes)
async function seenRecently(env, title) {
  if (!title) return false;
  const key = `seen:${title.toLowerCase()}`;
  const exists = await env.RATE.get(key);
  if (!exists) await env.RATE.put(key, "1", { expirationTtl: 3600 }); // 1h
  return Boolean(exists);
}

export default {
  async fetch(req, env, ctx) {
    const url = new URL(req.url);
    
    // Health check endpoint
    if (url.pathname === "/health") {
      return new Response("ok", {
        headers: { "Content-Type": "text/plain" }
      });
    }
    
    // Logging endpoint
    if (url.pathname === "/log") {
      return logHandler(req, env);
    }

    // Seed prewarming endpoint
    if (url.pathname === "/seed" && req.method === "POST") {
      return await seedHandler(req, env, url);
    }

    // Get prewarmed seed endpoint
    if (url.pathname.startsWith("/seed/") && req.method === "GET") {
      return await getSeedHandler(req, env, url);
    }

    // Main responses endpoint
    if (url.pathname !== "/responses") {
      return new Response("Not found", { status: 404 });
    }
    
    if (req.method !== "POST") {
      return new Response("Method Not Allowed", { status: 405 });
    }

    // App authentication
    const appToken = req.headers.get("x-signull-auth");
    if (!appToken || appToken !== env.APP_TOKEN) {
      return new Response("Unauthorized", { status: 401 });
    }

    // Basic CORS
    const origin = req.headers.get("Origin") ?? "*";

    // Rate limiting (per IP per minute)
    const ip = req.headers.get("CF-Connecting-IP") ?? "0.0.0.0";
    const key = `ratelimit:${ip}:${new Date().getUTCMinutes()}`;
    const count = (await env.RATE.get(key)) ? parseInt(await env.RATE.get(key)) : 0;
    
    if (count > 60) {
      return new Response("Too Many Requests", { status: 429 });
    }
    
    await env.RATE.put(key, String(count + 1), { expirationTtl: 120 });

    // Read incoming JSON body and apply critic system
    const original = await req.json();

    // Apply safety net to normalize payload
    attachSchema(original, env);

    // Force json_schema response if client forgot
    original.response_format = original.response_format || {};
    original.response_format.type = "json_schema";

    // Set model and optimize for speed
    original.model = original.model || OPENAI_MODEL_MAIN;
    original.temperature = original.temperature ?? 0.7;  // Lower for faster, more focused responses
    original.max_output_tokens = original.max_output_tokens ?? 800;    // Limit tokens for faster generation
    original.top_p = original.top_p ?? 0.8;             // Slightly lower for faster responses

    // Call OpenAI (first attempt)
    let r = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${env.OPENAI_API_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(original)
    });
    const text1 = await r.text();

    // Try to parse JSON object out of response
    const obj1 = parseMaybeJSON(text1);
    // Check critic + recent dupes
    const bad1 = looksBad(obj1) || await seenRecently(env, obj1?.title);

    // If fine, return and remember title
    if (!bad1) {
      if (obj1?.title) await env.RATE.put(`seen:${obj1.title.toLowerCase()}`, "1", { expirationTtl: 3600 });
      return new Response(text1, { 
        status: r.status, 
        headers: { 
          "Content-Type": "application/json", 
          "Cache-Control": "no-store",
          "Access-Control-Allow-Origin": origin,
          "Access-Control-Allow-Headers": "Content-Type, x-signull-auth",
          "Access-Control-Allow-Methods": "POST, OPTIONS"
        }
      });
    }

    // Single retry with explicit bans + diversity nudge
    const banMsg = {
      role: "system",
      content: `CRITICAL: Write ONLY the story content. NEVER use meta-language like:
- "Your story begins here"
- "The AI has responded" / "AI has responded" / "AI is thinking"
- "The AI responds to your mysticism"
- "In this tale" / "In this story"
- Any variation of "AI responds to your"

Write as if you ARE the story itself. Drop the reader directly into the scene. No prefaces, no meta-commentary.`
    };

    // Add ban message to beginning of input
    original.input = original.input || [];
    original.input.unshift(banMsg);

    let r2 = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${env.OPENAI_API_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(original)
    });
    const text2 = await r2.text();
    const obj2 = parseMaybeJSON(text2);
    
    if (obj2?.title) await env.RATE.put(`seen:${obj2.title.toLowerCase()}`, "1", { expirationTtl: 3600 });
    return new Response(text2, { 
      status: r2.status, 
      headers: { 
        "Content-Type": "application/json", 
        "Cache-Control": "no-store",
        "Access-Control-Allow-Origin": origin,
        "Access-Control-Allow-Headers": "Content-Type, x-signull-auth",
        "Access-Control-Allow-Methods": "POST, OPTIONS"
      }
    });
  }
};

async function seedHandler(req, env, url) {
  // App authentication
  const appToken = req.headers.get("x-signull-auth");
  if (!appToken || appToken !== env.APP_TOKEN) {
    return new Response("Unauthorized", { status: 401 });
  }

  const body = await req.json();
  
  // Apply safety net to normalize payload
  attachSchema(body, env);
  
  const messages = body.messages || []; // system+user from client (composer), or server can compose too
  const payload = {
    model: OPENAI_MODEL_MAIN,
    messages,
    response_format: body.response_format || { type: "json_schema" },
    temperature: body.temperature ?? 0.7,  // Lower for faster responses
    top_p: body.top_p ?? 0.8,             // Lower for faster responses
    max_tokens: body.max_tokens ?? 600,    // Limit tokens for faster generation
    presence_penalty: body.presence_penalty ?? 0.5,  // Lower penalty for speed
    frequency_penalty: body.frequency_penalty ?? 0.3, // Lower penalty for speed
    stream: false
  };

  const r1 = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: { "Authorization": `Bearer ${env.OPENAI_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });
  const text1 = await r1.text();
  const obj1 = parseMaybeJSON(text1);

  // Single critic pass; no infinite retries
  if (looksBad(obj1)) {
    // Retry once with a ban nudge
    payload.messages = [
      { role: "system", content: "CRITICAL: Write ONLY story content. NEVER use meta-language like 'Your story begins here', 'AI is thinking', 'The AI responds to your mysticism', 'In this tale', or any variation of 'AI responds to your'. Write as if you ARE the story itself. Drop reader directly into scene." },
      ...messages
    ];
    const r2 = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: { "Authorization": `Bearer ${env.OPENAI_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const text2 = await r2.text();
    const obj2 = parseMaybeJSON(text2);

    // Return even if still weak; client has its own fallback
    if (obj2 && !looksBad(obj2)) {
      const key = `seed:${crypto.randomUUID()}`;
      await env.SEED.put(key, text2, { expirationTtl: 120 }); // ~2 min cache
      return new Response(JSON.stringify({ seedId: key, story: obj2 }), {
        status: 200, headers: { "Content-Type": "application/json", "Cache-Control": "no-store", "Access-Control-Allow-Origin": "*" }
      });
    }
    const key = `seed:${crypto.randomUUID()}`;
    await env.SEED.put(key, text2, { expirationTtl: 60 });
    return new Response(JSON.stringify({ seedId: key, story: obj2 ?? null }), {
      status: 200, headers: { "Content-Type": "application/json", "Cache-Control": "no-store", "Access-Control-Allow-Origin": "*" }
    });
  }

  const key = `seed:${crypto.randomUUID()}`;
  await env.SEED.put(key, text1, { expirationTtl: 120 });
  return new Response(JSON.stringify({ seedId: key, story: obj1 }), {
    status: 200, headers: { "Content-Type": "application/json", "Cache-Control": "no-store", "Access-Control-Allow-Origin": "*" }
  });
}

async function getSeedHandler(req, env, url) {
  const seedId = url.pathname.split("/").pop();
  const blob = await env.SEED.get(seedId);
  if (!blob) return new Response(JSON.stringify({ error: "not_found" }), { 
    status: 404, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
  });
  return new Response(blob, { 
    status: 200, headers: { "Content-Type": "application/json", "Cache-Control": "no-store", "Access-Control-Allow-Origin": "*" }
  });
}

async function logHandler(req, env) {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { 
      headers: { 
        "Access-Control-Allow-Origin": "*", 
        "Access-Control-Allow-Headers": "Content-Type" 
      }
    });
  }
  
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }
  
  const json = await req.text();
  
  // Store log entry with timestamp
  const logKey = `log:${Date.now()}:${Math.random()}`;
  await env.LOGS.put(logKey, json, { expirationTtl: 7 * 24 * 3600 }); // 7 days
  
  return new Response("ok", { 
    headers: { "Access-Control-Allow-Origin": "*" }
  });
} 