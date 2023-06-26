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
            ContentView()
        }
    }
}
