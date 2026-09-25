import Foundation

/// Role: Stalk. Mass on a pledged Name. Floor is 0.01. Views never invent a second weight.
struct Stalk: Hashable, Sendable, Equatable {
    var mass: Double

    init(mass: Double = 1) {
        self.mass = mass
    }

    var isReady: Bool {
        mass.isFinite && mass >= StalkChance.floor
    }
}
