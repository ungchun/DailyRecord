//
//  CalendarViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import Foundation
import Combine

final class CalendarViewModel: BaseViewModel {
	
	// MARK: - Properties
	
	private let calendarUseCase: DefaultCalendarUseCase
	
	@Published var records: [RecordEntity] = []
	
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
	func fetchMonthRecordTrigger(year: Int, month: Int) {
		Task {
			do {
				records = try await self.calendarUseCase.readMonthRecord(
					year: year, month: month
				)
			} catch {
				// TODO: 에러 처리
			}
		}
	}
}
