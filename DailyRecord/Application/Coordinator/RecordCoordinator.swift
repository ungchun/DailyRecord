//
//  RecordCoordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/6/24.
//

import UIKit

final class RecordCoordinator: Coordinator {
	let DIContainer: RecordDIContainer
	
	private let navigationController: UINavigationController
	private let hasData: Bool
	
	init(
		DIContainer: RecordDIContainer,
		navigationController: UINavigationController,
		hasData: Bool
	) {
		self.DIContainer = DIContainer
		self.navigationController = navigationController
		self.hasData = hasData
	}
}

extension RecordCoordinator {
	func start() {
		if hasData {
			let recordViewController = DIContainer.makeRecordHistoryViewController()
			recordViewController.coordinator = self
			self.navigationController.pushViewController(recordViewController, animated: true)
		} else {
			let recordViewController = DIContainer.makeRecordWriteViewController()
			recordViewController.coordinator = self
			self.navigationController.pushViewController(recordViewController, animated: true)
		}
	}
	
	func showWriteViewController(_ viewModel: RecordViewModel) {
		let recordViewController = DIContainer.makeRecordWriteViewController(viewModel)
		recordViewController.coordinator = self
		self.navigationController.pushViewController(recordViewController,
																								 animated: true)
	}
	
	func dismiss() {
		navigationController.popViewController(animated: true)
	}
	
	func popToRoot() {
		navigationController.popToRootViewController(animated: true)
	}
}
