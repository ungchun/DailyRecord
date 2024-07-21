//
//  RecordDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/6/24.
//

import UIKit

final class RecordDIContainer: DIContainer {
	private let navigationController: UINavigationController
	private let selectData: RecordEntity
	
	init(
		navigationController: UINavigationController,
		selectData: RecordEntity
	) {
		self.navigationController = navigationController
		self.selectData = selectData
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
		return RecordViewModel(
			recordUseCase: RecordUseCase(recordRepository: RecordRepository()),
			selectData: selectData
		)
	}
}
