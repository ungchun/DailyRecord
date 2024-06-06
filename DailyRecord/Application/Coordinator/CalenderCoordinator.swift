//
//  CalenderCoordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import UIKit

final class CalenderCoordinator: Coordinator {
	private let navigationController: UINavigationController
	
	let DIContainer: CalenderDIContainer
	
	init(DIContainer: CalenderDIContainer,
			 navigationController: UINavigationController) {
		self.DIContainer = DIContainer
		self.navigationController = navigationController
	}
}

extension CalenderCoordinator {
	func start() {
		let calenderViewController = DIContainer.makeCalenderViewController()
		calenderViewController.coordinator = self
		self.navigationController.viewControllers = [calenderViewController]
	}
	
	func showRecord() {
		let recordDIContainer = DIContainer.makeRecordDIContainer()
		let recordCoordinator = recordDIContainer.makeRecordCoordinator()
		recordCoordinator.start()
	}
	
	func dismiss() {
		navigationController.popViewController(animated: true)
	}
}
