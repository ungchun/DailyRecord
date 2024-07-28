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
	
	func fetchMonthRecordTrigger(year: Int, month: Int) async throws {
		Task { [weak self] in
			guard let self = self else { return }
			let response = try await self.calendarUseCase.readMonthRecord(
				year: year, month: month
			 )
			await MainActor.run {
				self.records = response
			}
		}
	}
}
