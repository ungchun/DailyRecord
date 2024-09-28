//
//  DefaultRecordRepository.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Foundation

protocol DefaultRecordRepository {
  func createRecord(data: RecordEntity) async throws
  func updateRecord(data: RecordEntity) async throws
  func removeRecord(calendarDate: Int) async throws
}
