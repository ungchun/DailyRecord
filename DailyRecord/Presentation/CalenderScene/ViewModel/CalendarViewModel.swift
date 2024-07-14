//
//  CalendarViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import Foundation

final class CalendarViewModel: BaseViewModel {
	
	// MARK: - Properties
	
	private let calendarUseCase: DefaultCalendarUseCase
	
	var records: [RecordEntity] = []
	
	// MARK: - Init
	
	init(
		calendarUseCase: DefaultCalendarUseCase
	) {
		self.calendarUseCase = calendarUseCase
	}
}

extension CalendarViewModel {
	
	// MARK: - Functions
	
	@MainActor
	func TEST() {
		Task {
			do {
				records = try await self.calendarUseCase.readMonthRecord()
			} catch {
				// TODO: 에러 처리
			}
		}
	}
}
