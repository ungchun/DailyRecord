//
//  CalendarCoordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import UIKit

final class CalendarCoordinator: Coordinator {
	private let navigationController: UINavigationController
	
	let DIContainer: CalendarDIContainer
	
	init(DIContainer: CalendarDIContainer,
			 navigationController: UINavigationController) {
		self.DIContainer = DIContainer
		self.navigationController = navigationController
	}
}

extension CalendarCoordinator {
	func start() {
		let calendarViewController = DIContainer.makeCalendarViewController()
		calendarViewController.coordinator = self
		self.navigationController.viewControllers = [calendarViewController]
	}
	
	func showRecord(selectDate: Date) {
		let recordDIContainer = DIContainer.makeRecordDIContainer(selectDate: selectDate)
		let recordCoordinator = recordDIContainer.makeRecordCoordinator()
		recordCoordinator.start()
	}
	
	func dismiss() {
		navigationController.popViewController(animated: true)
	}
}
