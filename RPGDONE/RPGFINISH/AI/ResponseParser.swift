import Foundation

struct AIStoryIdea: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let hook: String
    let tags: [String]
    let icon: String?
}

enum ResponseParser {
    static func parseIdeas(from data: Data) throws -> [AIStoryIdea] {
        let root = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        if
          let output = root?["output"] as? [[String: Any]],
          let msg = output.compactMap({ $0["content"] as? [[String: Any]] }).flatMap({ $0 }).first,
          let text = msg["text"] as? String,
          let idea = parseOneIdeaFromText(text)
        { return [idea] }

        if
          let message = root?["message"] as? [String: Any],
          let content = message["content"] as? [[String: Any]],
          let text = content.first?["text"] as? String,
          let idea = parseOneIdeaFromText(text)
        { return [idea] }

        if let idea = parseOneIdeaFromJSON(root) { return [idea] }

        if let choices = root?["choices"] as? [[String: Any]] {
            var ideas: [AIStoryIdea] = []
            for c in choices {
                if
                  let msg = c["message"] as? [String: Any],
                  let content = msg["content"] as? String,
                  let idea = parseOneIdeaFromText(content)
                { ideas.append(idea) }
            }
            if !ideas.isEmpty { return ideas }
        }

        throw NSError(domain: "ResponseParser", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not locate idea text"])
    }

    private static func parseOneIdeaFromText(_ text: String) -> AIStoryIdea? {
        guard
          let data = text.data(using: .utf8),
          let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return parseOneIdeaFromJSON(obj)
    }

    private static func parseOneIdeaFromJSON(_ obj: [String: Any]?) -> AIStoryIdea? {
        guard let o = obj else { return nil }
        let title = (o["title"] as? String)
            ?? (o["storyTitle"] as? String)
            ?? (o["name"] as? String)
            ?? "Untitled"
        let hook = (o["opening_hook"] as? String)
            ?? (o["openingHook"] as? String)
            ?? (o["hook"] as? String)
            ?? (o["opening"] as? String)
            ?? "A strange night begins at the harbor."
        let tags = (o["tags"] as? [String]) ?? []

        return AIStoryIdea(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            hook: hook.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: tags,
            icon: nil
        )
    }
}


