//
//  RecordUseCase.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Foundation

protocol DefaultRecordUseCase {
  func createRecord(data: RecordEntity) async throws
  func updateRecord(data: RecordEntity) async throws
  func removeRecord(calendarDate: Int) async throws
}

final class RecordUseCase: DefaultRecordUseCase {
  let recordRepository: DefaultRecordRepository
  
  init(recordRepository: DefaultRecordRepository) {
    self.recordRepository = recordRepository
  }
}

extension RecordUseCase {
  func createRecord(data: RecordEntity) async throws {
    try await recordRepository.createRecord(data: data)
  }
  
  func updateRecord(data: RecordEntity) async throws {
    try await recordRepository.updateRecord(data: data)
  }
  
  func removeRecord(calendarDate: Int) async throws {
    try await recordRepository.removeRecord(calendarDate: calendarDate)
  }
}
