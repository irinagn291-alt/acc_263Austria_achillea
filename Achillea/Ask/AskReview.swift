import Foundation

/// Role: Ask. Launch keys for live shots. today/log/goals are arguments, not tabs.
enum AskReview: Equatable, Sendable {
    case today
    case log
    case goals

    init?(slug: String) {
        switch slug {
        case "today":
            self = .today
        case "log":
            self = .log
        case "goals":
            self = .goals
        default:
            return nil
        }
    }

    /// Extra cover keys from this app's screens. today/log/goals stay in `init?(slug:)`.
    static func isHomeSlug(_ slug: String) -> Bool {
        switch slug.lowercased() {
        case "today", "ask", "home", "root":
            return true
        default:
            return false
        }
    }

    static func sheet(forSlug slug: String) -> AskSheet? {
        switch slug.lowercased() {
        case "log", "history", "slips", "sliphistory":
            return .history
        case "goals", "settings", "settingsview":
            return .settings
        case "twist", "gage", "gageguide":
            return .twist
        default:
            return nil
        }
    }

    /// Reads `-ReviewScreen` once, only after onboarding. Do not host a View here.
    static func consume(
        arguments: [String],
        onboardingComplete: Bool,
        consumed: inout Bool
    ) -> AskReview? {
        guard onboardingComplete, !consumed else { return nil }
        consumed = true
        guard let index = arguments.firstIndex(of: "-ReviewScreen") else { return nil }
        let next = arguments.index(after: index)
        guard arguments.indices.contains(next) else { return nil }
        return AskReview(slug: arguments[next])
    }
}
