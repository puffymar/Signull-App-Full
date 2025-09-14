// DEBUG scaffold API for local testing. Not used in release.
#if DEBUG
import Foundation

public struct DevAITurnRequest: Codable {
    public let context: String
    public let player_input: String
}
#endif

public final class DevAIStoriesAPI {
    private let endpoint = URL(string: "https://api.signullrift.com/chat/completions")!
    private let session = URLSession(configuration: .default)
    private let apiKey: String = EnvironmentManager.shared.openAIAPIKeyRequired

    private let systemPrompt: String = """
Role: Continue the current story for the StoryView.
Rules: JSON-first per aistory_turn.schema.json.
- text = two short paragraphs total (4–7 sentences), 1st-person present.
- React precisely to player_input and context.
- If player_input is empty/whitespace, treat as "observe silently" and proceed.
- Optional single npc_line like [Samson] "Alright".
- Provide four choices: types think|act|say|intervene with specific labels + subtle hints.
- ASCII only; no clichés; do not echo prior lines.
"""

    public func turn(context: String, playerInput raw: String) async throws -> DevTurnResponse {
        let playerInput = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let payload: [String: Any] = [
            "model": "gpt-5-mini-2025-08-07",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content":
                 """
                 Context: \(context.prefix(1000))
                 PLAYER_INPUT: \(playerInput)
                 Return JSON exactly as:
                 {
                   "text":"two short paragraphs",
                   "npc_line":"optional",
                   "choices":[
                     {"type":"think","label":"string","hint":"string"},
                     {"type":"act","label":"string","hint":"string"},
                     {"type":"say","label":"string","hint":"string"},
                     {"type":"intervene","label":"string","hint":"string"}
                   ]
                 }
                 """
                ]
            ],
            "temperature": 0.8, "top_p": 0.9,
            "response_format": ["type": "json_object"]
        ]

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "AIStoriesAPI", code: (resp as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [
                "body": String(data: data, encoding: .utf8) ?? ""
            ])
        }
        struct Wire: Decodable { struct ChoiceMsg: Decodable { struct Msg: Decodable { let content: String } let message: Msg }; let choices: [ChoiceMsg] }
        let wire = try JSONDecoder().decode(Wire.self, from: data)
        guard let jsonText = wire.choices.first?.message.content.data(using: .utf8) else {
            throw NSError(domain: "AIStoriesAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Empty content"]) }
        return try JSONDecoder().decode(DevTurnResponse.self, from: jsonText)
    }
}
