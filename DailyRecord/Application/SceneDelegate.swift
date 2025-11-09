//
//  SceneDelegate.swift
//  DailyRecord
//
//  Created by Kim SungHun on 5/26/24.
//

import UIKit
import WidgetKit
import LocalAuthentication

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  private var isShowingPasswordScreen = false
  
  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    ShortcutsProvider.updateAppShortcutParameters()
    
    checkForUpdate()
    
    WidgetCenter.shared.reloadAllTimelines()
    
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      self.window = window
      
      self.initDisplayMode(window)
      
      // 비밀번호가 활성화되어 있으면 빈 검은 화면 표시
      if UserDefaultsSetting.isPasswordEnabled {
        let placeholderVC = UIViewController()
        placeholderVC.view.backgroundColor = .azGray50
        self.window?.rootViewController = placeholderVC
        self.window?.makeKeyAndVisible()
        
        // 비밀번호 입력 화면 표시
        checkAndShowPasswordScreen()
      } else {
        // 비밀번호가 없으면 바로 캘린더 화면 시작
        let navigationController = BaseNavigationController()
        self.window?.rootViewController = navigationController
        
        let calendarDIContainer = CalendarDIContainer(navigationController: navigationController)
        let calendarCoordinator = calendarDIContainer.makeCalendarCoordinator()
        calendarCoordinator.start()
        
        self.window?.makeKeyAndVisible()
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
    checkAndShowPasswordScreen()
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    
  }
}

private extension SceneDelegate {
  func checkAndShowPasswordScreen() {
    // 이미 비밀번호 화면이 띄워져 있으면 중복 방지
    guard !isShowingPasswordScreen else { return }
    
    // 비밀번호가 활성화되어 있는지 확인
    guard UserDefaultsSetting.isPasswordEnabled else { return }
    
    isShowingPasswordScreen = true
    
    // 생체 인증이 활성화되어 있으면 생체 인증 시도
    if UserDefaultsSetting.isBiometricEnabled {
      authenticateWithBiometric()
    } else {
      // 생체 인증이 비활성화되어 있으면 비밀번호 입력 화면 표시
      showPasswordInputScreen()
    }
  }
  
  func authenticateWithBiometric() {
    let context = LAContext()
    var error: NSError?
    
    // 생체 인증 사용 가능 여부 확인
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      let reason = L10n.ScreenLock.biometric
      
      context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics, localizedReason: reason
      ) { [weak self] success, error in
        DispatchQueue.main.async {
          guard let self = self else { return }
          
          if success {
            // 생체 인증 성공
            self.handleAuthenticationSuccess()
          } else {
            // 생체 인증 실패 - 비밀번호 입력 화면 표시
            self.showPasswordInputScreen()
          }
        }
      }
    } else {
      // 생체 인증을 사용할 수 없으면 비밀번호 입력 화면 표시
      showPasswordInputScreen()
    }
  }
  
  func showPasswordInputScreen() {
    _ = !(window?.rootViewController is BaseNavigationController)
    
    let passwordVC = PasswordInputViewController(
      mode: .verify, showCloseButton: false
    ) { [weak self] password in
      guard let self = self else { return }
      
      // 저장된 비밀번호와 비교
      do {
        let savedPassword = try KeyChainManager.shared.read(account: .password)
        if savedPassword == password {
          // 비밀번호가 맞으면 화면 닫기
          self.handleAuthenticationSuccess()
        } else {
          // 비밀번호가 틀리면 에러 표시
          if let vc = self.window?.rootViewController?.presentedViewController
              as? PasswordInputViewController {
            vc.showError(L10n.ScreenLock.currentPasswordIncorrect)
          }
        }
      } catch {
        // 에러 발생시 화면 닫기
        self.handleAuthenticationSuccess()
      }
    }
    
    passwordVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
    
    // 약간의 딜레이를 주어 rootViewController가 완전히 설정된 후 present
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      self?.window?.rootViewController?.present(passwordVC, animated: true)
    }
  }
  
  func handleAuthenticationSuccess() {
    let isInitialLaunch = !(window?.rootViewController is BaseNavigationController)
    
    if isInitialLaunch {
      // 앱 실행 시: 캘린더 화면으로 전환
      let navigationController = BaseNavigationController()
      let calendarDIContainer = CalendarDIContainer(navigationController: navigationController)
      let calendarCoordinator = calendarDIContainer.makeCalendarCoordinator()
      calendarCoordinator.start()
      
      self.window?.rootViewController = navigationController
      self.isShowingPasswordScreen = false
    } else {
      // 백그라운드에서 돌아온 경우: 화면만 닫기
      self.window?.rootViewController?.dismiss(animated: true) {
        self.isShowingPasswordScreen = false
      }
    }
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
      title: L10n.Update.title,
      message: L10n.Update.message,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: L10n.Update.action, style: .default, handler: { _ in
      if let url = URL(string: "https://apps.apple.com/app/6664067346"),
         UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
      }
    }))
    
    if let windowScene = window?.windowScene {
      windowScene.windows.first?.rootViewController?.present(
        alert, animated: true, completion: nil
      )
    }
  }
}
