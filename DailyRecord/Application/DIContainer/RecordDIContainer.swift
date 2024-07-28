//
//  RecordDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/6/24.
//

import UIKit

final class RecordDIContainer: DIContainer {
	private let navigationController: UINavigationController
	
	private let calendarViewModel: CalendarViewModel
	private let selectData: RecordEntity
	
	init(
		navigationController: UINavigationController,
		calendarViewModel: CalendarViewModel,
		selectData: RecordEntity
	) {
		self.navigationController = navigationController
		self.calendarViewModel = calendarViewModel
		self.selectData = selectData
	}
}

extension RecordDIContainer {
	
	// MARK: - Record
	
	func makeRecordCoordinator() -> RecordCoordinator {
		return RecordCoordinator(DIContainer: self,
														 navigationController: navigationController,
														 hasData: selectData.createTime != 0)
	}
	
	func makeRecordHistoryViewController() -> RecordHistoryViewController {
		return RecordHistoryViewController(
			viewModel: makeRecordViewModel(),
			calendarViewModel: calendarViewModel
		)
	}
	
	func makeRecordWriteViewController(_ viewModel: RecordViewModel? = nil) -> RecordWriteViewController {
		if let viewModel = viewModel {
			return RecordWriteViewController(
				viewModel: viewModel,
				calendarViewModel: calendarViewModel
			)
		} else {
			return RecordWriteViewController(
				viewModel: makeRecordViewModel(),
				calendarViewModel: calendarViewModel
			)
		}
	}
	
	private func makeRecordViewModel() -> RecordViewModel {
		return RecordViewModel(
			recordUseCase: RecordUseCase(recordRepository: RecordRepository()),
			selectData: selectData
		)
	}
}
