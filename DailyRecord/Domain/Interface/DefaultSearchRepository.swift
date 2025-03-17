//
//  DefaultSearchRepository.swift
//  DailyRecord
//
//  Created by Kim SungHun on 3/17/25.
//

import Foundation

protocol DefaultSearchRepository {
  func searchRecords(query: String) throws -> [RecordEntity]
}
