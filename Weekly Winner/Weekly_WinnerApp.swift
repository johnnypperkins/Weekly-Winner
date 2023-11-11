//
//  Weekly_WinnerApp.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Firebase
import FirebaseMessaging

// Reid Was Here -- Test 2 -- Test 3
// Reid was here again 06/26/23

class AppDelegate: NSObject, UIApplicationDelegate {
  
  let gcmMessageIDKey = "gcm.message_id"
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    print("hereeeeeeeee")
    FirebaseApp.configure()
      
      // Messaging Delegate
      
      Messaging.messaging().delegate = self
    
    // Push Notifications
    
    if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      UNUserNotificationCenter.current().delegate = self
      
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
      UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
      
      Messaging.messaging().isAutoInitEnabled = true

    
    return true
  }
  
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {

      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
       Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      //print(userInfo)

      return UIBackgroundFetchResult.newData
    }

  
  
}


//Cloude Messaging
extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        
        print("FCM Token")
        print(dataDict)
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                              -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // ...

    // Print full message.
    //print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([[.badge, .sound]])
  }


}


//extension AppDelegate : UNUserNotificationCenterDelegate {
//
//      // Receive displayed notifications for iOS 10 devices.
//      func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                  willPresent notification: UNNotification) async
//        -> UNNotificationPresentationOptions {
//        let userInfo = notification.request.content.userInfo
//
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//        // ...
//
//        // Print full message.
//        print(userInfo)
//
//        // Change this to your preferred presentation option
//        return [[.alert, .sound]]
//      }
//
//      func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                  didReceive response: UNNotificationResponse) async {
//        let userInfo = response.notification.request.content.userInfo
//
//        // ...
//
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//        // Print full message.
//        print(userInfo)
//      }
//
//    func application(_ application: UIApplication,
//                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
//      -> UIBackgroundFetchResult {
//      // If you are receiving a notification message while your app is in the background,
//      // this callback will not be fired till the user taps on the notification launching the application.
//      // TODO: Handle data of notification
//
//      // With swizzling disabled you must let Messaging know about the message, for Analytics
//      // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//      // Print message ID.
//      if let messageID = userInfo[gcmMessageIDKey] {
//        print("Message ID: \(messageID)")
//      }
//
//      // Print full message.
//      print(userInfo)
//
//      return UIBackgroundFetchResult.newData
//    }
//
//}

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
