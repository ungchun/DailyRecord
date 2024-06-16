//
//  RecordDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/6/24.
//

import UIKit

final class RecordDIContainer: DIContainer {
	private let navigationController: UINavigationController
	private let selectDate: Date
	
	init(
		navigationController: UINavigationController,
		selectDate: Date
	) {
		self.navigationController = navigationController
		self.selectDate = selectDate
	}
}

extension RecordDIContainer {
	
	// MARK: - Record
	
	func makeRecordCoordinator() -> RecordCoordinator {
		return RecordCoordinator(DIContainer: self,
														 navigationController: navigationController)
	}
	
	func makeRecordViewController() -> RecordViewController {
		return RecordViewController(
			viewModel: makeRecordViewModel()
		)
	}
	
	private func makeRecordViewModel() -> RecordViewModel {
		return RecordViewModel(selectDate: selectDate)
	}
}
