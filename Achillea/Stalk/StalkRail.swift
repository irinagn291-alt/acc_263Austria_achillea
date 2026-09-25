import SpriteKit
import SwiftUI

/// Role: Stalk. Numeric rail with one SpriteKit milfoil accent. Name count, stalk sum, gage state. No second SpriteKit surface.
struct StalkRail: View {
    var ask: Ask
    var reduceMotion: Bool
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        HStack(alignment: .center, spacing: AskSpace.card) {
            StalkGlowView(fold: ask.fold, reduceMotion: reduceMotion)
                .frame(width: AskSpace.step(7), height: AskSpace.step(7))
                .accessibilityHidden(true)
            HStack(alignment: .bottom, spacing: AskSpace.card) {
                railFigure(
                    value: AskFigures.integer(ask.railNameCount),
                    caption: AskCopy.namesCaption
                )
                railFigure(
                    value: AskCopy.chanceWord(on: ask),
                    caption: AskCopy.chanceCaption
                )
                railFigure(
                    value: AskCopy.foldWord(ask.fold),
                    caption: AskCopy.statusCaption
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AskSpace.card)
        .background {
            Image(AskArt.cardBackdrop)
                .resizable()
                .scaledToFill()
                .clipped()
                .opacity(0.28)
                .accessibilityHidden(true)
        }
        .askSurface()
        .clipped()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(railVoice)
    }

    private var railVoice: String {
        "\(AskCopy.namesCaption) \(AskFigures.integer(ask.railNameCount)), \(AskCopy.chanceCaption) \(AskCopy.chanceWord(on: ask)), \(AskCopy.statusCaption) \(AskCopy.foldWord(ask.fold))"
    }

    private func railFigure(value: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: AskSpace.inner) {
            Text(value)
                .font(AskType.rail)
                .foregroundStyle(AskInk.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(caption)
                .font(AskType.font(.micro, size: typeSize))
                .foregroundStyle(AskInk.muted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Role: Stalk. One glowing milfoil accent. Reduce Motion holds the group still.
struct StalkGlowView: UIViewRepresentable {
    var fold: AskFold
    var reduceMotion: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.allowsTransparency = true
        view.backgroundColor = .clear
        view.isAccessibilityElement = false
        view.accessibilityElementsHidden = true
        view.presentScene(context.coordinator.scene)
        context.coordinator.scene.apply(fold: fold, reduceMotion: reduceMotion)
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {
        view.isPaused = reduceMotion
        view.preferredFramesPerSecond = reduceMotion ? 1 : 30
        context.coordinator.scene.apply(fold: fold, reduceMotion: reduceMotion)
    }

    @MainActor
    final class Coordinator {
        let scene: StalkGlowScene

        init() {
            scene = StalkGlowScene()
        }
    }
}

/// Role: Stalk. Glowing milfoil lines. Fold changes the clip, never colour alone.
@MainActor
final class StalkGlowScene: SKScene {
    private var fold: AskFold = .idle
    private var reduceMotion = false

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        rebuild()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        rebuild()
    }

    func apply(fold: AskFold, reduceMotion: Bool) {
        let changed = self.fold != fold || self.reduceMotion != reduceMotion
        self.fold = fold
        self.reduceMotion = reduceMotion
        if changed || children.isEmpty {
            rebuild()
        }
    }

    private func rebuild() {
        removeAllChildren()
        guard size.width > 1, size.height > 1 else { return }
        let origin = CGPoint(x: size.width * 0.5, y: size.height * 0.18)
        let count = 7
        let span = CGFloat.pi * 0.72
        let start = (CGFloat.pi / 2) - (span / 2)
        let length: CGFloat
        switch fold {
        case .idle:
            length = min(size.width, size.height) * 0.72
        case .gaged:
            length = min(size.width, size.height) * 0.52
        case .filed:
            length = min(size.width, size.height) * 0.42
        }
        let stroke = AskPaint.accent
        for index in 0 ..< count {
            let angle = start + span * CGFloat(index) / CGFloat(max(count - 1, 1))
            let path = CGMutablePath()
            path.move(to: origin)
            let end = CGPoint(
                x: origin.x + cos(angle) * length,
                y: origin.y + sin(angle) * length
            )
            path.addLine(to: end)
            let node = SKShapeNode(path: path)
            node.strokeColor = stroke
            node.lineWidth = fold == .filed ? 2.4 : 1.6
            node.glowWidth = reduceMotion ? 2 : 6
            node.lineCap = .round
            node.fillColor = .clear
            addChild(node)
            if reduceMotion == false {
                let pulse = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.45, duration: 0.9),
                    SKAction.fadeAlpha(to: 1, duration: 0.9),
                ])
                node.run(SKAction.repeatForever(pulse))
            }
        }
        if fold == .gaged {
            let bar = SKShapeNode(
                rectOf: CGSize(width: size.width * 0.62, height: 3),
                cornerRadius: 1.5
            )
            bar.fillColor = stroke
            bar.strokeColor = .clear
            bar.position = CGPoint(x: size.width * 0.5, y: origin.y + length + 4)
            addChild(bar)
        }
        if fold == .filed {
            let slip = SKShapeNode(
                rectOf: CGSize(width: size.width * 0.34, height: size.height * 0.18),
                cornerRadius: 3
            )
            slip.fillColor = stroke.withAlphaComponent(0.35)
            slip.strokeColor = stroke
            slip.lineWidth = 1
            slip.position = CGPoint(x: size.width * 0.5, y: size.height * 0.72)
            addChild(slip)
        }
    }
}
