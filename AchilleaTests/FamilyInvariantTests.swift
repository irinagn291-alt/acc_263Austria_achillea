import XCTest
@testable import Achillea

/// Family random_picker: Weighted roulette, weight ≥ 0.01, seeded RNG. Argument mode = forced 50/50.
final class FamilyInvariantTests: XCTestCase {
    func test_weightFloor_rejectsBelowAndKeepsMinimum() throws {
        XCTAssertEqual(StalkChance.floor, 0.01, accuracy: 1e-12)
        XCTAssertFalse(Name(text: "Rowan", stalk: Stalk(mass: 0.009)).isPledged)
        XCTAssertTrue(Name(text: "Rowan", stalk: Stalk(mass: 0.01)).isPledged)

        var ask = Ask.empty
        XCTAssertThrowsError(
            try ask.pledging(Name(text: "Rowan", stalk: Stalk(mass: 0.009)))
        ) { error in
            XCTAssertEqual(error as? AskFault, .stalkBelowFloor)
        }
        ask = try ask.pledging(Name(text: "Rowan", stalk: Stalk(mass: 0.01)))
        XCTAssertEqual(try XCTUnwrap(ask.names.first?.stalk.mass), 0.01, accuracy: 1e-12)
    }

    func test_needsTwoNonBlankNames() {
        let one = [Name(text: "Rowan", stalk: Stalk(mass: 1))]
        XCTAssertThrowsError(try StalkChance.crateForDraw(one, dispute: false)) { error in
            XCTAssertEqual(error as? AskFault, .tooFewNames)
        }

        let blank = [
            Name(text: "Rowan", stalk: Stalk(mass: 1)),
            Name(text: "   ", stalk: Stalk(mass: 1)),
        ]
        XCTAssertThrowsError(try StalkChance.crateForDraw(blank, dispute: false)) { error in
            XCTAssertEqual(error as? AskFault, .tooFewNames)
        }

        let two = [
            Name(text: "Rowan", stalk: Stalk(mass: 1)),
            Name(text: "Sable", stalk: Stalk(mass: 1)),
        ]
        XCTAssertEqual(try StalkChance.crateForDraw(two, dispute: false).count, 2)
    }

    func test_weightedRoulette_unitIntervalFollowsStalkMass() {
        let light = Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 1))
        let heavy = Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 3))
        let crate = [light, heavy]
        XCTAssertEqual(StalkChance.pick(crate, unit: 0)?.id, light.id)
        XCTAssertEqual(StalkChance.pick(crate, unit: 0.24)?.id, light.id)
        XCTAssertEqual(StalkChance.pick(crate, unit: 0.25)?.id, heavy.id)
        XCTAssertEqual(StalkChance.pick(crate, unit: 0.99)?.id, heavy.id)
    }

    func test_seededRNG_sameSeedSamePick() throws {
        let ask = try Ask.empty
            .pledging(Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 4)))
            .pledging(Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1)))
            .pledging(Name(id: AskSeed.tansy, text: "Tansy", stalk: Stalk(mass: 2)))
            .gageAsk(at: date(2026, 9, 19), calendar: posixCalendar())
        let first = try ask.drawSlip(seed: 42, at: date(2026, 9, 19), calendar: posixCalendar())
        let second = try ask.drawSlip(seed: 42, at: date(2026, 9, 19), calendar: posixCalendar())
        XCTAssertEqual(first.slips.last?.nameID, second.slips.last?.nameID)
        XCTAssertEqual(first.fold, .filed)
        XCTAssertEqual(second.fold, .filed)
    }

    func test_argumentMode_forcesEqualMassAndSkipsGage() throws {
        let rowan = Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 10))
        let sable = Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1))
        let clamped = try StalkChance.crateForDraw([rowan, sable], dispute: true)
        XCTAssertEqual(clamped.count, 2)
        XCTAssertEqual(clamped[0].stalk.mass, 1, accuracy: 1e-12)
        XCTAssertEqual(clamped[1].stalk.mass, 1, accuracy: 1e-12)

        let calendar = posixCalendar()
        let day = date(2026, 9, 19, calendar: calendar)
        let filed = try Ask.empty
            .pledging(rowan)
            .pledging(sable)
            .settingDispute(true)
            .drawSlip(seed: 7, at: day, calendar: calendar)
        XCTAssertTrue(filed.dispute)
        XCTAssertTrue(filed.hidesStalkRails)
        XCTAssertEqual(filed.fold, .filed)
        XCTAssertNil(filed.gageMark)
        XCTAssertEqual(filed.slips.count, 1)
        XCTAssertEqual(filed.records.first?.dayKey, 20260919)

        XCTAssertThrowsError(
            try StalkChance.crateForDraw(
                [rowan, sable, Name(text: "Tansy", stalk: Stalk(mass: 1))],
                dispute: true
            )
        ) { error in
            XCTAssertEqual(error as? AskFault, .disputeNeedsTwo)
        }
    }

    private func posixCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, calendar: Calendar? = nil) -> Date {
        let calendar = calendar ?? posixCalendar()
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        return calendar.date(from: parts) ?? Date(timeIntervalSince1970: 0)
    }
}
