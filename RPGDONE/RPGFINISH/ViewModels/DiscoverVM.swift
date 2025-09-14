import Foundation
import SwiftUI

@MainActor
final class DiscoverVM: ObservableObject {
    @Published var stage: Stage = .loading
    @Published var selected: Journey? = nil
    @Published var ideas: [IdeaCard] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    @Published var opening: OpeningResponse? = nil
    @Published var storyTail: String = ""

    enum Stage { case loading, genres, generated }

    private let api = AIStoriesAPI()

    func start() {
        withAnimation(.easeIn(duration: 0.8)) { stage = .genres }
    }

    func pick(_ j: Journey) {
        selected = j
        generateCards(for: j)
    }

    func generateCards(for j: Journey) {
        isLoading = true; error = nil; ideas = []
        Task {
            do {
                async let a = api.idea(seed: j.seed)
                async let b = api.idea(seed: j.seed)
                async let c = api.idea(seed: j.seed)
                let outs = try await [a,b,c]
                await MainActor.run {
                    self.ideas = outs
                    self.stage = .generated
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = (error as NSError).userInfo["body"] as? String ?? error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func openStory(from card: IdeaCard) {
        guard let j = selected else { return }
        isLoading = true; error = nil
        Task {
            do {
                let op = try await api.opening(brief: j.openingBrief, context: j.openingContext)
                await MainActor.run {
                    self.opening = op
                    self.storyTail = op.text
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = (error as NSError).userInfo["body"] as? String ?? error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func continueStory(with player: String) async throws -> ContinueResponse {
        let resp = try await api.continue(player: player, last1000: String(storyTail.suffix(1000)))
        storyTail += "\n\n" + resp.text
        return resp
    }

    func backToGenres() {
        withAnimation(.spring()) {
            stage = .genres
            ideas = []; opening = nil; error = nil
        }
    }
}


