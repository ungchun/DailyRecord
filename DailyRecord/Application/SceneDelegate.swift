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
			
			/**
			 # 자동 로그인 로직 구현하기
			 Auth.auth().currentUser == nil : auth 등록이 안 되어 있거나
			 싱글턴 docID 값이 없을 때 : 가입은 되어 있으나 앱을 다시 깔았을 경우
			 */
			
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
