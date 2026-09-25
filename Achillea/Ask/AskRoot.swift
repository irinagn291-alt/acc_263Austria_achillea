import SwiftUI

/// Role: Ask. Root fused pick. Name table and stalk rail stay. History and Settings arrive as sheets.
struct AskRoot: View {
    @Bindable var desk: AskDesk
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case emptyFirst
        case emptySecond
        case draft
        case draftMass
    }

    private var usesSplit: Bool {
        sizeClass == .regular
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AskSpace.card) {
                chrome
                titleBlock
                StalkRail(ask: desk.ask, reduceMotion: reduceMotion)
                    .askReveal(index: 0, reduceMotion: reduceMotion)
                if desk.isEmptyAsk {
                    emptyBody
                } else {
                    populatedBody
                }
            }
            .padding(.horizontal, AskSpace.outer)
            .padding(.top, AskSpace.inner)
            .padding(.bottom, AskSpace.outer)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(AskInk.background.ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(AskCopy.done) {
                        focusedField = nil
                    }
                    .font(AskType.font(.headline, size: typeSize))
                    .foregroundStyle(AskInk.ink)
                    .askHit()
                    .accessibilityLabel(AskCopy.done)
                }
            }
        }
        .sheet(item: $desk.sheet) { sheet in
            cover(sheet)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: desk.commitPulse)
        .overlay {
            if desk.showSuccess {
                Image(AskArt.successMark)
                    .askCutout(maxHeight: AskSpace.step(10))
                    .padding(AskSpace.outer)
                    .askSurface()
                    .accessibilityHidden(true)
            }
        }
        .animation(AskMotion.snap(reduceMotion), value: desk.ask.fold)
        .animation(AskMotion.snap(reduceMotion), value: desk.showSuccess)
    }

    private var chrome: some View {
        HStack(spacing: AskSpace.inner) {
            Button {
                desk.present(.history)
            } label: {
                Image(systemName: "clock")
                    .foregroundStyle(AskInk.ink)
                    .frame(minWidth: AskSpace.hit, minHeight: AskSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(AskGlyphStyle())
            .accessibilityLabel(AskCopy.openHistory)

            Text(AskCopy.appTitle)
                .font(AskType.font(.title, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            Button {
                desk.present(.settings)
            } label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(AskInk.ink)
                    .frame(minWidth: AskSpace.hit, minHeight: AskSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(AskGlyphStyle())
            .accessibilityLabel(AskCopy.openSettings)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: AskSpace.inner) {
            Text(AskCopy.jobHeadline)
                .font(AskType.font(.display, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .lineLimit(2)
            Text(AskCopy.job(on: desk.ask))
                .font(AskType.font(.body, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .askReveal(index: 1, reduceMotion: reduceMotion)
    }

    private var emptyBody: some View {
        VStack(alignment: .leading, spacing: AskSpace.card) {
            ScrollView {
                VStack(alignment: .leading, spacing: AskSpace.card) {
                    emptyCopy(showsSpacer: false)
                    if let fault = desk.fault {
                        AskNotice(message: fault) {
                            Task { await desk.retryLoad() }
                        }
                    }
                    emptyFields
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            Button(AskCopy.emptyAction) {
                focusedField = nil
                Task { await desk.pledgeEmptyPair() }
            }
            .buttonStyle(AskVerbStyle(emphasized: true, isLoading: desk.pledgeBusy))
            .disabled(desk.emptyFirst.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || desk.emptySecond.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func emptyCopy(showsSpacer: Bool) -> some View {
        VStack(alignment: .leading, spacing: AskSpace.card) {
            Image(AskArt.emptyHome)
                .askCutout(maxHeight: AskSpace.step(16))
            Text(AskCopy.emptyHeadline)
                .font(AskType.font(.title, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .lineLimit(2)
            Text(AskCopy.emptyLine)
                .font(AskType.font(.body, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .lineLimit(3)
            if showsSpacer {
                Spacer(minLength: AskSpace.inner)
            }
        }
    }

    private var emptyFields: some View {
        VStack(spacing: AskSpace.inner) {
            TextField(AskCopy.firstName, text: $desk.emptyFirst)
                .font(AskType.font(.body, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .padding(.horizontal, AskSpace.card)
                .frame(minHeight: AskSpace.hit)
                .askSurface()
                .focused($focusedField, equals: .emptyFirst)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .onSubmit { focusedField = .emptySecond }
            TextField(AskCopy.secondName, text: $desk.emptySecond)
                .font(AskType.font(.body, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .padding(.horizontal, AskSpace.card)
                .frame(minHeight: AskSpace.hit)
                .askSurface()
                .focused($focusedField, equals: .emptySecond)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                    Task { await desk.pledgeEmptyPair() }
                }
        }
    }

    @ViewBuilder
    private var populatedBody: some View {
        if usesSplit {
            HStack(alignment: .top, spacing: AskSpace.card) {
                namesPane
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                drawPane
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            VStack(alignment: .leading, spacing: AskSpace.card) {
                pickBanner
                nameTable
                    .frame(height: tableHeight)
                if desk.ask.fold == .idle {
                    addRow
                    disputeRow
                }
                if let fault = desk.fault {
                    AskNotice(message: fault) {
                        Task { await desk.retryLoad() }
                    }
                }
                verbCard
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var namesPane: some View {
        VStack(alignment: .leading, spacing: AskSpace.card) {
            pickBanner
            nameTable
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if desk.ask.fold == .idle {
                addRow
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var drawPane: some View {
        VStack(alignment: .leading, spacing: AskSpace.card) {
            Text(AskCopy.foldWord(desk.ask.fold))
                .font(AskType.font(.title, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .lineLimit(2)
            Text(AskCopy.panelHint(on: desk.ask))
                .font(AskType.font(.body, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .lineLimit(4)
            if desk.ask.fold == .idle {
                disputeRow
            }
            if let fault = desk.fault {
                AskNotice(message: fault) {
                    Task { await desk.retryLoad() }
                }
            }
            verbCard
            lastPickCard
            recentPicksBlock
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var lastPickCard: some View {
        Button {
            desk.present(.history)
        } label: {
            VStack(alignment: .leading, spacing: AskSpace.inner) {
                Text(AskCopy.lastPickTitle)
                    .font(AskType.font(.caption, size: typeSize))
                    .foregroundStyle(AskInk.muted)
                    .lineLimit(1)
                if let pick = lastFiledSlip {
                    Text(pick.nameText)
                        .font(AskType.font(.display, size: typeSize))
                        .foregroundStyle(AskInk.ink)
                        .lineLimit(2)
                    Text(AskFigures.clock(pick.filedAt))
                        .font(AskType.font(.body, size: typeSize))
                        .foregroundStyle(AskInk.ink)
                        .lineLimit(1)
                } else {
                    Text(AskCopy.lastPickEmpty)
                        .font(AskType.font(.body, size: typeSize))
                        .foregroundStyle(AskInk.ink)
                        .lineLimit(3)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(AskSpace.card)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .askSurface()
        .accessibilityLabel(lastPickVoice)
    }

    private var lastPickVoice: String {
        if let pick = lastFiledSlip {
            return "\(AskCopy.lastPickTitle), \(pick.nameText), \(AskFigures.clock(pick.filedAt))"
        }
        return "\(AskCopy.lastPickTitle), \(AskCopy.lastPickEmpty)"
    }

    private var lastFiledSlip: Slip? {
        desk.ask.slips.max(by: { $0.filedAt < $1.filedAt })
    }

    private var recentPicksBlock: some View {
        VStack(alignment: .leading, spacing: AskSpace.inner) {
            Text(AskCopy.recentPicksTitle)
                .font(AskType.font(.caption, size: typeSize))
                .foregroundStyle(AskInk.muted)
                .lineLimit(1)
            ForEach(recentPreviewSlips) { slip in
                Button {
                    desk.present(.history)
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: AskSpace.inner) {
                        Text(slip.nameText)
                            .font(AskType.font(.headline, size: typeSize))
                            .foregroundStyle(AskInk.ink)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(AskFigures.clock(slip.filedAt))
                            .font(AskType.font(.body, size: typeSize))
                            .foregroundStyle(AskInk.muted)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: AskSpace.hit, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(AskQuietStyle())
                .accessibilityLabel(
                    "\(slip.nameText), \(AskFigures.clock(slip.filedAt))"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
    }

    private var recentPreviewSlips: [Slip] {
        let ordered = desk.ask.slips.sorted { $0.filedAt > $1.filedAt }
        return Array(ordered.dropFirst().prefix(3))
    }

    @ViewBuilder
    private var pickBanner: some View {
        if let pick = desk.newestSlip, desk.ask.fold == .filed {
            Text(AskCopy.filedPick(pick.nameText))
                .font(AskType.font(.headline, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AskSpace.card)
                .askSurface()
                .askReveal(index: 2, reduceMotion: reduceMotion)
        }
    }

    private var nameTable: some View {
        NameTableHost(
            names: desk.ask.names,
            frozen: desk.ask.fold != .idle,
            hidesStalk: desk.ask.hidesStalkRails,
            onCommitText: { id, text in
                Task { await desk.commitName(id: id, text: text) }
            },
            onCommitMass: { id, raw in
                Task { await desk.commitMass(id: id, raw: raw) }
            },
            onRemove: { id in
                Task { await desk.remove(nameID: id) }
            }
        )
        .frame(maxWidth: .infinity)
    }

    private var tableHeight: CGFloat {
        let rows = max(desk.ask.names.count, 1)
        return CGFloat(rows) * AskSpace.step(10)
    }

    private var addRow: some View {
        HStack(spacing: AskSpace.inner) {
            TextField(AskCopy.addName, text: $desk.draftName)
                .font(AskType.font(.body, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .padding(.horizontal, AskSpace.card)
                .frame(minHeight: AskSpace.hit)
                .askSurface()
                .focused($focusedField, equals: .draft)
                .textInputAutocapitalization(.words)
            if desk.ask.hidesStalkRails == false {
                TextField(AskCopy.massPlaceholder, text: $desk.draftMass)
                    .font(AskType.rail)
                    .foregroundStyle(AskInk.ink)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal, AskSpace.card)
                    .frame(width: AskSpace.step(10))
                    .frame(minHeight: AskSpace.hit)
                    .askSurface()
                    .focused($focusedField, equals: .draftMass)
                    .onChange(of: desk.draftMass) { old, next in
                        if AskFigures.allowsMassDraft(next) == false {
                            desk.draftMass = old
                        }
                    }
            }
            Button(AskCopy.addVerb) {
                focusedField = nil
                Task { await desk.addDraft() }
            }
            .buttonStyle(AskQuietStyle())
            .frame(width: AskSpace.step(10))
            .disabled(desk.draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private var disputeRow: some View {
        Toggle(isOn: Binding(
            get: { desk.ask.dispute },
            set: { value in Task { await desk.setDispute(value) } }
        )) {
            VStack(alignment: .leading, spacing: AskSpace.inner) {
                Text(AskCopy.disputeTitle)
                    .font(AskType.font(.headline, size: typeSize))
                    .foregroundStyle(AskInk.ink)
                Text(AskCopy.disputeHint)
                    .font(AskType.font(.caption, size: typeSize))
                    .foregroundStyle(AskInk.muted)
            }
        }
        .tint(AskInk.accent)
        .padding(AskSpace.card)
        .askSurface()
        .disabled(desk.ask.fold != .idle)
    }

    private var verbCard: some View {
        VStack(spacing: AskSpace.inner) {
            if desk.drawEnabled || desk.liveIsDraw {
                Button {
                    focusedField = nil
                    Task { await desk.drawSlip() }
                } label: {
                    clipVerb(AskCopy.drawVerb, showsClip: desk.drawEnabled)
                }
                .buttonStyle(
                    AskVerbStyle(emphasized: true, isLoading: desk.drawBusy)
                )
                .disabled(desk.drawEnabled == false)
                .accessibilityLabel(AskCopy.drawVerb)
            } else if desk.gageEnabled || desk.ask.canGage {
                Button {
                    focusedField = nil
                    Task { await desk.gageAsk() }
                } label: {
                    clipVerb(AskCopy.gageVerb, showsClip: desk.gageEnabled)
                }
                .buttonStyle(
                    AskVerbStyle(emphasized: desk.gageEnabled, isLoading: desk.gageBusy)
                )
                .disabled(desk.gageEnabled == false)
                .accessibilityLabel(AskCopy.gageVerb)
            }
            if desk.ask.fold == .filed {
                Button(AskCopy.newAsk) {
                    Task { await desk.beginFreshAsk() }
                }
                .buttonStyle(AskVerbStyle(emphasized: true, isLoading: false))
            }
        }
    }

    private func clipVerb(_ title: String, showsClip: Bool) -> some View {
        HStack(spacing: AskSpace.inner) {
            if showsClip {
                Image(AskArt.controlFace)
                    .askCutout(maxWidth: AskSpace.step(3), maxHeight: AskSpace.step(3))
            }
            Text(title)
        }
    }

    @ViewBuilder
    private func cover(_ sheet: AskSheet) -> some View {
        switch sheet {
        case .history:
            SlipHistory(desk: desk)
        case .settings:
            SettingsView(desk: desk)
        case .twist:
            GageGuide(desk: desk)
        }
    }
}
