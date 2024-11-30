//
//  DrawerDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 11/30/24.
//

import UIKit

final class DrawerDIContainer: DIContainer {
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
      viewModel: makeDrawerViewModel()
    )
  }
  
  private func makeDrawerViewModel() -> DrawerViewModel {
    return DrawerViewModel(
      currentDate: currentDate
    )
  }
}
