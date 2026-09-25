import UIKit
import XCTest
@testable import Achillea

final class AskDeskTests: XCTestCase {
    private var directory: URL!
    private var suiteName: String!
    private var calendar: Calendar!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        suiteName = "ach.desk.\(UUID().uuidString)"
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        utc.locale = Locale(identifier: "en_US_POSIX")
        calendar = utc
    }

    override func tearDownWithError() throws {
        if let directory {
            try? FileManager.default.removeItem(at: directory)
        }
        if let suiteName {
            UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        }
        directory = nil
        suiteName = nil
    }

    @MainActor
    func test_reviewKeysOpenDifferentSheets() async throws {
        let today = await booted(arguments: ["-ReviewScreen", "today"])
        XCTAssertNil(today.sheet)
        XCTAssertFalse(today.showsOnboarding)

        let log = await booted(arguments: ["-ReviewScreen", "log"])
        XCTAssertEqual(log.sheet, .history)

        let goals = await booted(arguments: ["-ReviewScreen", "goals"])
        XCTAssertEqual(goals.sheet, .settings)

        let twist = await booted(arguments: ["-ReviewScreen", "twist"])
        XCTAssertEqual(twist.sheet, .twist)

        let history = await booted(arguments: ["-ReviewScreen", "history"])
        XCTAssertEqual(history.sheet, .history)

        let settings = await booted(arguments: ["-ReviewScreen", "settings"])
        XCTAssertEqual(settings.sheet, .settings)

        let gage = await booted(arguments: ["-ReviewScreen", "gageguide"])
        XCTAssertEqual(gage.sheet, .twist)
    }

    @MainActor
    func test_reviewIsConsumedOnce() async throws {
        let desk = await booted(arguments: ["-ReviewScreen", "log"])
        XCTAssertEqual(desk.sheet, .history)
        desk.sheet = nil
        desk.applyReviewIfNeeded(["-ReviewScreen", "goals"])
        XCTAssertNil(desk.sheet)
    }

    @MainActor
    func test_onboardingIncompleteSkipsReview() async {
        let desk = makeDesk()
        await desk.boot(arguments: ["-ReviewScreen", "log"])
        XCTAssertTrue(desk.showsOnboarding)
        XCTAssertNil(desk.sheet)
    }

    @MainActor
    func test_gageThenDrawThroughDesk() async throws {
        let store = makeStore()
        _ = try await store.pledge(Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 2)))
        _ = try await store.pledge(Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1)))
        _ = try await store.setOnboardingComplete(true)
        try await store.flush()
        let stamp = day(2026, 9, 19)

        let desk = AskDesk(
            store: store,
            calendar: calendar,
            now: { stamp },
            plantsDemo: false
        )
        desk.drawSeed = 8
        await desk.boot(arguments: ["-ReviewScreen", "today"])
        XCTAssertTrue(desk.gageEnabled)
        XCTAssertFalse(desk.drawEnabled)

        await desk.gageAsk()
        XCTAssertEqual(desk.ask.fold, .gaged)
        XCTAssertTrue(desk.drawEnabled)
        XCTAssertFalse(desk.gageEnabled)

        await desk.drawSlip()
        XCTAssertEqual(desk.ask.fold, .filed)
        XCTAssertEqual(desk.ask.slips.count, 1)
        XCTAssertEqual(desk.commitPulse, 1)
        XCTAssertNil(desk.fault)
    }

    @MainActor
    func test_drawOnIdleIsRefusedUntilDispute() async throws {
        let store = makeStore()
        _ = try await store.pledge(Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 1)))
        _ = try await store.pledge(Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1)))
        _ = try await store.setOnboardingComplete(true)
        try await store.flush()
        let stamp = day(2026, 9, 19)
        let desk = AskDesk(
            store: store,
            calendar: calendar,
            now: { stamp },
            plantsDemo: false
        )
        desk.drawSeed = 2
        await desk.boot(arguments: [])
        await desk.drawSlip()
        XCTAssertEqual(desk.fault, AskCopy.fault(AskFault.idleDrawRefused))
        XCTAssertEqual(desk.ask.fold, .idle)

        await desk.setDispute(true)
        await desk.drawSlip()
        XCTAssertEqual(desk.ask.fold, .filed)
        XCTAssertEqual(desk.ask.slips.count, 1)
        XCTAssertNil(desk.ask.gageMark)
    }

    @MainActor
    func test_retractPeelsNewestSlip() async throws {
        let store = makeStore()
        _ = try await store.pledge(Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 1)))
        _ = try await store.pledge(Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1)))
        _ = try await store.setDispute(true)
        _ = try await store.setOnboardingComplete(true)
        _ = try await store.drawSlip(seed: 2, at: day(2026, 9, 19), calendar: calendar)
        try await store.flush()
        let stamp = day(2026, 9, 19)
        let desk = AskDesk(
            store: store,
            calendar: calendar,
            now: { stamp },
            plantsDemo: false
        )
        await desk.boot(arguments: [])
        XCTAssertEqual(desk.ask.slips.count, 1)
        await desk.peelSlip()
        XCTAssertTrue(desk.ask.slips.isEmpty)
        XCTAssertEqual(desk.ask.fold, .idle)
    }

    @MainActor
    func test_resetShowsOnboarding() async throws {
        let desk = await booted(arguments: [])
        await desk.resetAllData()
        XCTAssertTrue(desk.showsOnboarding)
        XCTAssertTrue(desk.isEmptyAsk)
        XCTAssertTrue(desk.settingsIsEmpty)
    }

    @MainActor
    func test_nameCellNibRegisters() {
        let nib = UINib(nibName: NameCell.nibName, bundle: Bundle(for: NameCell.self))
        let objects = nib.instantiate(withOwner: nil, options: nil)
        XCTAssertTrue(objects.contains { $0 is NameCell })
    }

    @MainActor
    func test_copyHasNoEmDash() {
        XCTAssertFalse(AskCopy.jobLine.contains("\u{2014}"))
        XCTAssertFalse(AskCopy.jobLine.contains("\u{2013}"))
        XCTAssertFalse(AskCopy.twistBody.contains("\u{2014}"))
        XCTAssertEqual(AskCopy.foldWord(.idle), "Ready")
        XCTAssertEqual(AskCopy.foldWord(.gaged), "Locked")
        XCTAssertEqual(AskCopy.foldWord(.filed), "Saved")
    }

    @MainActor
    private func booted(arguments: [String]) async -> AskDesk {
        let store = makeStore()
        _ = try? await store.setOnboardingComplete(true)
        try? await store.flush()
        let stamp = day(2026, 9, 19)
        let desk = AskDesk(
            store: store,
            calendar: calendar,
            now: { stamp },
            plantsDemo: false
        )
        await desk.boot(arguments: arguments)
        return desk
    }

    @MainActor
    private func makeDesk() -> AskDesk {
        let stamp = day(2026, 9, 19)
        return AskDesk(
            store: makeStore(),
            calendar: calendar,
            now: { stamp },
            plantsDemo: false
        )
    }

    private func makeStore() -> AskStore {
        AskStore(
            directory: directory,
            suiteName: suiteName,
            writeDelayNanoseconds: 0
        )
    }

    private func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        return calendar.date(from: parts) ?? Date(timeIntervalSince1970: 0)
    }
}
