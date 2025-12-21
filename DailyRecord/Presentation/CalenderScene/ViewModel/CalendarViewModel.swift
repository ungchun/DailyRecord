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
  
  private let coreDataManager: CoreDataManager = CoreDataManager.shared
  private let calendarUseCase: DefaultCalendarUseCase
  
  private(set) var currentDate: Date = Date()
  var lastModifiedRecordDate: Date?

  @Published var records: [RecordEntity] = []
  @Published var todayRecord: RecordEntity?
  
  // MARK: - Init
  
  init(
    calendarUseCase: DefaultCalendarUseCase
  ) {
    self.calendarUseCase = calendarUseCase
  }
}

// MARK: - Functions

extension CalendarViewModel {
  func updateCurrentDate(_ currentDate: Date) {
    self.currentDate = currentDate
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
      
      let uniqueRecords = self.removeDuplicatesAndSort(records: response)
      
      await MainActor.run {
        self.records = uniqueRecords
        
        // 오늘 날짜 월인 경우 todayRecord도 업데이트
        let nowDate = Calendar.current.startOfDay(for: Date())
        let todayYear = Calendar.current.component(.year, from: nowDate)
        let todayMonth = Calendar.current.component(.month, from: nowDate)
        
        if year == todayYear && month == todayMonth {
          if let matchedEntity = uniqueRecords.first(where: { entity in
            let seconds = TimeInterval(entity.calendarDate) / 1000
            let responseDate = Date(timeIntervalSince1970: seconds)
            return nowDate == responseDate
          }) {
            self.todayRecord = matchedEntity
          } else {
            self.todayRecord = RecordEntity(calendarDate: Int(nowDate.millisecondsSince1970))
          }
        }
        
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
