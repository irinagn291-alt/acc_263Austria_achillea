import Foundation

/// Role: DecisionRecord. History row for a filed Slip. Draw writes this; Gage never does.
struct DecisionRecord: Identifiable, Hashable, Sendable, Equatable {
    var id: UUID
    var slipID: UUID
    var nameID: UUID
    var nameText: String
    var dayKey: Int
    var filedAt: Date

    init(
        id: UUID = UUID(),
        slipID: UUID,
        nameID: UUID,
        nameText: String,
        dayKey: Int,
        filedAt: Date
    ) {
        self.id = id
        self.slipID = slipID
        self.nameID = nameID
        self.nameText = nameText
        self.dayKey = dayKey
        self.filedAt = filedAt
    }
}
