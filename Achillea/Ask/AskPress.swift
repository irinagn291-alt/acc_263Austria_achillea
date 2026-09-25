import SwiftUI

/// Role: Ask. One ButtonStyle for Gage and Draw. Default, pressed, disabled, loading. Retract does not wear this accent.
struct AskVerbStyle: ButtonStyle {
    var emphasized: Bool = true
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        AskVerbBody(configuration: configuration, emphasized: emphasized, isLoading: isLoading)
    }
}

private struct AskVerbBody: View {
    let configuration: ButtonStyle.Configuration
    let emphasized: Bool
    let isLoading: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let pressed = configuration.isPressed
        HStack(spacing: AskSpace.inner) {
            if isLoading {
                ProgressView()
                    .tint(labelInk)
            }
            configuration.label
        }
        .font(AskType.font(.headline, size: typeSize))
        .foregroundStyle(labelInk)
        .frame(maxWidth: .infinity)
        .frame(minHeight: AskSpace.hit)
        .padding(.horizontal, AskSpace.card)
        .background(
            fill,
            in: RoundedRectangle(cornerRadius: AskRadius.card, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AskRadius.card, style: .continuous)
                .stroke(
                    isFocused ? AskInk.ink : AskInk.muted.opacity(emphasized ? 0 : 0.35),
                    lineWidth: isFocused ? 2 : AskRadius.hairline
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: AskRadius.card, style: .continuous))
        .scaleEffect(pressed && isEnabled ? AskMotion.pressScale(reduceMotion) : 1)
        .opacity(visualOpacity(pressed: pressed))
        .animation(AskMotion.snap(reduceMotion), value: pressed)
        .animation(AskMotion.snap(reduceMotion), value: isEnabled)
        .animation(AskMotion.snap(reduceMotion), value: isLoading)
        .animation(AskMotion.snap(reduceMotion), value: isFocused)
    }

    private var fill: Color {
        if !isEnabled {
            return AskInk.muted.opacity(0.28)
        }
        return emphasized ? AskInk.accent : AskInk.surface
    }

    private var labelInk: Color {
        if !isEnabled {
            return AskInk.ink.opacity(0.7)
        }
        return emphasized ? AskInk.background : AskInk.ink
    }

    private func visualOpacity(pressed: Bool) -> Double {
        if !isEnabled { return 0.55 }
        if isLoading { return 0.7 }
        if pressed { return 0.88 }
        return 1
    }
}

/// Role: Ask. Quiet chrome and Retract. Never the live-verb accent.
struct AskQuietStyle: ButtonStyle {
    var destructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        AskQuietBody(configuration: configuration, destructive: destructive)
    }
}

private struct AskQuietBody: View {
    let configuration: ButtonStyle.Configuration
    let destructive: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let pressed = configuration.isPressed
        configuration.label
            .font(AskType.font(.headline, size: typeSize))
            .foregroundStyle(AskInk.ink)
            .frame(maxWidth: .infinity)
            .frame(minHeight: AskSpace.hit)
            .padding(.horizontal, AskSpace.card)
            .background(
                AskInk.surface,
                in: RoundedRectangle(cornerRadius: AskRadius.card, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AskRadius.card, style: .continuous)
                    .stroke(
                        isFocused ? AskInk.ink : AskInk.muted.opacity(0.35),
                        lineWidth: isFocused ? 2 : AskRadius.hairline
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: AskRadius.card, style: .continuous))
            .scaleEffect(pressed && isEnabled ? AskMotion.pressScale(reduceMotion) : 1)
            .opacity(quietOpacity(pressed: pressed))
            .animation(AskMotion.snap(reduceMotion), value: pressed)
            .animation(AskMotion.snap(reduceMotion), value: isEnabled)
    }

    private func quietOpacity(pressed: Bool) -> Double {
        if !isEnabled { return 0.45 }
        if pressed { return 0.88 }
        return destructive ? 0.92 : 1
    }
}

/// Role: Ask. Icon-only chrome. Hit the whole 44pt tile.
struct AskGlyphStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        AskGlyphBody(configuration: configuration)
    }
}

private struct AskGlyphBody: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        configuration.label
            .frame(minWidth: AskSpace.hit, minHeight: AskSpace.hit)
            .background(
                AskInk.surface,
                in: RoundedRectangle(cornerRadius: AskRadius.chip, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AskRadius.chip, style: .continuous)
                    .stroke(
                        isFocused ? AskInk.ink : AskInk.muted.opacity(0.35),
                        lineWidth: isFocused ? 2 : AskRadius.hairline
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: AskRadius.chip, style: .continuous))
            .scaleEffect(pressed && isEnabled ? AskMotion.pressScale(reduceMotion) : 1)
            .opacity(!isEnabled ? 0.42 : (pressed ? 0.88 : 1))
            .animation(AskMotion.snap(reduceMotion), value: pressed)
            .animation(AskMotion.snap(reduceMotion), value: isEnabled)
    }
}

/// Role: Ask. Sheet fade. Reduce Motion is opacity only.
struct AskSheetHost<Content: View>: View {
    @ViewBuilder var content: Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(AskInk.background.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .tint(AskInk.accent)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(AskMotion.snap(reduceMotion)) {
                    appeared = true
                }
            }
    }
}

/// Role: Ask. Full-page empty or error. Cutout, one headline, one line, bottom full-width CTA.
struct AskQuietPage: View {
    let art: String
    let headline: String
    let line: String
    let actionTitle: String
    var isLoading: Bool = false
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: AskSpace.card) {
            ViewThatFits(in: .vertical) {
                copyStack(showsSpacer: true)
                ScrollView {
                    copyStack(showsSpacer: false)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            Button(actionTitle, action: action)
                .buttonStyle(AskVerbStyle(emphasized: true, isLoading: isLoading))
                .askHit()
        }
        .padding(.horizontal, AskSpace.outer)
        .padding(.top, AskSpace.card)
        .padding(.bottom, AskSpace.outer)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(AskInk.background)
    }

    private func copyStack(showsSpacer: Bool) -> some View {
        VStack(alignment: .leading, spacing: AskSpace.card) {
            Image(art)
                .askCutout(maxHeight: AskSpace.step(22))
            Text(headline)
                .font(AskType.font(.display, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .lineLimit(3)
            Text(line)
                .font(AskType.font(.body, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .lineLimit(4)
            if showsSpacer {
                Spacer(minLength: AskSpace.inner)
            }
        }
    }
}

/// Role: Ask. Calm error with Retry. Hairline, not a tinted bar.
struct AskNotice: View {
    let message: String
    var retryTitle: String = AskCopy.retry
    var retry: (() -> Void)?
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        HStack(alignment: .center, spacing: AskSpace.inner) {
            Text(message)
                .font(AskType.font(.caption, size: typeSize))
                .foregroundStyle(AskInk.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let retry {
                Button(retryTitle, action: retry)
                    .font(AskType.font(.caption, size: typeSize))
                    .foregroundStyle(AskInk.ink)
                    .askHit()
                    .buttonStyle(AskGlyphStyle())
                    .accessibilityLabel(retryTitle)
            }
        }
        .padding(AskSpace.card)
        .askSurface()
    }
}
