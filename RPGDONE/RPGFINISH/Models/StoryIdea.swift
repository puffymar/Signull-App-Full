import Foundation
import SwiftUI

struct StoryIdea: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var hook: String
    var tags: [String]
    var thumbSeed: Int
    var accent: Color
}

struct IdeaDTO: Decodable {
    let title: String?
    let hook: String?
    let openingHook: String?
    let opening_hook: String?
    let tags: [String]?

    var resolvedTitle: String {
        let trimmed = title?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed?.isEmpty == false ? trimmed : nil) ?? fallbackTitle
    }

    var resolvedHook: String {
        let raw = [hook, openingHook, opening_hook]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first
        return sanitizeHook(raw)
    }

    private var fallbackTitle: String {
        let base = [hook, openingHook, opening_hook].compactMap { $0 }.first ?? "Signal Story"
        return sanitizeTitle(base)
    }

    private func sanitizeHook(_ raw: String?) -> String {
        guard var s = raw, !s.isEmpty else { return "You arrive; the scene breathes around you." }
        s = s.replacingOccurrences(of: "_", with: " ")
        s = s.replacingOccurrences(of: "-", with: " ")
        s = s.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        // Ensure it starts as second-person imperative/present
        if s.lowercased().hasPrefix("a ") || s.lowercased().hasPrefix("the ") {
            s = "You " + s
        }
        return s
    }

    private func sanitizeTitle(_ raw: String) -> String {
        var s = raw.replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
        s = s.replacingOccurrences(of: "[0-9]+", with: "", options: .regularExpression)
        s = s.replacingOccurrences(of: "[^A-Za-z\s]", with: "", options: .regularExpression)
        s = s.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
        let words = s.split(separator: " ").map { String($0).capitalized }
        let clamped = words.prefix(5)
        let title = clamped.joined(separator: " ")
        return title.isEmpty ? "Signal Story" : title
    }
}

