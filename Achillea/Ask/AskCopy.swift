import Foundation

/// Role: Ask. Warm short copy. Periods, never an em dash. The ui axis is never a title.
enum AskCopy {
    static let appTitle = "Achillea"
    static let jobHeadline = "Draw picks one name."
    static let jobLine = "Draw chooses from the names below and saves that pick in History."
    static let gagedLine = "The names are locked. Draw chooses one and saves it in History."
    static let filedLine = "That pick is in History. Start a new list for another."
    static let disputeLine = "Both names share the same chance. Draw chooses one and saves it in History."
    static let emptyHeadline = "Type two names."
    static let emptyLine = "Draw will pick one of them and save it in History."
    static let emptyAction = "Save names"
    static let firstName = "First name"
    static let secondName = "Second name"
    static let addName = "Add a name"
    static let namePlaceholder = "Name"
    static let massPlaceholder = "Chance"
    static let disputeTitle = "Even chance"
    static let disputeHint = "Both names get the same chance. Draw can run now."
    static let gageVerb = "Lock names"
    static let drawVerb = "Draw"
    static let retractVerb = "Undo last pick"
    static let newAsk = "New list"
    static let historyTitle = "History"
    static let settingsTitle = "Settings"
    static let twistTitle = "How Draw works"
    static let close = "Close"
    static let done = "Done"
    static let retry = "Retry"
    static let skip = "Skip"
    static let continueVerb = "Continue"
    static let beginVerb = "Begin"
    static let writeFailed = "Could not save the list. Try again."
    static let recovered = "Restored the last good list."
    static let startedEmpty = "The saved list could not be read. Starting empty."
    static let historyEmptyHeadline = "No picks yet."
    static let historyEmptyLine = "Draw a name, then read it here."
    static let historyEmptyAction = "Back to the list"
    static let historyErrorHeadline = "History could not load."
    static let settingsEmptyHeadline = "Nothing stored yet."
    static let settingsEmptyLine = "Add two names on the list, then come back."
    static let generatorTitle = "How Draw picks"
    static let generatorBody =
        "Draw chooses one name from the list you typed. The same names and chances give the same pick again."
    static let contactTitle = "Contact"
    static let contactDetail = "achillea-ask.pro/contact-us"
    static let replayOnboarding = "Re-run onboarding"
    static let resetTitle = "Reset all data"
    static let resetConfirm = "Reset all data?"
    static let resetMessage = "This removes names, locks, and saved picks on this device."
    static let resetAction = "Reset all data"
    static let retractConfirm = "Undo the last pick?"
    static let retractMessage = "The newest pick leaves History. Names stay."
    static let twistHeadline = "Lock the list, then pick."
    static let twistBody =
        "Lock names so they cannot change. Draw then picks one name by chance and saves it in History. Draw does nothing until the list is locked, unless even chance is on."
    static let twistDispute =
        "Even chance gives both names the same chance, so Draw can run without locking."
    static let onboarding1Headline = "One honest pick from names you type."
    static let onboarding1Line = "Not a room spinner. Not a score sheet."
    static let onboarding2Headline = "Lock the list. Then Draw."
    static let onboarding2Line = "Once locked, names and chances stay put."
    static let onboarding3Headline = "Filed picks stay on this device."
    static let onboarding3Line = "History keeps each pick. Undo last pick removes the newest one."
    static let onboarding4Headline = "Even chance treats two names the same."
    static let onboarding4Line = "Chances stay even. Draw can run without a lock."
    static let namesCaption = "Names"
    static let chanceCaption = "Chance"
    static let chanceEven = "Even"
    static let statusCaption = "Status"
    static let readyToPick = "Ready to pick"
    static let lockedList = "Locked"
    static let pickSaved = "Saved"
    static let drawHint = "Tap Draw to choose one name from this list."
    static let lockHint = "Lock the names, then Draw can pick."
    static let filedHint = "That pick is saved. Start a new list when you want another."
    static let filedPrefix = "Picked"
    static let lastPickTitle = "Last pick"
    static let lastPickEmpty = "Draw will write the next name here."
    static let recentPicksTitle = "Recent picks"
    static let addVerb = "Add"
    static let removeName = "Remove name"
    static let openHistory = "Open History"
    static let openSettings = "Open Settings"
    static let openTwist = "How Draw works"

    static func foldWord(_ fold: AskFold) -> String {
        switch fold {
        case .idle:
            return "Ready"
        case .gaged:
            return lockedList
        case .filed:
            return pickSaved
        }
    }

    static func chanceWord(on ask: Ask) -> String {
        if ask.dispute {
            return chanceEven
        }
        return AskFigures.mass(ask.railStalkSum)
    }

    static func job(on ask: Ask) -> String {
        if ask.fold == .filed {
            return filedLine
        }
        if ask.fold == .gaged {
            return gagedLine
        }
        if ask.dispute {
            return disputeLine
        }
        return jobLine
    }

    static func panelHint(on ask: Ask) -> String {
        if ask.fold == .filed {
            return filedHint
        }
        if ask.canDraw {
            return drawHint
        }
        return lockHint
    }

    static func filedPick(_ name: String) -> String {
        "\(filedPrefix) \(name)"
    }

    static func fault(_ error: Error) -> String {
        guard let fault = error as? AskFault else { return writeFailed }
        switch fault {
        case .bare:
            return "Type two names before you lock the list."
        case .tooFewNames:
            return "The list needs two names."
        case .blankName:
            return "A name cannot be empty."
        case .stalkBelowFloor:
            return "Each chance must be a number above zero."
        case .namesFrozen:
            return "The names are already locked."
        case .alreadyGaged:
            return "The list is already locked."
        case .idleDrawRefused:
            return "Lock the names first, then Draw."
        case .alreadyFiled:
            return "This list already saved a pick."
        case .disputeNeedsTwo:
            return "Even chance needs two names."
        case .disputeSkipsGage:
            return "Even chance is on. Draw from here."
        case .disputeLocksMass:
            return "Even chance keeps both chances the same."
        case .unknownName:
            return "That name is not in the list."
        case .nothingToPeel:
            return "There is no pick to undo."
        }
    }

    static func warning(_ warning: AskWarning) -> String {
        switch warning {
        case .recoveredFromBackup:
            return recovered
        case .startedEmpty:
            return startedEmpty
        }
    }
}
