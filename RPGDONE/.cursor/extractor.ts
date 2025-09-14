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
  const afterLine = raw.slice(end + 1).trim().split('\n').find(l => l.startsWith('AFTER:')) ?? "";
  return { data, after: afterLine.replace(/^AFTER:\s*/, '') };
}
