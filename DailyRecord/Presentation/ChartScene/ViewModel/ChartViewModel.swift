//
//  ChartViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 10/20/24.
//

import Foundation

final class ChartViewModel: BaseViewModel {
  
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

extension ChartViewModel {
  
  // MARK: - Functions
  
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
      
      Log.debug("AZHY uniqueRecords", uniqueRecords)
      
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
