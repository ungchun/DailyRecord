//
//  ChartCoordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 10/20/24.
//

import UIKit

final class ChartCoordinator: Coordinator {
  private let navigationController: UINavigationController
  
  let DIContainer: ChartDIContainer
  
  init(DIContainer: ChartDIContainer,
       navigationController: UINavigationController) {
    self.DIContainer = DIContainer
    self.navigationController = navigationController
  }
}

extension ChartCoordinator {
  func start() {
    let chartViewController = DIContainer.makeChartViewController()
    chartViewController.coordinator = self
    self.navigationController.pushViewController(chartViewController,
                                                 animated: true)
  }
  
  func popToRoot() {
    navigationController.popToRootViewController(animated: true)
  }
}
