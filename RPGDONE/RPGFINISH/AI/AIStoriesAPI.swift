import Foundation

public final class AIStoriesAPI {
    private let base = SignullConfig.proxyURL.appendingPathComponent("v1/aistories")

    private func post<T: Decodable>(_ path: String, _ body: [String: Any]) async throws -> T {
        var req = URLRequest(url: base.appendingPathComponent(path))
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        SignullAuth.apply(to: &req)
        let (data, resp) = try await SignullClient.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "AIStoriesAPI", code: (resp as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [
                "body": String(data: data, encoding: .utf8) ?? ""
            ])
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    public func idea(seed: String) async throws -> IdeaCard {
        try await post("idea", ["seed": seed])
    }

    public func opening(brief: String, context: String) async throws -> OpeningResponse {
        try await post("opening", ["brief": brief, "context_hints": context])
    }

    public func `continue`(player: String, last1000: String) async throws -> ContinueResponse {
        try await post("continue", ["player_input": player, "last_1000": last1000])
    }
}


