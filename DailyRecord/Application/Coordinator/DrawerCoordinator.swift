//
//  DrawerCoordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 11/30/24.
//

import UIKit

final class DrawerCoordinator: Coordinator {
  private let navigationController: UINavigationController
  
  let DIContainer: DrawerDIContainer
  
  init(
    DIContainer: DrawerDIContainer,
    navigationController: UINavigationController
  ) {
    self.DIContainer = DIContainer
    self.navigationController = navigationController
  }
}

extension DrawerCoordinator {
  func start() {
    let drawerViewController = DIContainer.makeDrawerViewController()
    drawerViewController.coordinator = self
    self.navigationController.pushViewController(
      drawerViewController,
      animated: true
    )
  }
  
  func popToRoot() {
    navigationController.popToRootViewController(animated: true)
  }
}
