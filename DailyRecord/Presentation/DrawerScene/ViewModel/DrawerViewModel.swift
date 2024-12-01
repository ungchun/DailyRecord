//
//  DrawerViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 11/30/24.
//

import Foundation

final class DrawerViewModel: BaseViewModel {
  
  // MARK: - Properties
  
  private let calendarUseCase: DefaultCalendarUseCase
  
  private(set) var records: [RecordEntity] = []
  private(set) var currentDate: Date
  
  // MARK: - Init
  
  init(
    calendarUseCase: DefaultCalendarUseCase,
    currentDate: Date
  ) {
    self.calendarUseCase = calendarUseCase
    self.currentDate = currentDate
  }
}

// MARK: - Functions

extension DrawerViewModel {
  func updateCurrentDate(_ currentDate: Date) {
    self.currentDate = currentDate
  }
}

extension DrawerViewModel {
  func fetchMonthRecordTrigger(
    year: Int,
    month: Int,
    completion: @escaping () -> Void
  ) async throws {
    Task { [weak self] in
      guard let self = self else { return }
      
      let response = try await self.calendarUseCase.readMonthRecord(
        year: year, month: month
      )
      
      let uniqueRecords = self.removeDuplicatesAndSort(records: response)
      
      await MainActor.run {
        self.records = uniqueRecords
        completion()
      }
    }
  }
  
  private func removeDuplicatesAndSort(records: [RecordEntity]) -> [RecordEntity] {
    let groupedRecords = Dictionary(grouping: records) { record -> Date in
      let seconds = TimeInterval(record.calendarDate) / 1000
      return Date(timeIntervalSince1970: seconds)
    }
    
    let uniqueRecords = groupedRecords.values.compactMap { $0.first }
    
    return uniqueRecords.sorted { (record1, record2) -> Bool in
      return record1.calendarDate < record2.calendarDate
    }
  }
}
