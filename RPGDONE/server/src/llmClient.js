import fetch from "node-fetch";

export async function chat(body) {
  const res = await fetch("https://api.signullrift.com/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${process.env.OPENAI_API_KEY ?? ""}`,
    },
    body: JSON.stringify(body)
  });
  const j = await res.json();
  return j.choices?.[0]?.message?.content ?? "";
}

export async function strictJson(messages) {
  return chat({
    model: "gpt-5-mini-2025-08-07",
    temperature: 0.8, top_p: 0.9, presence_penalty: 0.8, frequency_penalty: 0.3,
    response_format: { type: "json_object" },
    messages
  });
}
