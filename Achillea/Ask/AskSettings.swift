import SwiftUI

/// Role: Ask. Settings sheet. How Draw picks, contact URL, re-run onboarding, confirmed reset. Empty, populated, and error.
struct SettingsView: View {
    @Bindable var desk: AskDesk
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var confirmReset = false

    var body: some View {
        AskSheetHost {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: AskSpace.card) {
                        if let fault = desk.fault {
                            AskNotice(message: fault) {
                                Task { await desk.retryLoad() }
                            }
                        }
                        if desk.settingsIsEmpty {
                            inviteCard
                        }
                        generatorCard
                        contactCard
                        Button(AskCopy.openTwist) {
                            desk.present(.twist)
                        }
                        .buttonStyle(AskQuietStyle())
                        Button(AskCopy.replayOnboarding) {
                            desk.replayOnboarding()
                        }
                        .buttonStyle(AskQuietStyle())
                        Button(AskCopy.resetTitle) {
                            confirmReset = true
                        }
                        .buttonStyle(AskQuietStyle(destructive: true))
                    }
                    .padding(.horizontal, AskSpace.outer)
                    .padding(.top, AskSpace.card)
                    .padding(.bottom, AskSpace.outer)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollDismissesKeyboard(.interactively)
                .background(AskInk.background.ignoresSafeArea())
                .navigationTitle(AskCopy.settingsTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { closeToolbar }
                .confirmationDialog(
                    AskCopy.resetConfirm,
                    isPresented: $confirmReset,
                    titleVisibility: .visible
                ) {
                    Button(AskCopy.resetAction, role: .destructive) {
                        Task { await desk.resetAllData() }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text(AskCopy.resetMessage)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var inviteCard: some View {
        VStack(alignment: .leading, spacing: AskSpace.inner) {
            Text(AskCopy.settingsEmptyHeadline)
                .font(AskType.font(.headline, size: typeSize))
                .foregroundStyle(AskInk.ink)
            Text(AskCopy.settingsEmptyLine)
                .font(AskType.font(.caption, size: typeSize))
                .foregroundStyle(AskInk.muted)
            Button(AskCopy.historyEmptyAction) {
                dismiss()
            }
            .buttonStyle(AskVerbStyle(emphasized: true, isLoading: false))
        }
        .padding(AskSpace.card)
        .askSurface()
    }

    private var generatorCard: some View {
        VStack(alignment: .leading, spacing: AskSpace.card) {
            Text(AskCopy.generatorTitle)
                .font(AskType.font(.title, size: typeSize))
                .foregroundStyle(AskInk.ink)
            Text(AskCopy.generatorBody)
                .font(AskType.font(.body, size: typeSize))
                .foregroundStyle(AskInk.ink)
            HStack(spacing: AskSpace.card) {
                countTile(title: AskCopy.namesCaption, value: desk.ask.railNameCount)
                countTile(title: AskCopy.historyTitle, value: desk.ask.slips.count)
            }
        }
        .padding(AskSpace.card)
        .askSurface()
    }

    private var contactCard: some View {
        Button {
            openURL(AskCourier.contactURL)
        } label: {
            VStack(alignment: .leading, spacing: AskSpace.inner) {
                Text(AskCopy.contactTitle)
                    .font(AskType.font(.headline, size: typeSize))
                    .foregroundStyle(AskInk.ink)
                Text(AskCopy.contactDetail)
                    .font(AskType.font(.caption, size: typeSize))
                    .foregroundStyle(AskInk.muted)
            }
            .frame(maxWidth: .infinity, minHeight: AskSpace.hit, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(AskQuietStyle())
        .accessibilityLabel(AskCopy.contactTitle)
    }

    private func countTile(title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: AskSpace.inner) {
            Text(AskFigures.integer(value))
                .font(AskType.rail)
                .foregroundStyle(AskInk.ink)
                .lineLimit(1)
            Text(title)
                .font(AskType.font(.micro, size: typeSize))
                .foregroundStyle(AskInk.muted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
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
