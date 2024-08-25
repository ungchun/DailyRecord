//
//  SceneDelegate.swift
//  DailyRecord
//
//  Created by Kim SungHun on 5/26/24.
//

import UIKit

import FirebaseAuth
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	var window: UIWindow?
	
	func scene(_ scene: UIScene,
						 willConnectTo session: UISceneSession,
						 options connectionOptions: UIScene.ConnectionOptions) {
		if let windowScene = scene as? UIWindowScene {
			if Auth.auth().currentUser == nil {
				Auth.auth().signInAnonymously { authResult, error in
					if let error = error {
						Log.error(error)
						return
					}
					
					if let user = authResult?.user {
						do {
							try KeyChainManager.shared.create(account: .uid, data: user.uid)
							UserDefaultsSetting.isAnonymously = true
							
							var calendarDIContainer: CalendarDIContainer?
							var calendarCoordinator: CalendarCoordinator?
							let window = UIWindow(windowScene: windowScene)
							self.window = window
							
							if UserDefaultsSetting.currentDisplayMode == .system {
								window.overrideUserInterfaceStyle = .unspecified
							} else if UserDefaultsSetting.currentDisplayMode == .light {
								window.overrideUserInterfaceStyle = .light
							} else if UserDefaultsSetting.currentDisplayMode == .dark {
								window.overrideUserInterfaceStyle = .dark
							}
							
							let navigationController = BaseNavigationController()
							self.window?.rootViewController = navigationController
							
							calendarDIContainer = CalendarDIContainer(navigationController: navigationController)
							calendarCoordinator = calendarDIContainer?.makeCalendarCoordinator()
							calendarCoordinator?.start()
							
							self.window?.makeKeyAndVisible()
						} catch {
							Log.error(error)
							exit(0)
						}
					}
				}
			} else {
				var calendarDIContainer: CalendarDIContainer?
				var calendarCoordinator: CalendarCoordinator?
				let window = UIWindow(windowScene: windowScene)
				self.window = window
				
				if UserDefaultsSetting.currentDisplayMode == .system {
					window.overrideUserInterfaceStyle = .unspecified
				} else if UserDefaultsSetting.currentDisplayMode == .light {
					window.overrideUserInterfaceStyle = .light
				} else if UserDefaultsSetting.currentDisplayMode == .dark {
					window.overrideUserInterfaceStyle = .dark
				}
				
				let navigationController = BaseNavigationController()
				self.window?.rootViewController = navigationController
				
				calendarDIContainer = CalendarDIContainer(navigationController: navigationController)
				calendarCoordinator = calendarDIContainer?.makeCalendarCoordinator()
				calendarCoordinator?.start()
				
				self.window?.makeKeyAndVisible()
			}
		}
	}
	
	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		if let url = URLContexts.first?.url {
			if (AuthApi.isKakaoTalkLoginUrl(url)) {
				_ = AuthController.handleOpenUrl(url: url)
			}
		}
	}
	
	func sceneDidDisconnect(_ scene: UIScene) {
		
	}
	
	func sceneDidBecomeActive(_ scene: UIScene) {
		
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		
	}
	
	func sceneWillEnterForeground(_ scene: UIScene) {
		
	}
	
	func sceneDidEnterBackground(_ scene: UIScene) {
		
	}
}
