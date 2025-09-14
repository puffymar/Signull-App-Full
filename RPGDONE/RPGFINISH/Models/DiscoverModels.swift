import Foundation

public struct IdeaCard: Codable, Identifiable, Equatable {
    public var id: String { title }
    public let title: String
    public let hook: String
    public let tags: [String]?
}

public enum ChoiceType: String, Codable { case think, act, say, intervene }

public struct TurnChoice: Codable, Identifiable, Equatable {
    public var id: String { "\(type.rawValue)-\(label)" }
    public let type: ChoiceType
    public let label: String
    public let hint: String
}

public struct OpeningResponse: Codable, Equatable {
    public let title: String
    public let text: String
    public let choices: [TurnChoice]
}

public struct ContinueResponse: Codable, Equatable {
    public let text: String
    public let choices: [TurnChoice]
}


