//
//  PdfExportViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 1/16/25.
//

import Foundation

final class PdfExportViewModel: BaseViewModel {
  
  // MARK: - Properties
  
  @Published private(set) var records: [RecordEntity] = []
  @Published private(set) var currentDate: Date
  
  private let calendarUseCase: DefaultCalendarUseCase
  
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

extension PdfExportViewModel {
  func updateCurrentDate(_ date: Date) {
    currentDate = date
  }
  
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
      
      let sortedRecords = self.removeDuplicatesAndSort(records: response)
      
      await MainActor.run {
        self.records = sortedRecords
        completion()
      }
    }
  }
}

private extension PdfExportViewModel {
  func removeDuplicatesAndSort(records: [RecordEntity]) -> [RecordEntity] {
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
