import XCTest
@testable import Achillea

final class AskFoldTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        utc.locale = Locale(identifier: "en_US_POSIX")
        calendar = utc
    }

    func test_foldHasOnlyIdleGagedFiled() {
        XCTAssertEqual(AskFold.allCases, [.idle, .gaged, .filed])
        XCTAssertEqual(Ask.empty.fold, .idle)
    }

    func test_gageThenDraw_emptyPopulatedInvalid() throws {
        var ask = Ask.empty
        XCTAssertTrue(ask.names.isEmpty)
        XCTAssertThrowsError(try ask.gageAsk(at: day(2026, 9, 19), calendar: calendar)) { error in
            XCTAssertEqual(error as? AskFault, .bare)
        }
        XCTAssertThrowsError(try ask.drawSlip(seed: 1)) { error in
            XCTAssertEqual(error as? AskFault, .idleDrawRefused)
        }

        ask = try ask
            .pledging(Name(id: AskSeed.rowan, text: "  Rowan  ", stalk: Stalk(mass: 2)))
            .pledging(Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1)))
        XCTAssertEqual(ask.names.first?.text, "Rowan")
        XCTAssertTrue(ask.canGage)
        XCTAssertFalse(ask.canDraw)

        XCTAssertThrowsError(try ask.pledging(Name(text: "   ", stalk: Stalk(mass: 1)))) { error in
            XCTAssertEqual(error as? AskFault, .blankName)
        }

        let gaged = try ask.gageAsk(at: day(2026, 9, 19), calendar: calendar)
        XCTAssertEqual(gaged.fold, .gaged)
        XCTAssertNotNil(gaged.gageMark)
        XCTAssertTrue(gaged.canDraw)
        XCTAssertThrowsError(try gaged.gageAsk(at: day(2026, 9, 19), calendar: calendar)) { error in
            XCTAssertEqual(error as? AskFault, .alreadyGaged)
        }
        XCTAssertThrowsError(try gaged.pledging(Name(text: "Tansy", stalk: Stalk(mass: 1)))) { error in
            XCTAssertEqual(error as? AskFault, .namesFrozen)
        }

        let filed = try gaged.drawSlip(seed: 3, at: day(2026, 9, 19), calendar: calendar)
        XCTAssertEqual(filed.fold, .filed)
        XCTAssertEqual(filed.slips.count, 1)
        XCTAssertEqual(filed.records.count, 1)
        XCTAssertEqual(filed.records.first?.dayKey, 20260919)
        XCTAssertEqual(filed.slips.first?.nameText, filed.records.first?.nameText)
        XCTAssertThrowsError(try filed.drawSlip(seed: 4)) { error in
            XCTAssertEqual(error as? AskFault, .alreadyFiled)
        }
    }

    func test_secondGageWhileGagedIsRefused() throws {
        let gaged = try Ask.empty
            .pledging(Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 1)))
            .pledging(Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1)))
            .gageAsk(at: day(2026, 9, 19), calendar: calendar)
        XCTAssertThrowsError(try gaged.gageAsk(at: day(2026, 9, 19), calendar: calendar)) { error in
            XCTAssertEqual(error as? AskFault, .alreadyGaged)
        }
        XCTAssertEqual(gaged.fold, .gaged)
    }

    func test_bareOnCrateUnderTwoNames() throws {
        let one = try Ask.empty.pledging(Name(text: "Rowan", stalk: Stalk(mass: 1)))
        XCTAssertThrowsError(try one.gageAsk(at: day(2026, 9, 19), calendar: calendar)) { error in
            XCTAssertEqual(error as? AskFault, .bare)
        }
        XCTAssertEqual(one.fold, .idle)
    }

    func test_disputeSkipsGageAndLetsIdleDrawFile() throws {
        let idle = try Ask.empty
            .pledging(Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 8)))
            .pledging(Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1)))
            .settingDispute(true)
        XCTAssertTrue(idle.canDraw)
        XCTAssertFalse(idle.canGage)
        XCTAssertThrowsError(try idle.gageAsk(at: day(2026, 9, 19), calendar: calendar)) { error in
            XCTAssertEqual(error as? AskFault, .disputeSkipsGage)
        }
        XCTAssertEqual(idle.names.map(\.stalk.mass), [1, 1])
        let filed = try idle.drawSlip(seed: 2, at: day(2026, 9, 19), calendar: calendar)
        XCTAssertEqual(filed.fold, .filed)
        XCTAssertEqual(filed.slips.count, 1)
        XCTAssertNil(filed.gageMark)
    }

    func test_retractPeelsNewestSlip() throws {
        let first = try Ask.empty
            .pledging(Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 1)))
            .pledging(Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1)))
            .settingDispute(true)
            .drawSlip(
                seed: 2,
                at: day(2026, 9, 18),
                calendar: calendar,
                slipID: AskSeed.slipRowan,
                recordID: AskSeed.recordRowan
            )
        let second = try first
            .beginFreshAsk()
            .drawSlip(
                seed: 9,
                at: day(2026, 9, 19),
                calendar: calendar,
                slipID: AskSeed.slipSable,
                recordID: AskSeed.recordSable
            )
        XCTAssertEqual(second.slips.map(\.id), [AskSeed.slipRowan, AskSeed.slipSable])
        let peeled = try second.peelSlip()
        XCTAssertEqual(peeled.slips.map(\.id), [AskSeed.slipRowan])
        XCTAssertEqual(peeled.records.map(\.id), [AskSeed.recordRowan])
        XCTAssertEqual(peeled.fold, .idle)
        XCTAssertNil(peeled.gageMark)
        XCTAssertThrowsError(try Ask.empty.peelSlip()) { error in
            XCTAssertEqual(error as? AskFault, .nothingToPeel)
        }
    }

    func test_seededAskEnablesDrawAndIsNeverBare() {
        let seeded = AskSeed.ask(now: day(2026, 9, 19), calendar: calendar)
        XCTAssertTrue(seeded.dispute)
        XCTAssertEqual(seeded.fold, .idle)
        XCTAssertTrue(seeded.canDraw)
        XCTAssertTrue(seeded.onboardingComplete)
        XCTAssertEqual(seeded.pledgedNames.count, 2)
        XCTAssertEqual(seeded.slips.count, 5)
        XCTAssertEqual(seeded.records.count, 5)
        XCTAssertNil(seeded.gageMark)
    }

    private func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        return calendar.date(from: parts) ?? Date(timeIntervalSince1970: 0)
    }
}
