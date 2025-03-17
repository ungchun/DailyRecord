//
//  SearchDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 3/17/25.
//

import UIKit

final class SearchDIContainer: DIContainer {
  private let navigationController: UINavigationController
  private let calendarViewModel: CalendarViewModel
  
  init(
    navigationController: UINavigationController,
    calendarViewModel: CalendarViewModel
  ) {
    self.navigationController = navigationController
    self.calendarViewModel = calendarViewModel
  }
}

extension SearchDIContainer {
  func makeSearchCoordinator() -> SearchCoordinator {
    return SearchCoordinator(
      DIContainer: self,
      navigationController: navigationController
    )
  }
  
  func makeSearchViewController() -> SearchViewController {
    return SearchViewController(
      viewModel: makeSearchViewModel(),
      calendarViewModel: calendarViewModel
    )
  }
  
  private func makeSearchViewModel() -> SearchViewModel {
    return SearchViewModel(
      searchUseCase: SearchUseCase(
        searchRepository: SearchRepository()
      )
    )
  }
  
  // MARK: - Record
  
  func makeRecordDIContainer(
    calendarViewModel: CalendarViewModel,
    selectData: RecordEntity
  ) -> RecordDIContainer {
    return RecordDIContainer(
      navigationController: navigationController,
      calendarViewModel: calendarViewModel,
      selectData: selectData
    )
  }
}
