import Foundation
import SwiftUI

@MainActor
final class AIStoriesViewModel: ObservableObject {
    enum Phase { case idle, preparing, generating(Int, Int), ready, failed(String) }
    @Published var phase: Phase = .idle
    @Published var ideas: [StoryIdea] = []

    private var task: Task<Void, Never>?

    func generateIdeas() {
        task?.cancel()
        ideas.removeAll()
        phase = .preparing

        task = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)

            let target = 3
            var produced = 0
            phase = .generating(produced, target)

            for i in 0..<target {
                guard !Task.isCancelled else { return }
                do {
                    let dto = try await fetchIdeaDTO()
                    let idea = StoryIdea(
                        title: dto.resolvedTitle,
                        hook: dto.resolvedHook,
                        tags: dto.tags ?? autoTags(from: dto.resolvedHook),
                        thumbSeed: Int.random(in: 0...999_999),
                        accent: [.cyan, .mint, .purple, .blue, .teal].randomElement()!
                    )
                    ideas.append(idea)
                } catch {
                    ideas.append(StoryIdea(
                        title: "Signal Break • \(i+1)",
                        hook: "The server blinked—your story survived anyway.",
                        tags: ["retryable", "offline"],
                        thumbSeed: Int.random(in: 0...999_999),
                        accent: .orange
                    ))
                }
                produced += 1
                phase = .generating(produced, target)
            }
            phase = .ready
        }
    }

    func cancel() { task?.cancel() }

    // MARK: - Networking (placeholder)
    private func fetchIdeaDTO() async throws -> IdeaDTO {
        // Replace this with SignullAPI call; keeping lightweight placeholder to compile
        let sample = #"{"title":"Moon Market","hook":"Stalls close as the tide rises; a bell tolls from the clocktower."}"#
        let data = Data(sample.utf8)
        return try JSONDecoder().decode(IdeaDTO.self, from: data)
    }

    private func autoTags(from s: String) -> [String] {
        let lower = s.lowercased()
        var tags: [String] = []
        if lower.contains("harbor") || lower.contains("lighthouse") || lower.contains("tide") { tags.append("coastal") }
        if lower.contains("night") || lower.contains("lantern") || lower.contains("moon") { tags.append("nocturne") }
        if lower.contains("clock") || lower.contains("time") { tags.append("temporal") }
        if tags.isEmpty { tags = ["mystical"] }
        return tags
    }
}

