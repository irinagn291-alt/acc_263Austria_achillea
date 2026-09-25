import SwiftUI
import UIKit

/// Role: Ask. Root shell. Onboarding cover, then the locked ask. ReviewScreen is applied after onboarding.
struct ContentView: View {
    @State private var desk: AskDesk
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(desk: AskDesk = AskDesk.live()) {
        _desk = State(wrappedValue: desk)
    }

    var body: some View {
        ZStack {
            AskInk.background.ignoresSafeArea()
            if desk.isBooting {
                Image(AskArt.splash)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            } else if desk.showsOnboarding {
                AskOnboarding(
                    onSkip: { Task { await desk.finishOnboarding() } },
                    onFinish: { Task { await desk.finishOnboarding() } }
                )
            } else {
                AskRoot(desk: desk)
            }
        }
        .preferredColorScheme(.dark)
        .tint(AskInk.accent)
        .animation(AskMotion.snap(reduceMotion), value: desk.showsOnboarding)
        .animation(AskMotion.snap(reduceMotion), value: desk.isBooting)
        .task { await desk.boot() }
        .onChange(of: scenePhase) { _, phase in
            Task { await desk.handle(phase: phase) }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)
        ) { _ in
            Task { await desk.noteCalendarShift() }
        }
    }
}

#Preview {
    ContentView()
}
