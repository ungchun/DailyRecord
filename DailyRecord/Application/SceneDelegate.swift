//
//  SceneDelegate.swift
//  DailyRecord
//
//  Created by Kim SungHun on 5/26/24.
//

import UIKit
import WidgetKit

import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    checkForUpdate()
    
    WidgetCenter.shared.reloadAllTimelines()
    
    if let windowScene = scene as? UIWindowScene {
      if Auth.auth().currentUser == nil {
        self.signInAnonymously(windowScene)
      } else {
        checkUserAgainstDatabase { [weak self] success, error in
          if success {
            self?.signInUser(windowScene)
          } else {
            /// 이미 탈퇴한 유저
            self?.signInAnonymously(windowScene)
          }
        }
      }
    }
  }
  
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
    
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    checkForUpdate()
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    
  }
}

private extension SceneDelegate {
  func signInAnonymously(_ windowScene: UIWindowScene) {
    Auth.auth().signInAnonymously { authResult, error in
      if let error = error {
        Log.error(error)
        return
      }
      
      if let user = authResult?.user {
        do {
          try KeyChainManager.shared.create(account: .uid, data: user.uid)
          UserDefaultsSetting.uid = user.uid
          
          var calendarDIContainer: CalendarDIContainer?
          var calendarCoordinator: CalendarCoordinator?
          let window = UIWindow(windowScene: windowScene)
          self.window = window
          
          self.initDisplayMode(window)
          
          let navigationController = BaseNavigationController()
          self.window?.rootViewController = navigationController
          
          calendarDIContainer = CalendarDIContainer(
            navigationController: navigationController
          )
          calendarCoordinator = calendarDIContainer?.makeCalendarCoordinator()
          calendarCoordinator?.start()
          
          self.window?.makeKeyAndVisible()
        } catch {
          Log.error(error)
          exit(0)
        }
      }
    }
  }
  
  func signInUser(_ windowScene: UIWindowScene) {
    if UserDefaultsSetting.uid.isEmpty {
      do {
        UserDefaultsSetting.uid = try KeyChainManager.shared.read(account: .uid)
      } catch {
        Log.error(error)
      }
    }
    
    var calendarDIContainer: CalendarDIContainer?
    var calendarCoordinator: CalendarCoordinator?
    let window = UIWindow(windowScene: windowScene)
    self.window = window
    
    self.initDisplayMode(window)
    
    let navigationController = BaseNavigationController()
    self.window?.rootViewController = navigationController
    
    calendarDIContainer = CalendarDIContainer(navigationController: navigationController)
    calendarCoordinator = calendarDIContainer?.makeCalendarCoordinator()
    calendarCoordinator?.start()
    
    self.window?.makeKeyAndVisible()
  }
}

private extension SceneDelegate {
  func checkUserAgainstDatabase(completion: @escaping (_ success: Bool,
                                                       _ error: NSError?) -> Void) {
    guard let currentUser = Auth.auth().currentUser else { return }
    currentUser.getIDTokenForcingRefresh(true, completion:  { (idToken, error) in
      if let error = error {
        completion(false, error as NSError?)
        print(error.localizedDescription)
      } else {
        completion(true, nil)
      }
    })
  }
  
  func initDisplayMode(_ window: UIWindow) {
    if UserDefaultsSetting.currentDisplayMode == .system {
      window.overrideUserInterfaceStyle = .unspecified
    } else if UserDefaultsSetting.currentDisplayMode == .light {
      window.overrideUserInterfaceStyle = .light
    } else if UserDefaultsSetting.currentDisplayMode == .dark {
      window.overrideUserInterfaceStyle = .dark
    }
  }
  
  func checkForUpdate() {
    guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
            as? String else { return }
    
    guard let bundleId = Bundle.main.bundleIdentifier,
          let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else {
      return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, error == nil else {
        print("Failed to fetch app info from App Store")
        return
      }
      
      if let json = try? JSONSerialization.jsonObject(with: data,
                                                      options: []) as? [String: Any],
         let results = json["results"] as? [[String: Any]],
         let appStoreVersion = results.first?["version"] as? String {
        DispatchQueue.main.async {
          self.compareVersions(currentVersion: currentVersion,
                               appStoreVersion: appStoreVersion)
        }
      }
    }
    
    task.resume()
  }
  
  func compareVersions(currentVersion: String, appStoreVersion: String) {
    let currentVersionComponents = currentVersion.split(separator: ".").map { Int($0) ?? 0 }
    let appStoreVersionComponents = appStoreVersion.split(separator: ".").map { Int($0) ?? 0 }
    
    if appStoreVersionComponents.count >= 2 {
      if appStoreVersionComponents[0] > currentVersionComponents[0] ||
          (appStoreVersionComponents[0] == currentVersionComponents[0]
           && appStoreVersionComponents[1] > currentVersionComponents[1]) {
        self.showUpdateAlert()
      }
    }
  }
  
  func showUpdateAlert() {
    let alert = UIAlertController(
      title: "업데이트 알림",
      message: "더 나은 서비스를 위해 다온을 업데이트 해주세요!",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "업데이트", style: .default, handler: { _ in
      if let url = URL(string: "https://apps.apple.com/app/6664067346"),
         UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
      }
    }))
    
    if let windowScene = window?.windowScene {
      windowScene.windows.first?.rootViewController?.present(alert,
                                                             animated: true,
                                                             completion: nil)
    }
  }
}
