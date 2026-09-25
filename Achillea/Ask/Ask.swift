import Foundation

/// Role: Ask. Closed fold over Names: Idle, Gaged, Filed. A fourth case is a defect.
enum AskFold: String, Codable, Equatable, Sendable, CaseIterable {
    case idle
    case gaged
    case filed
}

/// Role: Ask. Faults the fold can raise. Views never invent a second error vocabulary.
enum AskFault: Error, Equatable, Sendable {
    case bare
    case tooFewNames
    case blankName
    case stalkBelowFloor
    case namesFrozen
    case alreadyGaged
    case idleDrawRefused
    case alreadyFiled
    case disputeNeedsTwo
    case disputeSkipsGage
    case disputeLocksMass
    case unknownName
    case nothingToPeel
}

/// Role: Ask. The crate. Gage writes a GageMark and freezes Names. Draw writes a Slip. Views call the fold, never a parallel bool.
struct Ask: Equatable, Sendable {
    var names: [Name]
    var fold: AskFold
    var gageMark: GageMark?
    var slips: [Slip]
    var records: [DecisionRecord]
    var dispute: Bool
    var onboardingComplete: Bool

    static let empty = Ask(
        names: [],
        fold: .idle,
        gageMark: nil,
        slips: [],
        records: [],
        dispute: false,
        onboardingComplete: false
    )

    var pledgedNames: [Name] {
        StalkChance.pledged(names)
    }

    var railNameCount: Int {
        pledgedNames.count
    }

    var railStalkSum: Double {
        pledgedNames.reduce(0) { $0 + $1.stalk.mass }
    }

    var hidesStalkRails: Bool {
        dispute
    }

    var canGage: Bool {
        fold == .idle && !dispute && pledgedNames.count >= 2
    }

    var canDraw: Bool {
        switch fold {
        case .gaged:
            return pledgedNames.count >= 2
        case .idle:
            return dispute && pledgedNames.count == 2
        case .filed:
            return false
        }
    }

    func pledging(_ name: Name) throws -> Ask {
        try requireIdle()
        var prepared = name
        prepared.text = prepared.trimmedText
        guard !prepared.text.isEmpty else { throw AskFault.blankName }
        guard prepared.stalk.isReady else { throw AskFault.stalkBelowFloor }
        var next = self
        if let index = next.names.firstIndex(where: { $0.id == prepared.id }) {
            if dispute {
                prepared.stalk = Stalk(mass: 1)
            }
            next.names[index] = prepared
            return next
        }
        if dispute, next.pledgedNames.count >= 2 {
            throw AskFault.disputeNeedsTwo
        }
        if dispute {
            prepared.stalk = Stalk(mass: 1)
        }
        next.names.append(prepared)
        return next
    }

    func removing(nameID: UUID) throws -> Ask {
        try requireIdle()
        guard names.contains(where: { $0.id == nameID }) else { throw AskFault.unknownName }
        var next = self
        next.names.removeAll { $0.id == nameID }
        if next.pledgedNames.count != 2 {
            next.dispute = false
        }
        return next
    }

    func settingStalk(nameID: UUID, mass: Double) throws -> Ask {
        try requireIdle()
        if dispute { throw AskFault.disputeLocksMass }
        guard let name = names.first(where: { $0.id == nameID }) else { throw AskFault.unknownName }
        var next = name
        next.stalk = Stalk(mass: mass)
        return try pledging(next)
    }

    func settingDispute(_ on: Bool) throws -> Ask {
        try requireIdle()
        var next = self
        if on {
            let pool = next.pledgedNames
            guard pool.count == 2 else { throw AskFault.disputeNeedsTwo }
            next.names = next.names.map { name in
                var item = name
                if item.isPledged {
                    item.stalk = Stalk(mass: 1)
                }
                return item
            }
        }
        next.dispute = on
        return next
    }

    func settingOnboardingComplete(_ done: Bool) -> Ask {
        var next = self
        next.onboardingComplete = done
        return next
    }

    func gageAsk(
        at date: Date = Date(),
        calendar: Calendar = .current,
        markID: UUID = UUID()
    ) throws -> Ask {
        if dispute { throw AskFault.disputeSkipsGage }
        if fold == .gaged { throw AskFault.alreadyGaged }
        if fold == .filed { throw AskFault.alreadyFiled }
        let pool = pledgedNames
        guard pool.count >= 2 else { throw AskFault.bare }
        var next = self
        next.fold = .gaged
        next.gageMark = GageMark(
            id: markID,
            dayKey: AskDay.key(for: date, calendar: calendar),
            stampedAt: date,
            nameIDs: pool.map(\.id)
        )
        return next
    }

    func drawSlip(
        using rng: inout some RandomNumberGenerator,
        at date: Date = Date(),
        calendar: Calendar = .current,
        slipID: UUID = UUID(),
        recordID: UUID = UUID()
    ) throws -> Ask {
        if fold == .filed { throw AskFault.alreadyFiled }
        if fold == .idle && !dispute { throw AskFault.idleDrawRefused }
        let drawn = try StalkChance.draw(names: names, dispute: dispute, using: &rng)
        let dayKey = AskDay.key(for: date, calendar: calendar)
        let slip = Slip(
            id: slipID,
            nameID: drawn.id,
            nameText: drawn.text,
            mass: dispute ? 1 : drawn.stalk.mass,
            dayKey: dayKey,
            filedAt: date
        )
        let record = DecisionRecord(
            id: recordID,
            slipID: slip.id,
            nameID: drawn.id,
            nameText: drawn.text,
            dayKey: dayKey,
            filedAt: date
        )
        var next = self
        next.slips.append(slip)
        next.records.append(record)
        next.fold = .filed
        return next
    }

    func drawSlip(
        seed: UInt64,
        at date: Date = Date(),
        calendar: Calendar = .current,
        slipID: UUID = UUID(),
        recordID: UUID = UUID()
    ) throws -> Ask {
        var mixer = StalkMixer(seed)
        return try drawSlip(
            using: &mixer,
            at: date,
            calendar: calendar,
            slipID: slipID,
            recordID: recordID
        )
    }

    func peelSlip() throws -> Ask {
        guard let slip = slips.last else { throw AskFault.nothingToPeel }
        var next = self
        next.slips.removeAll { $0.id == slip.id }
        next.records.removeAll { $0.slipID == slip.id }
        if next.fold == .filed {
            next.fold = .idle
            next.gageMark = nil
        }
        return next
    }

    func beginFreshAsk() -> Ask {
        var next = self
        next.fold = .idle
        next.gageMark = nil
        return next
    }

    private func requireIdle() throws {
        if fold == .gaged { throw AskFault.namesFrozen }
        if fold == .filed { throw AskFault.alreadyFiled }
    }
}
