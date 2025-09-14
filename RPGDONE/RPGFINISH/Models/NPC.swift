import Foundation
import SwiftUI

struct NPC: Codable, Equatable {
    var id: String
    var name: String
    var affinity: Int       // -100..100
    var tags: [String]      // e.g., ["mentor","occult","unreliable"]

    mutating func nudge(_ delta: Int) { affinity = max(-100, min(100, affinity + delta)) }
}

final class WorldStore: ObservableObject {
    static let shared = WorldStore()
    @Published var state = WorldState()
    @Published var npcs: [NPC] = [
        NPC(id: "guide", name: "The Veilbearer", affinity: 10, tags: ["mentor","cryptic"]),
        NPC(id: "scav",  name: "Rook", affinity: -5, tags: ["wasteland","trader"]),
        NPC(id: "chor",  name: "Chorister", affinity: 0, tags: ["oceanic","choir"])
    ]
} 