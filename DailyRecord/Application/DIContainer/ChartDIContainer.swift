//
//  ChartDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 10/20/24.
//

import UIKit

final class ChartDIContainer: DIContainer {
  private let navigationController: UINavigationController
  private let currentDate: Date
  
  init(
    navigationController: UINavigationController,
    currentDate: Date
  ) {
    self.navigationController = navigationController
    self.currentDate = currentDate
  }
}

extension ChartDIContainer {
  
  // MARK: - Chart
  
  func makeChartCoordinator() -> ChartCoordinator {
    return ChartCoordinator(
      DIContainer: self,
      navigationController: navigationController,
      currentDate: currentDate
    )
  }
  
  func makeChartViewController(currentDate: Date) -> ChartViewController {
    return ChartViewController(
      viewModel: makeChartViewModel(currentDate: currentDate)
    )
  }
  
  private func makeChartViewModel(currentDate: Date) -> ChartViewModel {
    return ChartViewModel(
      calendarUseCase: CalendarUseCase(
        calendarRepository: CalendarRepository()
      ),
      currentDate: currentDate
    )
  }
}
