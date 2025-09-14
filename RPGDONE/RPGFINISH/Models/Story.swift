import Foundation

// MARK: - New Story Data Model (Matching Surgical Fix Schema)
struct Story: Codable {
    struct World: Codable { 
        let premise: String
        let history: String 
    }
    
    struct Cast: Codable { 
        let name: String
        let role: String
        let one_liner: String 
    }
    
    struct StoryBody: Codable { 
        let synopsis: String
        let beats: [String] 
    }
    
    struct Choice: Codable { 
        let label: String
        let hint: String 
    }

    let title: String
    let genre: String
    let tags: [String]
    let world: World
    let cast: [Cast]
    let story: StoryBody
    let player_in: String
    let choices: [Choice]
}

// MARK: - Responses API Decoder
struct ResponsesAPI: Decodable {
    struct OutputItem: Decodable {
        let id: String
        let type: String
        let status: String?
        struct ContentItem: Decodable {
            let type: String
            let text: String?
        }
        let content: [ContentItem]?
    }
    let id: String
    let status: String
    let output: [OutputItem]
}

// MARK: - Helper Functions
func extractText(from response: ResponsesAPI) -> String? {
    for block in response.output {
        if block.type == "message" {
            for c in block.content ?? [] where c.type == "output_text" {
                return c.text
            }
        }
    }
    return nil
}

func parseStory(from raw: String) throws -> Story {
    // 1) try direct JSON
    if let data = raw.data(using: .utf8) {
        if let obj = try? JSONDecoder().decode(Story.self, from: data) {
            return obj
        }
        // 2) try to extract JSON substring (guards when model wraps text)
        if let start = raw.firstIndex(of: "{"), let end = raw.lastIndex(of: "}") {
            let jsonSlice = raw[start...end]
            if let data2 = String(jsonSlice).data(using: .utf8),
               let obj2 = try? JSONDecoder().decode(Story.self, from: data2) {
                return obj2
            }
        }
    }
    // 3) fallback: synthesize minimal Story from plain text
    struct Fallback: Error {}
    throw Fallback()
}

func decodeStory(from data: Data) throws -> Story {
    let api = try JSONDecoder().decode(ResponsesAPI.self, from: data)
    guard let raw = extractText(from: api) else { throw NSError() }
    return try parseStory(from: raw)
}
