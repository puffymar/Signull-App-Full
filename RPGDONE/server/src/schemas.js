export const OpeningSchema = {
  type: "object",
  properties: {
    title: { type: "string", minLength: 12, maxLength: 60 },
    text: { type: "string", minLength: 300, maxLength: 1200 },
    choices: {
      type: "array", minItems: 2, maxItems: 4, items: {
        type: "object",
        properties: {
          label: { type: "string", minLength: 3, maxLength: 48 },
          hint: { type: "string", minLength: 6, maxLength: 80 }
        },
        required: ["label","hint"], additionalProperties: false
      }
    }
  },
  required: ["title","text","choices"],
  additionalProperties: false
};

export const ContinueSchema = {
  type: "object",
  properties: {
    text: { type: "string", minLength: 220, maxLength: 900 },
    choices: {
      type: "array", minItems: 2, maxItems: 4, items: {
        type: "object",
        properties: {
          label: { type: "string", minLength: 3, maxLength: 48 },
          hint: { type: "string", minLength: 6, maxLength: 80 }
        },
        required: ["label","hint"], additionalProperties: false
      }
    }
  },
  required: ["text","choices"],
  additionalProperties: false
};

export const IdeaSchema = {
  type: "object",
  properties: {
    title: { type: "string", minLength: 12, maxLength: 60 },
    hook:  { type: "string", minLength: 28, maxLength: 160 },
    tags:  { type: "array", items: { type: "string" }, minItems: 0, maxItems: 5 }
  },
  required: ["title","hook"],
  additionalProperties: false
};
