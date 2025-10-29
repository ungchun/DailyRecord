//
//  AppDelegate.swift
//  DailyRecord
//
//  Created by Kim SungHun on 5/26/24.
//

import UIKit

import AmplitudeSwift
import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    Amp.configure(apiKey: "a94605679e0892a6387c7a7657c4a1c4")
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration",
                                sessionRole: connectingSceneSession.role)
  }
  
  func application(
    _ application: UIApplication,
    didDiscardSceneSessions sceneSessions: Set<UISceneSession>
  ) {
    
  }
}
