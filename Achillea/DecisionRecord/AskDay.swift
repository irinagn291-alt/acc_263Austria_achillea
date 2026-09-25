import Foundation

/// Role: DecisionRecord. Day keys are Int YYYYMMDD from Calendar.startOfDay in the user's zone.
enum AskDay {
    static func key(for date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let year = calendar.component(.year, from: start)
        let month = calendar.component(.month, from: start)
        let day = calendar.component(.day, from: start)
        return year * 10_000 + month * 100 + day
    }
}
