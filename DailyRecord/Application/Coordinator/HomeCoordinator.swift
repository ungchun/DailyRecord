//
//  HomeCoordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import UIKit

final class HomeCoordinator: Coordinator {
	var DIContainer: HomeDIContainer
	private var navigationController: UINavigationController
	
	init(DIContainer: HomeDIContainer,
			 navigationController: UINavigationController) {
		self.DIContainer = DIContainer
		self.navigationController = navigationController
	}
}

extension HomeCoordinator {
	func start() {
		startHome()
	}
	
	func startHome() {
		let homeViewController = DIContainer.makeHomeViewController()
		homeViewController.coordinator = self
		self.navigationController.viewControllers = [homeViewController]
	}
}
