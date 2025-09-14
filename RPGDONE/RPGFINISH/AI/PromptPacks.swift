import Foundation

enum PromptPack: String { case scp, tlou, defaultPack }

func pack(for seed: String) -> PromptPack {
    let s = seed.lowercased()
    if s.contains("scp") { return .scp }
    if s.contains("tlou") || s.contains("last of us") { return .tlou }
    return .defaultPack
}

func systemFor(seed: String) -> String {
    switch pack(for: seed) {
    case .scp:
        return """
        You write interactive scenes for a modern containment universe (SCP-adjacent). Rules:
        - Voice: first-person present, tight, clinical but human; short, vivid.
        - Setting: underground site corridors, observation rooms, blast doors, negative-pressure labs.
        - NPCs speak like professionals under stress. Include at most 2 short lines of dialogue per scene.
        - No clichés, no “virus/salt/nightmare/ancient curse” crutches. No generic harbors/markets/villages unless the brief says so.
        - Output JSON ONLY that satisfies the provided JSON schema.
        """
    case .tlou:
        return """
        You write interactive scenes in a grounded post‑pandemic world (TLOU‑adjacent). Rules:
        - Voice: first‑person present, spare, tactile; weathered gear, scarcity, urban rot.
        - Use specific, contemporary details; show danger via environment and NPC choices.
        - Avoid cliché apocalypse beats unless requested. Output JSON ONLY per schema.
        """
    case .defaultPack:
        return """
        You write interactive scenes from user intent. Rules:
        - First‑person present. Short, vivid, modern tone. No clichés, no generic harbors/markets/villages.
        - Always react to PLAYER INPUT precisely. Output JSON ONLY per schema.
        """
    }
}

func openingUserPrompt(seed: String, title: String) -> String {
    """
    Continue with an OPENING SCENE.

    Brief: \(seed)
    Title: \(title)

    Return:
    {
      "text": "two short paragraphs (4–7 sentences total), first‑person present, includes at most 2 short lines of NPC dialogue, no meta",
      "choices": [
        {"label":"specific action", "hint":"subtle consequence"},
        {"label":"specific action", "hint":"subtle consequence"}
      ]
    }

    Rules:
    - Do not repeat or echo the brief.
    - Modern tone; ASCII only; no clichés; no generic locales unless brief said so.
    - If brief implies SCP, lean containment site (labs, intercom, blast doors).
    """
}

func continuationUserPrompt(tail: String, playerInput: String) -> String {
    """
    Continue the story from PLAYER INPUT.

    Context (tail, last ~1000 chars of story so far):
    «\(tail)»

    PLAYER INPUT: «\(playerInput)»

    Return:
    {
      "text": "two short paragraphs",
      "choices": [
        {"label":"specific action", "hint":"subtle consequence"},
        {"label":"specific action", "hint":"subtle consequence"}
      ]
    }

    Rules:
    - First‑person present.
    - React precisely to PLAYER INPUT (words + intent). Show immediate world/NPC response.
    - 4–7 sentences total. No meta‑text. Do not restate prior lines.
    - Modern tone; ASCII only.
    """
}


