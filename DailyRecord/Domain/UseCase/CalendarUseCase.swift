//
//  CalendarUseCase.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/13/24.
//

import Foundation

protocol DefaultCalendarUseCase {
	func readMonthRecord() async throws -> [RecordEntity]
}

final class CalendarUseCase: DefaultCalendarUseCase {
	let calendarRepository: DefaultCalendarRepository
	
	init(calendarRepository: DefaultCalendarRepository) {
		self.calendarRepository = calendarRepository
	}
}

extension CalendarUseCase {
	func readMonthRecord() async throws -> [RecordEntity] {
		return try await calendarRepository.readMonthRecord().map{$0.toEntity()}
	}
}
