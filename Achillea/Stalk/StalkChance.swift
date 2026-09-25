import Foundation

/// Role: Stalk. Massed chance over pledged Names. The ask fold calls this; views never roll.
enum StalkChance {
    static let floor: Double = 0.01

    static func pledged(_ names: [Name]) -> [Name] {
        names.filter(\.isPledged)
    }

    static func crateForDraw(_ names: [Name], dispute: Bool) throws -> [Name] {
        let pool = pledged(names)
        if dispute {
            guard pool.count == 2 else { throw AskFault.disputeNeedsTwo }
            return pool.map { name in
                var next = name
                next.stalk = Stalk(mass: 1)
                return next
            }
        }
        guard pool.count >= 2 else { throw AskFault.tooFewNames }
        return pool
    }

    static func pick(_ names: [Name], unit: Double) -> Name? {
        guard !names.isEmpty else { return nil }
        let total = names.reduce(0.0) { $0 + $1.stalk.mass }
        guard total > 0, total.isFinite else { return names.last }
        let clamped: Double
        if unit.isFinite {
            clamped = min(max(unit, 0), Double(1).nextDown)
        } else {
            clamped = 0
        }
        let mark = clamped * total
        var walked = 0.0
        for name in names {
            walked += name.stalk.mass
            if mark < walked {
                return name
            }
        }
        return names.last
    }

    static func pick(_ names: [Name], using rng: inout some RandomNumberGenerator) -> Name? {
        pick(names, unit: Double.random(in: 0 ..< 1, using: &rng))
    }

    static func draw(
        names: [Name],
        dispute: Bool,
        using rng: inout some RandomNumberGenerator
    ) throws -> Name {
        let crate = try crateForDraw(names, dispute: dispute)
        guard let name = pick(crate, using: &rng) else {
            throw AskFault.tooFewNames
        }
        return name
    }
}

/// Role: Stalk. Seeded generator so the same massed sequence can be replayed in tests.
struct StalkMixer: RandomNumberGenerator, Sendable {
    private var state: UInt64

    init(_ seed: UInt64) {
        state = seed &+ 0x9E3779B97F4A7C15
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var mix = state
        mix = (mix ^ (mix &>> 30)) &* 0xBF58476D1CE4E5B9
        mix = (mix ^ (mix &>> 27)) &* 0x94D049BB133111EB
        return mix ^ (mix &>> 31)
    }
}
