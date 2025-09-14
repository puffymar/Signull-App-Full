export const buildRepair = (schemaJson: any, badJson: any, hint: string) => `
FIX ONLY to satisfy this JSON schema. Preserve valid content. Output JSON ONLY.
SCHEMA: ${JSON.stringify(schemaJson)}
BROKEN_JSON: ${JSON.stringify(badJson)}
HINT: ${hint}
`;
