//
//  SearchUseCase.swift
//  DailyRecord
//
//  Created by Kim SungHun on 3/17/25.
//

import Foundation

protocol DefaultSearchUseCase {
  func searchRecords(query: String) throws -> [RecordEntity]
}

final class SearchUseCase: DefaultSearchUseCase {
  let searchRepository: DefaultSearchRepository
  
  init(searchRepository: DefaultSearchRepository) {
    self.searchRepository = searchRepository
  }
}

extension SearchUseCase {
  func searchRecords(query: String) throws -> [RecordEntity] {
    return try searchRepository.searchRecords(query: query)
  }
}
