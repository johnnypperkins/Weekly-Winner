import Firebase
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseMessaging
import UserNotifications
import FirebaseAnalytics

// Log a test event

import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        Analytics.logEvent("test_event", parameters: [
            "name": "test_name" as NSObject,
            "value": 123 as NSObject
        ])

        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })

        application.registerForRemoteNotifications()

        Messaging.messaging().token { token, error in
            if let error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token {
                print("FCM registration token: \(token)")
            }
        }

        return true
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Oh no! Failed to register for remote notifications with error \(error)")
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var readableToken = ""
        for index in 0 ..< deviceToken.count {
            readableToken += String(format: "%02.2hhx", deviceToken[index] as CVarArg)
        }
        print("Received an APNs device token: \(readableToken)")
    }
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

extension AppDelegate: MessagingDelegate {
    @objc func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase token: \(String(describing: fcmToken))")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .list, .sound]])
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(
            name: Notification.Name("didReceiveRemoteNotification"),
            object: nil,
            userInfo: userInfo
        )
        completionHandler()
    }
}

@main
 struct Weekly_WinnerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            splashScreenView()
            .onAppear() {
                let standardAppearance = UITabBarAppearance()
                standardAppearance.backgroundColor = UIColor(K.finalColor.backgroundBlue)
                let itemAppearance = UITabBarItemAppearance()
                itemAppearance.normal.iconColor = UIColor(Color.white)
                itemAppearance.selected.iconColor = UIColor(K.finalColor.tabSelectedBlue)
                itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.finalUIColor.tabSelectedBlue]
                standardAppearance.inlineLayoutAppearance = itemAppearance
                standardAppearance.stackedLayoutAppearance = itemAppearance
                standardAppearance.compactInlineLayoutAppearance = itemAppearance
                UITabBar.appearance().standardAppearance = standardAppearance
            }
        }
    }
}
