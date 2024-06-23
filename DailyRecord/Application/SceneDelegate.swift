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
				// 로그인 뷰
				var loginDIContainer: LoginDIContainer?
				var loginCoordinator: LoginCoordinator?
				let window = UIWindow(windowScene: windowScene)
				self.window = window
				
				let navigationController = UINavigationController()
				self.window?.rootViewController = navigationController
				
				loginDIContainer = LoginDIContainer(navigationController: navigationController)
				loginCoordinator = loginDIContainer?.makeLoginCoordinator()
				loginCoordinator?.start()
				
				self.window?.makeKeyAndVisible()
			} else {
				// 캘린더 뷰
				var calenderDIContainer: CalenderDIContainer?
				var calenderCoordinator: CalenderCoordinator?
				let window = UIWindow(windowScene: windowScene)
				self.window = window
				
				let navigationController = UINavigationController()
				self.window?.rootViewController = navigationController
				
				calenderDIContainer = CalenderDIContainer(navigationController: navigationController)
				calenderCoordinator = calenderDIContainer?.makeCalenderCoordinator()
				calenderCoordinator?.start()
				
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
