import Foundation

/// Role: Name. One pledged line in the ask crate. Stalk mass is weight, never a stored chance.
struct Name: Identifiable, Hashable, Sendable, Equatable {
    var id: UUID
    var text: String
    var stalk: Stalk

    init(id: UUID = UUID(), text: String, stalk: Stalk = Stalk()) {
        self.id = id
        self.text = text
        self.stalk = stalk
    }

    var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isPledged: Bool {
        !trimmedText.isEmpty && stalk.isReady
    }
}
