//
//  LoginCoordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/22/24.
//

import UIKit

final class LoginCoordinator: Coordinator {
	private let navigationController: UINavigationController
	
	let DIContainer: LoginDIContainer
	
	init(DIContainer: LoginDIContainer,
			 navigationController: UINavigationController) {
		self.DIContainer = DIContainer
		self.navigationController = navigationController
	}
}

extension LoginCoordinator {
	func start() {
		let loginViewController = DIContainer.makeLoginViewController()
		loginViewController.coordinator = self
		self.navigationController.viewControllers = [loginViewController]
	}
	
	func showCalender() {
		let calenderDIContainer = DIContainer.makeCalenderDIContainer()
		let calenderCoordinator = calenderDIContainer.makeCalenderCoordinator()
		calenderCoordinator.start()
	}
	
	func dismiss() {
		navigationController.popViewController(animated: true)
	}
}
