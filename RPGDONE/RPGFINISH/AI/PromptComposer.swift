import Foundation

struct Seed: Codable { let theme: String; let setting: String; let starter: String }
struct SeedBank: Codable { let seeds: [Seed] }

enum DiversityMode { case rotate, random }

final class PromptComposer {
    private static var cachedSeeds: [Seed] = {
        guard let url = Bundle.main.url(forResource: "StorySeeds", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let seedBank = try? JSONDecoder().decode(SeedBank.self, from: data) else {
            print("⚠️ Failed to load StorySeeds.json, using fallback")
            return [Seed(theme: "urban", setting: "liminal stairwell", starter: "Keys are ticking in the lock.")]
        }
        return seedBank.seeds
    }()
    private var index = 0

    func nextSeed(_ mode: DiversityMode = .rotate) -> Seed {
        guard !Self.cachedSeeds.isEmpty else {
            return Seed(theme: "urban", setting: "liminal stairwell", starter: "Keys are ticking in the lock.")
        }
        switch mode {
        case .rotate:
            defer { index = (index + 1) % Self.cachedSeeds.count }
            return Self.cachedSeeds[index]
        case .random:
            return Self.cachedSeeds.randomElement()!
        }
    }

    func systemPrompt() -> String {
        """
        You are SIGNULL — an atmospheric, psycho-spiritual story engine.

        Immersion rules (MANDATORY):
        - Write everything in first-person present (I, my). The player is the speaker.
        - NPCs speak directly to me using quoted dialogue; include names.
        - Respond to the user's exact words and intent, not generic actions.
        - Keep paragraphs short (2–3 sentences), vivid, and concrete. No walls of text.
        - Make concepts COMPLETELY ORIGINAL. No reused motifs, no generic fantasy tropes, no "explorer/cartographer" clichés, no virus/salt motifs.

        Hard rules:
        - Output ONLY the JSON object defined by the provided schema.
        - No meta language or boilerplate (ban: "your story begins here", "the AI has thought", "in this tale").
        - Start in media res; openingHook must drop the reader directly into the scene.
        - Language: cinematic, concrete, sensory; no clichés; keep internal logic consistent.
        """
    }

    func storyUserPrompt(seed: Seed, ws: WorldState, npcs: [NPC]) -> String {
        let npcSummary = npcs.prefix(4).map { "\($0.id): affinity=\($0.affinity), tags=\($0.tags.joined(separator: ","))" }.joined(separator: " | ")
        return """
        Output ONLY the JSON object per provided schema; no prose outside JSON. Then, after the JSON, include a short human-readable guidance line starting with 'AFTER:' that gives 1 sentence on how to continue (this is not part of the JSON).
        Write a Signull scene with these constraints (first-person present):
        - I am the speaker; use "I" and "my" throughout.
        - NPCs address me; include quoted dialogue with names.
        - Keep 3–4 short paragraphs (2–3 sentences each). No long blocks.
        - Concept must be fresh and unprecedented. No recycled motifs.

        theme: \(seed.theme)
        setting: \(seed.setting)
        openingHook inspiration: \(seed.starter)

        worldState:
        season=\(ws.season), timeOfDay=\(ws.timeOfDay), tension=\(ws.tension)
        flags=\(ws.flags.joined(separator:","))
        inventory=\(ws.inventory.joined(separator:","))
        npcAffinity=[\(npcSummary)]

        Length: 3–4 short paragraphs. End on a sharp cliffhanger.
        Provide 3–4 consequential choices with subtle hints (no spoilers).
        """
    }

    func continueUserPrompt(context: StoryData, ws: WorldState, npcs: [NPC], playerInput: String) -> String {
        let npcSummary = npcs.prefix(4).map { "\($0.id): affinity=\($0.affinity)" }.joined(separator: " | ")
        return """
        Continue the scene in-world, same voice and tone, first-person present.
        - DIRECTLY incorporate the player's latest words verbatim at least once.
        - 2–3 short paragraphs (2–4 sentences each); no meta, no repetition.
        - Keep it original; avoid any previously used lines.

        Prior context:
        title=\(context.title)
        theme=\(context.theme)
        setting=\(context.setting)
        last text (tail): \(String(context.fullStory.suffix(1000)))

        worldState(season=\(ws.season), timeOfDay=\(ws.timeOfDay), tension=\(ws.tension), flags=\(ws.flags.joined(separator:",")), inventory=\(ws.inventory.joined(separator:",")))
        npcAffinity=[\(npcSummary)]

        Player input (use verbatim once): "\(playerInput)"

        Output story text only; no meta or prefaces.
        """
    }
} 