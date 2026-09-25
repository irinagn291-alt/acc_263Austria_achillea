import Foundation

/// Role: Slip. The filed pick written by Draw. Retract peels the newest one.
struct Slip: Identifiable, Hashable, Sendable, Equatable {
    var id: UUID
    var nameID: UUID
    var nameText: String
    var mass: Double
    var dayKey: Int
    var filedAt: Date

    init(
        id: UUID = UUID(),
        nameID: UUID,
        nameText: String,
        mass: Double,
        dayKey: Int,
        filedAt: Date
    ) {
        self.id = id
        self.nameID = nameID
        self.nameText = nameText
        self.mass = mass
        self.dayKey = dayKey
        self.filedAt = filedAt
    }
}
