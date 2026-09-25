import SwiftUI

/// Role: Slip. History sheet of filed slips keyed by Int YYYYMMDD. Empty, populated, and error.
struct SlipHistory: View {
    @Bindable var desk: AskDesk
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var confirmRetract = false

    var body: some View {
        AskSheetHost {
            NavigationStack {
                Group {
                    if let fault = desk.fault, desk.historyIsEmpty {
                        AskQuietPage(
                            art: AskArt.emptyList,
                            headline: AskCopy.historyErrorHeadline,
                            line: fault,
                            actionTitle: AskCopy.retry,
                            action: { Task { await desk.retryLoad() } }
                        )
                    } else if desk.historyIsEmpty {
                        AskQuietPage(
                            art: AskArt.emptyList,
                            headline: AskCopy.historyEmptyHeadline,
                            line: AskCopy.historyEmptyLine,
                            actionTitle: AskCopy.historyEmptyAction,
                            action: { dismiss() }
                        )
                    } else {
                        historyBoard
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AskInk.background.ignoresSafeArea())
                .navigationTitle(AskCopy.historyTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { closeToolbar }
                .confirmationDialog(
                    AskCopy.retractConfirm,
                    isPresented: $confirmRetract,
                    titleVisibility: .visible
                ) {
                    Button(AskCopy.retractVerb, role: .destructive) {
                        Task { await desk.peelSlip() }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text(AskCopy.retractMessage)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    /// Button 44 + footer padding. Scroll content uses this so the last card never sits under Undo.
    private var undoFooterHeight: CGFloat {
        AskSpace.hit + AskSpace.inner + AskSpace.outer
    }

    private var historyBoard: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AskSpace.card) {
                ForEach(desk.groupedSlips, id: \.key) { group in
                    VStack(alignment: .leading, spacing: AskSpace.inner) {
                        Text(AskFigures.dayTitle(group.key))
                            .font(AskType.font(.caption, size: typeSize))
                            .foregroundStyle(AskInk.muted)
                        ForEach(group.slips) { slip in
                            pickCard(slip)
                        }
                    }
                }
            }
            .padding(.horizontal, AskSpace.outer)
            .padding(.top, AskSpace.card)
            .padding(.bottom, AskSpace.card)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
        .contentMargins(.bottom, undoFooterHeight, for: .scrollContent)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            undoFooter
        }
    }

    private func pickCard(_ slip: Slip) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: AskSpace.inner) {
            VStack(alignment: .leading, spacing: AskSpace.inner) {
                Text(slip.nameText)
                    .font(AskType.font(.headline, size: typeSize))
                    .foregroundStyle(AskInk.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(AskFigures.clock(slip.filedAt))
                    .font(AskType.font(.body, size: typeSize))
                    .foregroundStyle(AskInk.muted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AskSpace.card)
        .frame(minHeight: AskSpace.hit)
        .askSurface()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(slip.nameText), \(AskFigures.clock(slip.filedAt))")
    }

    private var undoFooter: some View {
        Button(AskCopy.retractVerb) {
            confirmRetract = true
        }
        .buttonStyle(AskQuietStyle(destructive: true))
        .disabled(desk.peelBusy)
        .padding(.horizontal, AskSpace.outer)
        .padding(.top, AskSpace.inner)
        .padding(.bottom, AskSpace.outer)
        .frame(maxWidth: .infinity)
        .background(AskInk.background.ignoresSafeArea(edges: .bottom))
    }

    @ToolbarContentBuilder
    private var closeToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .frame(minWidth: AskSpace.hit, minHeight: AskSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(AskGlyphStyle())
            .accessibilityLabel(AskCopy.close)
        }
    }
}
