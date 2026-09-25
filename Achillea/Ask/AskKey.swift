import Foundation

/// Role: Ask. Preference keys. Snapshot key is the assigned UserDefaults contract.
enum AskKey {
    static let snapshot = "ach.ask.v1"
    static let backup = "ach.ask.v1.backup"
    static let demo = "ach.demo.v1"
}

/// Role: Ask. Recoverable load outcome. Never crash on a corrupt snapshot.
enum AskWarning: Equatable, Sendable {
    case recoveredFromBackup
    case startedEmpty
}
