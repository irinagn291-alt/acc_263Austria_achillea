import UIKit
import Alamofire
import OneSignalFramework

final class AppDelegate: NSObject, UIApplicationDelegate {
    private static let bind = "com.achillea.ask"

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        _ = Self.bind
        APIConfig.apply()
        OneSignal.initialize("f12d4964-5688-476a-988d-3a0906ceb3e9", withLaunchOptions: launchOptions)
        OneSignal.Notifications.requestPermission({ @Sendable _ in }, fallbackToSettings: false)
        application.registerForRemoteNotifications()
        return true
    }
}
