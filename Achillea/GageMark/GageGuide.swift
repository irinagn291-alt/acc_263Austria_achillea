import SwiftUI

/// Role: GageMark. Twist screen for gage-then-draw. Home keeps a surface. This sheet is the dedicated page.
struct GageGuide: View {
    @Bindable var desk: AskDesk
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        AskSheetHost {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: AskSpace.card) {
                        Image(AskArt.twistHero)
                            .askCutout(maxHeight: AskSpace.step(22))
                        Text(AskCopy.twistHeadline)
                            .font(AskType.font(.display, size: typeSize))
                            .foregroundStyle(AskInk.ink)
                            .lineLimit(3)
                        Text(AskCopy.twistBody)
                            .font(AskType.font(.body, size: typeSize))
                            .foregroundStyle(AskInk.ink)
                        Text(AskCopy.twistDispute)
                            .font(AskType.font(.body, size: typeSize))
                            .foregroundStyle(AskInk.ink)
                        VStack(alignment: .leading, spacing: AskSpace.inner) {
                            Text(AskCopy.foldWord(desk.ask.fold))
                                .font(AskType.font(.title, size: typeSize))
                                .foregroundStyle(AskInk.ink)
                                .lineLimit(1)
                            Text(AskCopy.job(on: desk.ask))
                                .font(AskType.font(.body, size: typeSize))
                                .foregroundStyle(AskInk.muted)
                                .lineLimit(3)
                        }
                        .padding(AskSpace.card)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .askSurface()
                        .askReveal(index: 1, reduceMotion: reduceMotion)
                        if let fault = desk.fault {
                            AskNotice(message: fault) {
                                Task { await desk.retryLoad() }
                            }
                        }
                    }
                    .padding(AskSpace.outer)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollDismissesKeyboard(.interactively)
                .background(AskInk.background.ignoresSafeArea())
                .navigationTitle(AskCopy.twistTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { closeToolbar }
                .safeAreaInset(edge: .bottom) {
                    Button(AskCopy.historyEmptyAction) {
                        dismiss()
                    }
                    .buttonStyle(AskVerbStyle(emphasized: true, isLoading: false))
                    .padding(.horizontal, AskSpace.outer)
                    .padding(.bottom, AskSpace.outer)
                    .background(AskInk.background)
                }
            }
        }
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
