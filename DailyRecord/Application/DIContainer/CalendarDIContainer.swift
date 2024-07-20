//
//  CalendarDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import UIKit

final class CalendarDIContainer: DIContainer {
	private let navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
}

extension CalendarDIContainer {
	
	// MARK: - Calendar
	
	func makeCalendarCoordinator() -> CalendarCoordinator {
		return CalendarCoordinator(DIContainer: self,
															 navigationController: navigationController)
	}
	
	func makeCalendarViewController() -> CalendarViewController {
		return CalendarViewController(viewModel: makeCalendarViewModel())
	}
	
	private func makeCalendarViewModel() -> CalendarViewModel {
		return CalendarViewModel(
			calendarUseCase: CalendarUseCase(calendarRepository: CalendarRepository())
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