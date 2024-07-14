//
//  CalenderDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import UIKit

final class CalenderDIContainer: DIContainer {
	private let navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
}

extension CalenderDIContainer {
	
	// MARK: - Calender
	
	func makeCalenderCoordinator() -> CalenderCoordinator {
		return CalenderCoordinator(DIContainer: self,
															 navigationController: navigationController)
	}
	
	func makeCalenderViewController() -> CalenderViewController {
		return CalenderViewController(viewModel: makeCalenderViewModel())
	}
	
	private func makeCalenderViewModel() -> CalenderViewModel {
		return CalenderViewModel(
			calenderUseCase: CalenderUseCase(calenderRepository: CalenderRepository())
		)
	}
	
	// MARK: - Record
	
	func makeRecordDIContainer(selectDate: Date) -> RecordDIContainer {
		return RecordDIContainer(
			navigationController: navigationController,
			selectDate: selectDate
		)
	}
}
