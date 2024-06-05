//
//  CalenderCoordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import UIKit

final class CalenderCoordinator: Coordinator {
	var DIContainer: CalenderDIContainer
	private var navigationController: UINavigationController
	
	init(DIContainer: CalenderDIContainer,
			 navigationController: UINavigationController) {
		self.DIContainer = DIContainer
		self.navigationController = navigationController
	}
}

extension CalenderCoordinator {
	func start() {
		startCalender()
	}
	
	func startCalender() {
		let calenderViewController = DIContainer.makeCalenderViewController()
		calenderViewController.coordinator = self
		self.navigationController.viewControllers = [calenderViewController]
	}
}
