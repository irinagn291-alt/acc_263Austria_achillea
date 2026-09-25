import Foundation
import Observation
import SwiftUI

/// Role: Ask. Sheets from the locked rail. History, Settings, and the gage-then-draw guide. Never tabs.
enum AskSheet: String, Identifiable, Equatable, Sendable {
    case history
    case settings
    case twist

    var id: String { rawValue }
}

/// Role: Ask. Observable fold over AskStore. Views call gageAsk, drawSlip, and peelSlip and never keep a parallel bool.
@MainActor
@Observable
final class AskDesk {
    let store: AskStore
    private let calendar: Calendar
    private let clock: @Sendable () -> Date
    private let plantsDemo: Bool

    private(set) var ask: Ask
    var isBooting: Bool
    var showsOnboarding: Bool
    var sheet: AskSheet?
    var recoveredNotice: Bool
    var fault: String?
    var gageBusy: Bool
    var drawBusy: Bool
    var peelBusy: Bool
    var pledgeBusy: Bool
    var showSuccess: Bool
    var commitPulse: Int
    var draftName: String
    var draftMass: String
    var emptyFirst: String
    var emptySecond: String
    var drawSeed: UInt64?

    private var reviewConsumed: Bool
    private var gageInFlight: Bool
    private var drawInFlight: Bool
    private var peelInFlight: Bool
    private var pledgeInFlight: Bool
    private var successTask: Task<Void, Never>?

    init(
        store: AskStore,
        calendar: Calendar = .current,
        now: @escaping @Sendable () -> Date = { Date() },
        plantsDemo: Bool = true,
        isBooting: Bool = true
    ) {
        self.store = store
        self.calendar = calendar
        self.clock = now
        self.plantsDemo = plantsDemo
        self.ask = .empty
        self.isBooting = isBooting
        self.showsOnboarding = false
        self.sheet = nil
        self.recoveredNotice = false
        self.fault = nil
        self.gageBusy = false
        self.drawBusy = false
        self.peelBusy = false
        self.pledgeBusy = false
        self.showSuccess = false
        self.commitPulse = 0
        self.draftName = ""
        self.draftMass = "1"
        self.emptyFirst = ""
        self.emptySecond = ""
        self.drawSeed = nil
        self.reviewConsumed = false
        self.gageInFlight = false
        self.drawInFlight = false
        self.peelInFlight = false
        self.pledgeInFlight = false
    }

    static func live() -> AskDesk {
        AskDesk(store: AskStore.applicationSupportStore())
    }

    var isEmptyAsk: Bool {
        ask.names.isEmpty
    }

    var gageEnabled: Bool {
        ask.canGage && !gageInFlight && !drawInFlight
    }

    var drawEnabled: Bool {
        ask.canDraw && !drawInFlight && !gageInFlight
    }

    var liveIsDraw: Bool {
        ask.canDraw
    }

    var historyIsEmpty: Bool {
        ask.slips.isEmpty
    }

    var settingsIsEmpty: Bool {
        ask.names.isEmpty && ask.slips.isEmpty
    }

    var groupedSlips: [(key: Int, slips: [Slip])] {
        let groups = Dictionary(grouping: ask.slips, by: \.dayKey)
        return groups.keys.sorted(by: >).map { key in
            (key, (groups[key] ?? []).sorted { $0.filedAt > $1.filedAt })
        }
    }

    var newestSlip: Slip? {
        ask.slips.last
    }

    func boot(arguments: [String] = ProcessInfo.processInfo.arguments) async {
        guard isBooting else { return }
        let loaded = await store.load()
        ask = loaded.ask
        recoveredNotice = loaded.warning != nil
        if let warning = loaded.warning {
            fault = AskCopy.warning(warning)
        }
        if plantsDemo {
            do {
                _ = try await store.seedDemoIfNeeded(now: clock(), calendar: calendar)
            } catch {
                fault = AskCopy.writeFailed
            }
            await refreshFromStore()
        }
        showsOnboarding = !ask.onboardingComplete
        isBooting = false
        if !showsOnboarding {
            applyReview(arguments)
        }
    }

    func flush() async {
        do {
            try await store.flush()
            if fault == AskCopy.writeFailed {
                fault = nil
            }
            await refreshFromStore()
        } catch {
            fault = AskCopy.writeFailed
            await refreshFromStore()
        }
    }

    func retryLoad() async {
        let loaded = await store.load()
        ask = loaded.ask
        recoveredNotice = loaded.warning != nil
        if let warning = loaded.warning {
            fault = AskCopy.warning(warning)
        } else {
            fault = nil
        }
    }

    func handle(phase: ScenePhase) async {
        switch phase {
        case .inactive, .background:
            await flush()
        case .active:
            break
        @unknown default:
            break
        }
    }

    func finishOnboarding() async {
        do {
            ask = try await store.setOnboardingComplete(true)
            try await store.flush()
            fault = nil
        } catch {
            fault = AskCopy.writeFailed
            await refreshFromStore()
        }
        showsOnboarding = false
        applyReview(ProcessInfo.processInfo.arguments)
    }

    func replayOnboarding() {
        sheet = nil
        showsOnboarding = true
    }

    func present(_ sheet: AskSheet) {
        self.sheet = sheet
    }

    func gageAsk() async {
        guard !gageInFlight else { return }
        gageInFlight = true
        let pulse = Task {
            try await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { gageBusy = true }
        }
        do {
            ask = try await store.gageAsk(at: clock(), calendar: calendar)
            fault = nil
        } catch {
            fault = AskCopy.fault(error)
            await refreshFromStore()
        }
        pulse.cancel()
        gageBusy = false
        gageInFlight = false
    }

