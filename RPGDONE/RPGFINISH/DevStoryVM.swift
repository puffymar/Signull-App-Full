// DEBUG scaffold VM for local testing. Not used in release.
#if DEBUG
import Foundation
import SwiftUI

@MainActor
final class DevStoryVM: ObservableObject {
    @Published var input: String = ""
    @Published var storyText: String = ""
    @Published var npcLine: String? = nil
    @Published var choices: [DevTurnChoice] = []
    @Published var isLoading = false
    @Published var error: String? = nil

    private let api = DevAIStoriesAPI()
    private var contextBuffer: String = ""

    func appendToContext(_ newText: String) {
        contextBuffer += (contextBuffer.isEmpty ? "" : "\n\n") + newText
        if contextBuffer.count > 1400 {
            contextBuffer = String(contextBuffer.suffix(1200))
        }
    }

    func submitTurn() {
        Task {
            isLoading = true; error = nil
            let user = input
            do {
                let resp = try await api.turn(context: contextBuffer, playerInput: user)
                storyText = resp.text
                npcLine = (resp.npc_line?.isEmpty == true) ? nil : resp.npc_line
                choices = resp.choices
                appendToContext(resp.text + (resp.npc_line.map { "\n\($0)" } ?? ""))
                input = ""
            } catch {
                self.error = (error as NSError).userInfo["body"] as? String ?? error.localizedDescription
            }
            isLoading = false
        }
    }

    func choose(_ choice: DevTurnChoice) {
        let mapped: String = {
            switch choice.type {
            case .think: return "(THINK) \(choice.label)"
            case .act: return "(ACT) \(choice.label)"
            case .say: return "(SAY) \(choice.label)"
            case .intervene: return "(INTERVENE) \(choice.label)"
            }
        }()
        input = mapped
        submitTurn()
    }
}
#endif
