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
	
	func showCalendar() {
		let calendarDIContainer = DIContainer.makeCalendarDIContainer()
		let calendarCoordinator = calendarDIContainer.makeCalendarCoordinator()
		calendarCoordinator.start()
	}
	
	func dismiss() {
		navigationController.popViewController(animated: true)
	}
}
