//
//  Weekly_WinnerApp.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import FirebaseCore

// Reid Was Here -- Test 2 -- Test 3
// Reid was here again 06/26/23

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
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
