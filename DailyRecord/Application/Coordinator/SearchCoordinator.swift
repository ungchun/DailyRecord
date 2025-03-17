//
//  SearchCoordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 3/17/25.
//

import UIKit

final class SearchCoordinator: Coordinator {
  private let navigationController: UINavigationController
  
  let DIContainer: SearchDIContainer
  
  init(
    DIContainer: SearchDIContainer,
    navigationController: UINavigationController
  ) {
    self.DIContainer = DIContainer
    self.navigationController = navigationController
  }
}

extension SearchCoordinator {
  func start() {
    let searchViewController = DIContainer.makeSearchViewController()
    searchViewController.coordinator = self
    self.navigationController.pushViewController(
      searchViewController,
      animated: true
    )
  }
  
  func showRecord(
    calendarViewModel: CalendarViewModel,
    selectData: RecordEntity
  ) {
    let recordDIContainer = DIContainer.makeRecordDIContainer(
      calendarViewModel: calendarViewModel,
      selectData: selectData
    )
    let recordCoordinator = recordDIContainer.makeRecordCoordinator()
    recordCoordinator.start()
  }
  
  func popToRoot() {
    navigationController.popToRootViewController(animated: true)
  }
}
