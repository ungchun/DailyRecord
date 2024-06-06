//
//  RecordCoordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/6/24.
//

import UIKit

final class RecordCoordinator: Coordinator {
	private let navigationController: UINavigationController
	
	let DIContainer: RecordDIContainer
	
	init(DIContainer: RecordDIContainer,
			 navigationController: UINavigationController) {
		self.DIContainer = DIContainer
		self.navigationController = navigationController
	}
}

extension RecordCoordinator {
	func start() {
		let recordViewController = DIContainer.makeRecordViewController()
		recordViewController.coordinator = self
		self.navigationController.pushViewController(recordViewController, animated: true)
	}
	
	func dismiss() {
		navigationController.popViewController(animated: true)
	}
}
