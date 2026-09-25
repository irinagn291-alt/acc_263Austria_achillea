import XCTest
@testable import Achillea

final class AskStoreTests: XCTestCase {
    private var directory: URL!
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var calendar: Calendar!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        suiteName = "ach.test.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
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
            defaults?.removePersistentDomain(forName: suiteName)
        }
        directory = nil
        defaults = nil
        suiteName = nil
    }

    func test_roundTrip_reloadPreservesFoldAndSlips() async throws {
        let store = makeStore()
        _ = try await store.pledge(Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 2)))
        _ = try await store.pledge(Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1)))
        _ = try await store.gageAsk(at: day(2026, 9, 19), calendar: calendar)
        _ = try await store.drawSlip(seed: 8, at: day(2026, 9, 19), calendar: calendar)

        let relaunched = makeStore()
        let loaded = await relaunched.load()
        XCTAssertNil(loaded.warning)
        XCTAssertEqual(loaded.ask.fold, .filed)
        XCTAssertEqual(loaded.ask.names.map(\.id), [AskSeed.rowan, AskSeed.sable])
        XCTAssertEqual(loaded.ask.slips.count, 1)
        XCTAssertEqual(loaded.ask.records.first?.dayKey, 20260919)
        XCTAssertNotNil(loaded.ask.gageMark)
        XCTAssertNotNil(defaults.data(forKey: AskKey.snapshot))
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: directory.appendingPathComponent("ask.json").path)
        )
    }

    func test_gageAndDrawFlushImmediately() async throws {
        let store = makeStore()
        _ = try await store.pledge(Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 1)))
        _ = try await store.pledge(Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1)))
        try await store.flush()
        let afterPledge = defaults.data(forKey: AskKey.snapshot)

        _ = try await store.gageAsk(at: day(2026, 9, 19), calendar: calendar)
        XCTAssertNotEqual(defaults.data(forKey: AskKey.snapshot), afterPledge)
        let coldAfterGage = await makeStore().load()
        XCTAssertEqual(coldAfterGage.ask.fold, .gaged)

        _ = try await store.drawSlip(seed: 3, at: day(2026, 9, 19), calendar: calendar)
        let coldAfterDraw = await makeStore().load()
        XCTAssertEqual(coldAfterDraw.ask.fold, .filed)
        XCTAssertEqual(coldAfterDraw.ask.slips.count, 1)
    }

    func test_disputeDrawWritesFromIdle() async throws {
        let store = makeStore()
        _ = try await store.pledge(Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 8)))
        _ = try await store.pledge(Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1)))
        _ = try await store.setDispute(true)
        _ = try await store.drawSlip(seed: 2, at: day(2026, 9, 19), calendar: calendar)
        let cold = await makeStore().load()
        XCTAssertEqual(cold.ask.fold, .filed)
        XCTAssertEqual(cold.ask.slips.count, 1)
        XCTAssertTrue(cold.ask.dispute)
        XCTAssertNil(cold.ask.gageMark)
    }

    func test_corruptSnapshotFallsBackToBackup() async throws {
        let store = makeStore()
        _ = try await store.pledge(Name(id: AskSeed.sable, text: "Sable", stalk: Stalk(mass: 1)))
        _ = try await store.pledge(Name(id: AskSeed.tansy, text: "Tansy", stalk: Stalk(mass: 1)))
        try await store.flush()
        if let good = defaults.data(forKey: AskKey.snapshot) {
            defaults.set(good, forKey: AskKey.backup)
        }
        let file = directory.appendingPathComponent("ask.json")
        let backup = directory.appendingPathComponent("ask.json.backup")
        if FileManager.default.fileExists(atPath: file.path) {
            try? FileManager.default.removeItem(at: backup)
            try FileManager.default.copyItem(at: file, to: backup)
        }
        defaults.set(Data("{not-json".utf8), forKey: AskKey.snapshot)
        try Data("{not-json".utf8).write(to: file)

        let loaded = await makeStore().load()
        XCTAssertEqual(loaded.warning, .recoveredFromBackup)
        XCTAssertEqual(loaded.ask.names.map(\.id), [AskSeed.sable, AskSeed.tansy])
    }

    func test_corruptSnapshotWithoutBackupStartsEmpty() async throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defaults.set(Data("nope".utf8), forKey: AskKey.snapshot)
        try Data("nope".utf8).write(to: directory.appendingPathComponent("ask.json"))
        let loaded = await makeStore().load()
        XCTAssertEqual(loaded.warning, .startedEmpty)
        XCTAssertTrue(loaded.ask.names.isEmpty)
        XCTAssertEqual(loaded.ask.fold, .idle)
    }

    func test_codecSwitchesOnSchemaVersion() throws {
        let document = AskDocument.envelope(
            from: AskSeed.ask(now: day(2026, 9, 19), calendar: calendar)
        )
        let data = try AskCodec.encode(document)
        let decoded = try AskCodec.decode(data)
        XCTAssertEqual(decoded.schemaVersion, 1)
        XCTAssertEqual(decoded.names.count, 2)
        XCTAssertEqual(decoded.slips.count, 5)
        XCTAssertEqual(decoded.fold, .idle)
        XCTAssertTrue(decoded.dispute)

        let future = Data("{\"schemaVersion\":99}".utf8)
        XCTAssertThrowsError(try AskCodec.decode(future)) { error in
            XCTAssertEqual(error as? AskCodec.Failure, .unsupportedSchema(99))
        }
        XCTAssertThrowsError(try AskCodec.decode(Data("[]".utf8))) { error in
            XCTAssertEqual(error as? AskCodec.Failure, .corrupt)
        }
    }

    func test_resetAllDataClearsSnapshotAndFiles() async throws {
        let store = makeStore()
        _ = try await store.pledge(Name(id: AskSeed.rowan, text: "Rowan", stalk: Stalk(mass: 1)))
        try await store.flush()
        try await store.resetAllData()
        let loaded = await store.load()
        XCTAssertTrue(loaded.ask.names.isEmpty)
        XCTAssertNil(defaults.data(forKey: AskKey.snapshot))
        XCTAssertNil(defaults.data(forKey: AskKey.backup))
        let leftovers = (try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )) ?? []
        XCTAssertTrue(leftovers.filter { $0.pathExtension == "json" }.isEmpty)
    }

    #if targetEnvironment(simulator)
    func test_simulatorSeedWritesOnce() async throws {
        let store = makeStore()
        let first = try await store.seedDemoIfNeeded(now: day(2026, 9, 19), calendar: calendar)
        let second = try await store.seedDemoIfNeeded(now: day(2026, 9, 19), calendar: calendar)
        XCTAssertNil(second)
        XCTAssertEqual(first?.names.count, 2)
        XCTAssertEqual(first?.fold, .idle)
        XCTAssertTrue(first?.canDraw ?? false)
        XCTAssertEqual(first?.onboardingComplete, true)
        XCTAssertEqual(first?.slips.count, 5)
        XCTAssertTrue(defaults.bool(forKey: AskKey.demo))
        XCTAssertNotNil(defaults.data(forKey: AskKey.snapshot))
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: directory.appendingPathComponent("ask.json").path)
        )
    }
    #endif

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
