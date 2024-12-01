//
//  ChartCoordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 10/20/24.
//

import UIKit

final class ChartCoordinator: Coordinator {
  private let navigationController: UINavigationController
  private let currentDate: Date
  
  let DIContainer: ChartDIContainer
  
  init(
    DIContainer: ChartDIContainer,
    navigationController: UINavigationController,
    currentDate: Date
  ) {
    self.DIContainer = DIContainer
    self.navigationController = navigationController
    self.currentDate = currentDate
  }
}

extension ChartCoordinator {
  func start() {
    let chartViewController = DIContainer.makeChartViewController(
      currentDate: currentDate
    )
    chartViewController.coordinator = self
    self.navigationController.pushViewController(
      chartViewController,
      animated: true
    )
  }
  
  func popToRoot() {
    navigationController.popToRootViewController(animated: true)
  }
}
