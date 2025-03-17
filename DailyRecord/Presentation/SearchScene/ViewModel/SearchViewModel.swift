//
//  SearchViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 3/17/25.
//

import Foundation
import UIKit

final class SearchViewModel: BaseViewModel {
  
  // MARK: - Properties
  
  private let searchUseCase: DefaultSearchUseCase
  
  private(set) var searchResults: [RecordEntity] = []
  
  // MARK: - Init
  
  init(searchUseCase: DefaultSearchUseCase) {
    self.searchUseCase = searchUseCase
    super.init()
  }
}

// MARK: - Functions

extension SearchViewModel {
  func clearSearchResults() {
    DispatchQueue.main.async {
      self.searchResults = []
    }
  }
  
  func search(query: String) {
    if query.isEmpty {
      DispatchQueue.main.async {
        self.searchResults = []
      }
      return
    }
    
    do {
      searchResults = try searchUseCase.searchRecords(query: query)
    } catch {
      DispatchQueue.main.async {
        self.searchResults = []
      }
    }
  }
}
