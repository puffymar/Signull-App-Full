// DEBUG scaffold models for local testing. Not used in release.
#if DEBUG
import Foundation

public enum DevChoiceType: String, Codable { case think, act, say, intervene }

public struct DevTurnChoice: Codable, Identifiable {
    public var id: String { "\(type.rawValue)-\(label)" }
    public let type: DevChoiceType
    public let label: String
    public let hint: String
}

public struct DevTurnResponse: Codable {
    public let text: String
    public let npc_line: String?
    public let choices: [DevTurnChoice]
}
#endif
