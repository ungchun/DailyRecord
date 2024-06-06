//
//  RecordDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/6/24.
//

import UIKit

final class RecordDIContainer: DIContainer {
	private let navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
}

extension RecordDIContainer {
	
	// MARK: - Record
	
	func makeRecordCoordinator() -> RecordCoordinator {
		return RecordCoordinator(DIContainer: self,
														 navigationController: navigationController)
	}
	
	func makeRecordViewController() -> RecordViewController {
		return RecordViewController()
	}
	
	// makeRecordViewModel
	
}
