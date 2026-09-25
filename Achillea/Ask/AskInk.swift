import SwiftUI

/// Role: Ask. Named colours from Assets.xcassets. Hex lives only in this accessor: #1B161D #261F28 #F1EDF2 #BB64D8 #A296A7.
enum AskInk {
    enum Hex {
        static let background = "#1B161D"
        static let surface = "#261F28"
        static let ink = "#F1EDF2"
        static let accent = "#BB64D8"
        static let muted = "#A296A7"
    }

    static var background: Color { Color("background") }
    static var surface: Color { Color("surface") }
    static var ink: Color { Color("ink") }
    static var accent: Color { Color("accent") }
    static var muted: Color { Color("muted") }
}

/// Role: Ask. SF Pro via Font.system is the UI face. One serif hit on display. Six steps. Never Font.custom, never above 34pt, never below 12pt.
enum AskType {
    static let face = "SF Pro"

    enum Step: CaseIterable {
        case display
        case title
        case headline
        case body
        case caption
        case micro
    }

    static func font(_ step: Step, size: DynamicTypeSize = .large) -> Font {
        switch step {
        case .display:
            if size >= .accessibility3 {
                return .system(.title2, design: .serif).weight(.semibold)
            }
            return .system(.title, design: .serif).weight(.semibold)
        case .title:
            return .system(.title3, design: .default).weight(.semibold)
        case .headline:
            return .system(.headline, design: .default).weight(.semibold)
        case .body:
            return .system(.body, design: .default)
        case .caption:
            return .system(.footnote, design: .default).weight(.medium)
        case .micro:
            return .system(.caption, design: .default)
        }
    }

    static var rail: Font {
        font(.headline).monospacedDigit()
    }
}

/// Role: Ask. One 8pt grid. Hits are 44pt. Views never pick a stray padding.
enum AskSpace {
    static let unit: CGFloat = 8

    static func step(_ n: Int) -> CGFloat {
        unit * CGFloat(n)
    }

    static var hit: CGFloat { 44 }
    static var outer: CGFloat { step(3) }
    static var card: CGFloat { step(2) }
    static var inner: CGFloat { step(1) }
}

/// Role: Ask. Cards and sheets 20pt, chips 12pt. Hairline plus fill. Never a second radius.
enum AskRadius {
    static let card: CGFloat = 20
    static let chip: CGFloat = 12
    static let hairline: CGFloat = 1
}
