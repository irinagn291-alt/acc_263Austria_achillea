import SwiftUI

/// Role: Ask. Stagger 50ms, cap 360ms. Reduce Motion fades the group at once.
enum AskSnap {
    static let pressScale: CGFloat = 0.97
    static let duration: Double = 0.24
    static let fade: Double = 0.16
    static let stagger: Double = 0.05
    static let staggerCap: Double = 0.36
}

enum AskMotion {
    static func snap(_ reduceMotion: Bool) -> Animation {
        .easeOut(duration: reduceMotion ? AskSnap.fade : AskSnap.duration)
    }

    static func pressScale(_ reduceMotion: Bool) -> CGFloat {
        reduceMotion ? 1 : AskSnap.pressScale
    }

    static func staggerDelay(index: Int, reduceMotion: Bool) -> Double {
        if reduceMotion { return 0 }
        return min(Double(index) * AskSnap.stagger, AskSnap.staggerCap)
    }
}

/// Role: Ask. Grouped reveal. Reduce Motion shows the group at once with a fade.
struct AskReveal: ViewModifier {
    let index: Int
    let reduceMotion: Bool
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown || reduceMotion ? 0 : AskSpace.inner)
            .onAppear {
                if reduceMotion {
                    withAnimation(.easeOut(duration: AskSnap.fade)) {
                        shown = true
                    }
                    return
                }
                let delay = AskMotion.staggerDelay(index: index, reduceMotion: false)
                withAnimation(.easeOut(duration: AskSnap.duration).delay(delay)) {
                    shown = true
                }
            }
    }
}

extension View {
    func askReveal(index: Int, reduceMotion: Bool) -> some View {
        modifier(AskReveal(index: index, reduceMotion: reduceMotion))
    }

    func askHit() -> some View {
        frame(minWidth: AskSpace.hit, minHeight: AskSpace.hit)
            .contentShape(Rectangle())
    }

    func askSurface() -> some View {
        background(
            AskInk.surface,
            in: RoundedRectangle(cornerRadius: AskRadius.card, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AskRadius.card, style: .continuous)
                .stroke(AskInk.muted.opacity(0.35), lineWidth: AskRadius.hairline)
        )
    }
}

extension Image {
    func askCutout(maxWidth: CGFloat? = .infinity, maxHeight: CGFloat) -> some View {
        resizable()
            .scaledToFit()
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
            .clipped()
            .accessibilityHidden(true)
    }
}