    func drawSlip() async {
        guard !drawInFlight else { return }
        drawInFlight = true
        let pulse = Task {
            try await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { drawBusy = true }
        }
        do {
            ask = try await store.drawSlip(seed: drawSeed, at: clock(), calendar: calendar)
            fault = nil
            commitPulse += 1
            flashSuccess()
        } catch {
            fault = AskCopy.fault(error)
            await refreshFromStore()
        }
        pulse.cancel()
        drawBusy = false
        drawInFlight = false
    }

    func peelSlip() async {
        guard !peelInFlight else { return }
        peelInFlight = true
        let pulse = Task {
            try await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { peelBusy = true }
        }
        do {
            ask = try await store.peelSlip()
            fault = nil
        } catch {
            fault = AskCopy.fault(error)
            await refreshFromStore()
        }
        pulse.cancel()
        peelBusy = false
        peelInFlight = false
    }

    func beginFreshAsk() async {
        do {
            ask = try await store.beginFreshAsk()
            fault = nil
        } catch {
            fault = AskCopy.writeFailed
            await refreshFromStore()
        }
    }

    func pledgeEmptyPair() async {
        await pledge(first: emptyFirst, second: emptySecond)
    }

    func pledge(first: String, second: String) async {
        guard !pledgeInFlight else { return }
        pledgeInFlight = true
        let pulse = Task {
            try await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { pledgeBusy = true }
        }
        do {
            _ = try await store.pledge(Name(text: first, stalk: Stalk(mass: 1)))
            _ = try await store.pledge(Name(text: second, stalk: Stalk(mass: 1)))
            emptyFirst = ""
            emptySecond = ""
            fault = nil
            await refreshFromStore()
        } catch {
            fault = AskCopy.fault(error)
            await refreshFromStore()
        }
        pulse.cancel()
        pledgeBusy = false
        pledgeInFlight = false
    }

    func addDraft() async {
        guard !pledgeInFlight else { return }
        let mass = AskFigures.parseMass(draftMass) ?? 1
        pledgeInFlight = true
        do {
            ask = try await store.pledge(Name(text: draftName, stalk: Stalk(mass: mass)))
            draftName = ""
            draftMass = "1"
            fault = nil
        } catch {
            fault = AskCopy.fault(error)
            await refreshFromStore()
        }
        pledgeInFlight = false
    }

    func commitName(id: UUID, text: String) async {
        guard let existing = ask.names.first(where: { $0.id == id }) else { return }
        do {
            ask = try await store.pledge(Name(id: id, text: text, stalk: existing.stalk))
            fault = nil
        } catch {
            fault = AskCopy.fault(error)
            await refreshFromStore()
        }
    }

    func commitMass(id: UUID, raw: String) async {
        guard let mass = AskFigures.parseMass(raw) else {
            fault = AskCopy.fault(AskFault.stalkBelowFloor)
            await refreshFromStore()
            return
        }
        do {
            ask = try await store.setStalk(nameID: id, mass: mass)
            fault = nil
        } catch {
            fault = AskCopy.fault(error)
            await refreshFromStore()
        }
    }

    func remove(nameID: UUID) async {
        do {
            ask = try await store.remove(nameID: nameID)
            fault = nil
        } catch {
            fault = AskCopy.fault(error)
            await refreshFromStore()
        }
    }

    func setDispute(_ on: Bool) async {
        do {
            ask = try await store.setDispute(on)
            fault = nil
        } catch {
            fault = AskCopy.fault(error)
            await refreshFromStore()
        }
    }

    func resetAllData() async {
        successTask?.cancel()
        do {
            try await store.resetAllData()
            await refreshFromStore()
            sheet = nil
            draftName = ""
            draftMass = "1"
            emptyFirst = ""
            emptySecond = ""
            recoveredNotice = false
            showSuccess = false
            fault = nil
            showsOnboarding = true
            reviewConsumed = true
        } catch {
            fault = AskCopy.writeFailed
            await refreshFromStore()
        }
    }

    func applyReviewIfNeeded(_ arguments: [String]) {
        applyReview(arguments)
    }

    private func applyReview(_ arguments: [String]) {
        let alreadyConsumed = reviewConsumed
        var consumed = reviewConsumed
        let review = AskReview.consume(
            arguments: arguments,
            onboardingComplete: ask.onboardingComplete,
            consumed: &consumed
        )
        reviewConsumed = consumed
        if let review {
            switch review {
            case .today:
                sheet = nil
            case .log:
                sheet = .history
            case .goals:
                sheet = .settings
            }
            return
        }
        guard !alreadyConsumed, consumed, let slug = reviewSlug(arguments) else { return }
        if AskReview.isHomeSlug(slug) {
            sheet = nil
            return
        }
        if let cover = AskReview.sheet(forSlug: slug) {
            sheet = cover
        }
    }

    func noteCalendarShift() async {
        await refreshFromStore()
    }

    private func reviewSlug(_ arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: "-ReviewScreen") else { return nil }
        let next = arguments.index(after: index)
        guard arguments.indices.contains(next) else { return nil }
        return arguments[next]
    }

    private func flashSuccess() {
        successTask?.cancel()
        showSuccess = true
        successTask = Task {
            try? await Task.sleep(for: .milliseconds(1200))
            if !Task.isCancelled {
                showSuccess = false
            }
        }
    }

    private func refreshFromStore() async {
        ask = await store.ask()
        if let write = await store.lastWriteError, !write.isEmpty {
            fault = AskCopy.writeFailed
        }
    }
}
