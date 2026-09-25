import SwiftUI

/// Role: Ask. One-shot cover. Four pages. Continue full width at the bottom. Skip writes defaults. Re-runnable from Settings.
struct AskOnboarding: View {
    var onSkip: () -> Void
    var onFinish: () -> Void
    @State private var page = 0
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let lastPage = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                if page < lastPage {
                    Button(AskCopy.skip, action: onSkip)
                        .font(AskType.font(.caption, size: typeSize))
                        .foregroundStyle(AskInk.ink)
                        .askHit()
                        .buttonStyle(AskGlyphStyle())
                        .accessibilityLabel(AskCopy.skip)
                }
            }
            .padding(.horizontal, AskSpace.outer)

            ViewThatFits(in: .vertical) {
                pageSwitch(showsSpacer: true)
                ScrollView {
                    pageSwitch(showsSpacer: false)
                }
                .scrollIndicators(.hidden)
            }
            .id(page)
            .animation(AskMotion.snap(reduceMotion), value: page)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            HStack(spacing: AskSpace.inner) {
                ForEach(0 ... lastPage, id: \.self) { index in
                    RoundedRectangle(cornerRadius: AskRadius.chip, style: .continuous)
                        .fill(index == page ? AskInk.accent : AskInk.surface)
                        .frame(
                            width: index == page ? AskSpace.step(3) : AskSpace.inner,
                            height: AskSpace.inner
                        )
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, AskSpace.outer)
            .padding(.bottom, AskSpace.inner)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                "Page \(AskFigures.integer(page + 1)) of \(AskFigures.integer(lastPage + 1))"
            )

            Button(page < lastPage ? AskCopy.continueVerb : AskCopy.beginVerb) {
                if page < lastPage {
                    page += 1
                } else {
                    onFinish()
                }
            }
            .buttonStyle(AskVerbStyle(emphasized: true, isLoading: false))
            .padding(.horizontal, AskSpace.outer)
            .padding(.bottom, AskSpace.outer)
        }
        .background(AskInk.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func pageSwitch(showsSpacer: Bool) -> some View {
        switch page {
        case 0:
            pageBody(
                art: AskArt.onboarding1,
                headline: AskCopy.onboarding1Headline,
                line: AskCopy.onboarding1Line,
                showsSpacer: showsSpacer
            )
        case 1:
            pageBody(
                art: AskArt.onboarding2,
                headline: AskCopy.onboarding2Headline,
                line: AskCopy.onboarding2Line,
                showsSpacer: showsSpacer
            )
        case 2:
            pageBody(
                art: AskArt.onboarding3,
                headline: AskCopy.onboarding3Headline,
                line: AskCopy.onboarding3Line,
                showsSpacer: showsSpacer
            )
        default:
            pageBody(
                art: AskArt.twistHero,
                headline: AskCopy.onboarding4Headline,
                line: AskCopy.onboarding4Line,
                showsSpacer: showsSpacer
            )
        }
    }

    private func pageBody(art: String, headline: String, line: String, showsSpacer: Bool) -> some View {
        VStack(alignment: .leading, spacing: AskSpace.card) {
            Image(art)
                .askCutout(maxHeight: AskSpace.step(28))
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
        .padding(.horizontal, AskSpace.outer)
        .padding(.top, AskSpace.card)
    }
}
