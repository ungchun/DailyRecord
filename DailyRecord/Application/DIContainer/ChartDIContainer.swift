//
//  ChartDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 10/20/24.
//

import UIKit

final class ChartDIContainer: DIContainer {
  private let navigationController: UINavigationController
  
  init(
    navigationController: UINavigationController
  ) {
    self.navigationController = navigationController
  }
}

extension ChartDIContainer {
  
  // MARK: - Profile
  
  func makeChartCoordinator() -> ChartCoordinator {
    return ChartCoordinator(DIContainer: self,
                              navigationController: navigationController)
  }
  
  func makeChartViewController() -> ChartViewController {
    return ChartViewController(
      viewModel: makeChartViewModel()
    )
  }
  
  private func makeChartViewModel() -> ChartViewModel {
    return ChartViewModel(
      calendarUseCase: CalendarUseCase(calendarRepository: CalendarRepository())
    )
  }
}
