import Foundation

/// Role: GageMark. Freeze stamp written by Gage. Idle folds to Gaged. A later Gage is refused.
struct GageMark: Identifiable, Hashable, Sendable, Equatable {
    var id: UUID
    var dayKey: Int
    var stampedAt: Date
    var nameIDs: [UUID]

    init(
        id: UUID = UUID(),
        dayKey: Int,
        stampedAt: Date,
        nameIDs: [UUID]
    ) {
        self.id = id
        self.dayKey = dayKey
        self.stampedAt = stampedAt
        self.nameIDs = nameIDs
    }
}
