//
//  CalendarUseCase.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/13/24.
//

import Foundation

protocol DefaultCalendarUseCase {
  func readMonthRecord(year: Int, month: Int) async throws -> [RecordEntity]
}

final class CalendarUseCase: DefaultCalendarUseCase {
  let calendarRepository: DefaultCalendarRepository
  
  init(calendarRepository: DefaultCalendarRepository) {
    self.calendarRepository = calendarRepository
  }
}

extension CalendarUseCase {
  func readMonthRecord(year: Int, month: Int) async throws -> [RecordEntity] {
    return try await calendarRepository.readMonthRecord(
      year: year, month: month
    )
  }
}
