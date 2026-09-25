import Foundation

/// Role: Ask. Locale numbers through NumberFormatter. Views never interpolate a count.
enum AskFigures {
    static func integer(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func mass(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func parseMass(_ raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        guard let number = formatter.number(from: trimmed) else { return nil }
        let value = number.doubleValue
        guard value.isFinite, value >= 0 else { return nil }
        return value
    }

    /// Live field filter. Allows an unfinished decimal so typing is not blocked.
    static func allowsMassDraft(_ raw: String) -> Bool {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true }
        if trimmed.contains(where: { $0 == "-" || $0 == "+" }) { return false }
        if parseMass(trimmed) != nil { return true }
        let sep = Locale.current.decimalSeparator ?? "."
        if trimmed == sep { return true }
        if trimmed.hasSuffix(sep) {
            return parseMass(String(trimmed.dropLast())) != nil
        }
        return false
    }

    static func dayTitle(_ key: Int, calendar: Calendar = .current) -> String {
        let year = key / 10_000
        let month = (key / 100) % 100
        let day = key % 100
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        guard let date = calendar.date(from: parts) else {
            return integer(key)
        }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    static func clock(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}
