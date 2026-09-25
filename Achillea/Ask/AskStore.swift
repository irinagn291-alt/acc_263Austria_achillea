import Foundation

/// Role: Ask. Memory is the source of truth. UserDefaults is the projection. Views never touch UserDefaults.
actor AskStore {
    private let vault: AskVault
    private let writeDelayNanoseconds: UInt64

    private var latest: Ask = .empty
    private var dirty = false
    private var writeTask: Task<Void, Never>?
    private(set) var warning: AskWarning?
    private(set) var lastWriteError: String?

    init(
        directory: URL,
        suiteName: String? = nil,
        writeDelayNanoseconds: UInt64 = 300_000_000
    ) {
        self.vault = AskVault(directory: directory, suiteName: suiteName)
        self.writeDelayNanoseconds = writeDelayNanoseconds
    }

    static func applicationSupportStore() -> AskStore {
        let directory: URL
        do {
            directory = try AskVault.supportDirectory()
        } catch {
            directory = FileManager.default.temporaryDirectory.appendingPathComponent(
                "Achillea",
                isDirectory: true
            )
        }
        return AskStore(directory: directory)
    }

    func load() async -> (ask: Ask, warning: AskWarning?) {
        let loaded = vault.load()
        latest = loaded.ask
        warning = loaded.warning
        dirty = false
        lastWriteError = nil
        return loaded
    }

    func ask() -> Ask {
        latest
    }

    func pledge(_ name: Name) async throws -> Ask {
        latest = try latest.pledging(name)
        schedulePersist()
        return latest
    }

    func remove(nameID: UUID) async throws -> Ask {
        latest = try latest.removing(nameID: nameID)
        schedulePersist()
        return latest
    }

    func setStalk(nameID: UUID, mass: Double) async throws -> Ask {
        latest = try latest.settingStalk(nameID: nameID, mass: mass)
        schedulePersist()
        return latest
    }

    func setDispute(_ on: Bool) async throws -> Ask {
        latest = try latest.settingDispute(on)
        schedulePersist()
        return latest
    }

    func setOnboardingComplete(_ done: Bool) async throws -> Ask {
        latest = latest.settingOnboardingComplete(done)
        schedulePersist()
        return latest
    }

    func gageAsk(at date: Date, calendar: Calendar) async throws -> Ask {
        latest = try latest.gageAsk(at: date, calendar: calendar)
        try persistNow()
        return latest
    }

    func drawSlip(seed: UInt64?, at date: Date, calendar: Calendar) async throws -> Ask {
        if let seed {
            latest = try latest.drawSlip(seed: seed, at: date, calendar: calendar)
        } else {
            var rng = SystemRandomNumberGenerator()
            latest = try latest.drawSlip(using: &rng, at: date, calendar: calendar)
        }
        try persistNow()
        return latest
    }

    func peelSlip() async throws -> Ask {
        latest = try latest.peelSlip()
        try persistNow()
        return latest
    }

    func beginFreshAsk() async throws -> Ask {
        latest = latest.beginFreshAsk()
        schedulePersist()
        return latest
    }

    func flush() async throws {
        writeTask?.cancel()
        writeTask = nil
        if dirty {
            try persistNow()
        }
    }

    func resetAllData() async throws {
        writeTask?.cancel()
        writeTask = nil
        latest = .empty
        dirty = false
        warning = nil
        lastWriteError = nil
        try vault.wipe()
    }

    func seedDemoIfNeeded(now: Date, calendar: Calendar) async throws -> Ask? {
        #if targetEnvironment(simulator)
        if vault.demoPlanted() { return nil }
        latest = AskSeed.ask(now: now, calendar: calendar)
        try persistNow()
        vault.markDemoPlanted()
        return latest
        #else
        return nil
        #endif
    }

    private func schedulePersist() {
        dirty = true
        writeTask?.cancel()
        let delay = writeDelayNanoseconds
        writeTask = Task { [weak self] in
            if delay > 0 {
                try? await Task.sleep(nanoseconds: delay)
            }
            guard !Task.isCancelled else { return }
            await self?.flushIfNeeded()
        }
    }

    private func flushIfNeeded() async {
        writeTask = nil
        do {
            if dirty {
                try persistNow()
            }
        } catch {
            lastWriteError = String(describing: error)
        }
    }

    private func persistNow() throws {
        try vault.save(latest)
        dirty = false
        lastWriteError = nil
    }
}
