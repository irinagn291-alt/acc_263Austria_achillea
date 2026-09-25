import Foundation

/// Role: Ask. Projects AskDocument to UserDefaults plus an atomic Application Support file.
struct AskVault {
    var directory: URL
    var suiteName: String?

    init(directory: URL, suiteName: String? = nil) {
        self.directory = directory
        self.suiteName = suiteName
    }

    static func supportDirectory() throws -> URL {
        let root = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return root.appendingPathComponent("Achillea", isDirectory: true)
    }

    func load() -> (ask: Ask, warning: AskWarning?) {
        if let ask = decode(box().data(forKey: AskKey.snapshot)) {
            return (ask, nil)
        }
        if let ask = decode(read(fileURL)) {
            return (ask, nil)
        }
        if let ask = decode(box().data(forKey: AskKey.backup)) {
            return (ask, .recoveredFromBackup)
        }
        if let ask = decode(read(backupURL)) {
            return (ask, .recoveredFromBackup)
        }
        let hadPayload = box().data(forKey: AskKey.snapshot) != nil
            || FileManager.default.fileExists(atPath: fileURL.path)
        return (.empty, hadPayload ? .startedEmpty : nil)
    }

    func save(_ ask: Ask) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try AskCodec.encode(AskDocument.envelope(from: ask))
        let defaults = box()
        if let current = defaults.data(forKey: AskKey.snapshot) {
            defaults.set(current, forKey: AskKey.backup)
        }
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: backupURL)
            try? FileManager.default.copyItem(at: fileURL, to: backupURL)
        }
        defaults.set(data, forKey: AskKey.snapshot)
        try data.write(to: fileURL, options: .atomic)
        excludeCacheIfPresent()
    }

    func wipe() throws {
        let defaults = box()
        defaults.removeObject(forKey: AskKey.snapshot)
        defaults.removeObject(forKey: AskKey.backup)
        defaults.removeObject(forKey: AskKey.demo)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        if FileManager.default.fileExists(atPath: backupURL.path) {
            try FileManager.default.removeItem(at: backupURL)
        }
        if FileManager.default.fileExists(atPath: cacheURL.path) {
            try FileManager.default.removeItem(at: cacheURL)
        }
    }

    func demoPlanted() -> Bool {
        box().object(forKey: AskKey.demo) != nil
    }

    func markDemoPlanted() {
        box().set(true, forKey: AskKey.demo)
    }

    private func decode(_ data: Data?) -> Ask? {
        guard let data else { return nil }
        return try? AskCodec.decode(data).asAsk()
    }

    private func read(_ url: URL) -> Data? {
        try? Data(contentsOf: url)
    }

    private var fileURL: URL {
        directory.appendingPathComponent("ask.json", isDirectory: false)
    }

    private var backupURL: URL {
        directory.appendingPathComponent("ask.json.backup", isDirectory: false)
    }

    private var cacheURL: URL {
        directory.appendingPathComponent("net-cache.json", isDirectory: false)
    }

    private func excludeCacheIfPresent() {
        guard FileManager.default.fileExists(atPath: cacheURL.path) else { return }
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var url = cacheURL
        try? url.setResourceValues(values)
    }

    private func box() -> UserDefaults {
        if let suiteName {
            return UserDefaults(suiteName: suiteName) ?? UserDefaults()
        }
        return .standard
    }
}
