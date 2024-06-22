//
//  SceneDelegate.swift
//  DailyRecord
//
//  Created by Kim SungHun on 5/26/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	var window: UIWindow?
	
	var loginTempValue = false
	
	func scene(_ scene: UIScene,
						 willConnectTo session: UISceneSession,
						 options connectionOptions: UIScene.ConnectionOptions) {
		if let windowScene = scene as? UIWindowScene {
			
			if loginTempValue {
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
			} else {
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
