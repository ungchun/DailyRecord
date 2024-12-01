//
//  DrawerDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 11/30/24.
//

import UIKit

final class DrawerDIContainer: DIContainer {
  private let navigationController: UINavigationController
  private let calendarViewModel: CalendarViewModel
  private let currentDate: Date
  
  init(
    navigationController: UINavigationController,
    calendarViewModel: CalendarViewModel,
    currentDate: Date
  ) {
    self.navigationController = navigationController
    self.calendarViewModel = calendarViewModel
    self.currentDate = currentDate
  }
}

extension DrawerDIContainer {
  
  // MARK: - Drawer
  
  func makeDrawerCoordinator() -> DrawerCoordinator {
    return DrawerCoordinator(
      DIContainer: self,
      navigationController: navigationController
    )
  }
  
  func makeDrawerViewController() -> DrawerViewController {
    return DrawerViewController(
      viewModel: makeDrawerViewModel(),
      calendarViewModel: calendarViewModel
    )
  }
  
  private func makeDrawerViewModel() -> DrawerViewModel {
    return DrawerViewModel(
      calendarUseCase: CalendarUseCase(
        calendarRepository: CalendarRepository()
      ),
      currentDate: currentDate
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
