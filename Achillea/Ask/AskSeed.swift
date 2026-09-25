import Foundation

/// Role: Ask. Simulator-only dispute crate. Device never seeds. Draw stays live. Never Bare.
enum AskSeed {
    static let rowan = uuid("aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa")
    static let sable = uuid("bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb")
    static let tansy = uuid("cccccccc-cccc-4ccc-8ccc-cccccccccccc")
    static let slipRowan = uuid("dddddddd-dddd-4ddd-8ddd-dddddddddddd")
    static let slipSable = uuid("eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee")
    static let slipTansy = uuid("ffffffff-ffff-4fff-8fff-ffffffffffff")
    static let slipPrior = uuid("12121212-1212-4121-8121-121212121212")
    static let slipUmbel = uuid("34343434-3434-4343-8343-343434343434")
    static let recordRowan = uuid("56565656-5656-4565-8565-565656565656")
    static let recordSable = uuid("78787878-7878-4787-8787-787878787878")
    static let recordTansy = uuid("90909090-9090-4909-8909-909090909090")
    static let recordPrior = uuid("a1a1a1a1-a1a1-41a1-81a1-a1a1a1a1a1a1")
    static let recordUmbel = uuid("b2b2b2b2-b2b2-42b2-82b2-b2b2b2b2b2b2")

    /// Seed identities are literals. Failure here is a programmer error.
    private static func uuid(_ raw: String) -> UUID {
        guard let value = UUID(uuidString: raw) else {
            fatalError("Demo seed UUID literal is invalid")
        }
        return value
    }

    static func ask(now: Date, calendar: Calendar) -> Ask {
        let start = calendar.startOfDay(for: now)
        let yesterday = stamp(day: start, offset: -1, hour: 8, minute: 20, calendar: calendar)
        let twoAgo = stamp(day: start, offset: -2, hour: 15, minute: 45, calendar: calendar)
        let threeAgo = stamp(day: start, offset: -3, hour: 11, minute: 12, calendar: calendar)
        let fourAgoEvening = stamp(day: start, offset: -4, hour: 19, minute: 5, calendar: calendar)
        let fourAgoMorning = stamp(day: start, offset: -4, hour: 9, minute: 30, calendar: calendar)
        let names = [
            Name(id: rowan, text: "Rowan", stalk: Stalk(mass: 1)),
            Name(id: sable, text: "Sable", stalk: Stalk(mass: 1)),
        ]
        let slips = [
            Slip(
                id: slipRowan,
                nameID: rowan,
                nameText: "Rowan",
                mass: 1,
                dayKey: AskDay.key(for: yesterday, calendar: calendar),
                filedAt: yesterday
            ),
            Slip(
                id: slipSable,
                nameID: sable,
                nameText: "Sable",
                mass: 1,
                dayKey: AskDay.key(for: twoAgo, calendar: calendar),
                filedAt: twoAgo
            ),
            Slip(
                id: slipTansy,
                nameID: tansy,
                nameText: "Tansy",
                mass: 1,
                dayKey: AskDay.key(for: threeAgo, calendar: calendar),
                filedAt: threeAgo
            ),
            Slip(
                id: slipPrior,
                nameID: rowan,
                nameText: "Rowan",
                mass: 1,
                dayKey: AskDay.key(for: fourAgoEvening, calendar: calendar),
                filedAt: fourAgoEvening
            ),
            Slip(
                id: slipUmbel,
                nameID: sable,
                nameText: "Sable",
                mass: 1,
                dayKey: AskDay.key(for: fourAgoMorning, calendar: calendar),
                filedAt: fourAgoMorning
            ),
        ]
        let records = slips.enumerated().map { index, slip in
            let ids = [recordRowan, recordSable, recordTansy, recordPrior, recordUmbel]
            return DecisionRecord(
                id: ids[index],
                slipID: slip.id,
                nameID: slip.nameID,
                nameText: slip.nameText,
                dayKey: slip.dayKey,
                filedAt: slip.filedAt
            )
        }
        return Ask(
            names: names,
            fold: .idle,
            gageMark: nil,
            slips: slips,
            records: records,
            dispute: true,
            onboardingComplete: true
        )
    }

    private static func stamp(
        day: Date,
        offset: Int,
        hour: Int,
        minute: Int,
        calendar: Calendar
    ) -> Date {
        let shifted = calendar.date(byAdding: .day, value: offset, to: day) ?? day
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: shifted) ?? shifted
    }
}
