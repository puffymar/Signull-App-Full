import Ajv from "ajv";
const ajv = new Ajv({ allErrors: true, removeAdditional: "failing" });

export const IdeaSchema = {
  type: "object",
  properties: {
    title: { type: "string", minLength: 12, maxLength: 60 },
    hook:  { type: "string", minLength: 28, maxLength: 160 }
  },
  required: ["title","hook"],
  additionalProperties: false
} as const;

export const OpeningSchema = {
  type: "object",
  properties: {
    title: { type: "string", minLength: 12, maxLength: 60 },
    text:  { type: "string", minLength: 300, maxLength: 1200 },
    choices: {
      type: "array", minItems: 2, maxItems: 4, items: {
        type: "object",
        properties: {
          label: { type: "string", minLength: 3,  maxLength: 48 },
          hint:  { type: "string", minLength: 6,  maxLength: 80 }
        },
        required: ["label","hint"],
        additionalProperties: false
      }
    }
  },
  required: ["title","text","choices"],
  additionalProperties: false
} as const;

export const ContinueSchema = {
  type: "object",
  properties: {
    text: { type: "string", minLength: 220, maxLength: 900 },
    choices: {
      type: "array", minItems: 2, maxItems: 4, items: {
        type: "object",
        properties: {
          label: { type: "string", minLength: 3,  maxLength: 48 },
          hint:  { type: "string", minLength: 6,  maxLength: 80 }
        },
        required: ["label","hint"],
        additionalProperties: false
      }
    }
  },
  required: ["text","choices"],
  additionalProperties: false
} as const;

type Validator<T> = (v: unknown) => v is T;

export const validateIdea:  Validator<any> = ajv.compile(IdeaSchema) as any;
export const validateOpen:  Validator<any> = ajv.compile(OpeningSchema) as any;
export const validateTurn:  Validator<any> = ajv.compile(ContinueSchema) as any;

export function assertValid<T>(validate: Validator<T>, obj: unknown, tag: string): T {
  if (validate(obj)) return obj as T;
  const msg = (validate as any).errors?.map((e: any) => `${e.instancePath} ${e.message}`).join("; ") || "unknown";
  throw new Error(`SCHEMA_FAIL[${tag}]: ${msg}`);
}
