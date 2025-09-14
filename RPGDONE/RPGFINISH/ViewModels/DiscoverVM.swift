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
        print("[DiscoverVM] start() called → transitioning to .genres")
        withAnimation(.easeIn(duration: 0.8)) { stage = .genres }
    }

    func pick(_ j: Journey) {
        print("[DiscoverVM] pick(\(j.rawValue))")
        selected = j
        generateCards(for: j)
    }

    func generateCards(for j: Journey) {
        print("[DiscoverVM] generateCards(for: \(j.title)) seed=\(j.seed)")
        isLoading = true; error = nil; ideas = []
        Task {
            do {
                async let a = api.idea(seed: j.seed)
                async let b = api.idea(seed: j.seed)
                async let c = api.idea(seed: j.seed)
                let outs = try await [a,b,c]
                await MainActor.run {
                    print("[DiscoverVM] ideas received: \(outs.map{ $0.title }.joined(separator: ", "))")
                    self.ideas = outs
                    self.stage = .generated
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("[DiscoverVM] generateCards error: \(error)")
                    self.error = (error as NSError).userInfo["body"] as? String ?? error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func openStory(from card: IdeaCard) {
        guard let j = selected else { return }
        print("[DiscoverVM] openStory(from: \(card.title)) brief=\(j.openingBrief)")
        isLoading = true; error = nil
        Task {
            do {
                let op = try await api.opening(brief: j.openingBrief, context: j.openingContext)
                await MainActor.run {
                    print("[DiscoverVM] opening title=\(op.title) chars=\(op.text.count) choices=\(op.choices.count)")
                    self.opening = op
                    self.storyTail = op.text
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("[DiscoverVM] opening error: \(error)")
                    self.error = (error as NSError).userInfo["body"] as? String ?? error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func continueStory(with player: String) async throws -> ContinueResponse {
        print("[DiscoverVM] continueStory input=\(player.prefix(80))… tailLen=\(storyTail.count)")
        let resp = try await api.continue(player: player, last1000: String(storyTail.suffix(1000)))
        storyTail += "\n\n" + resp.text
        print("[DiscoverVM] continue ok: +\(resp.text.count) chars choices=\(resp.choices.count)")
        return resp
    }

    func backToGenres() {
        print("[DiscoverVM] backToGenres()")
        withAnimation(.spring()) {
            stage = .genres
            ideas = []; opening = nil; error = nil
        }
    }
}


