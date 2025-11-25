//
//  ProfileCoordinator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/1/24.
//

import UIKit

final class ProfileCoordinator: Coordinator {
  private let navigationController: UINavigationController
  
  let DIContainer: ProfileDIContainer
  
  init(
    DIContainer: ProfileDIContainer,
    navigationController: UINavigationController
  ) {
    self.DIContainer = DIContainer
    self.navigationController = navigationController
  }
}

extension ProfileCoordinator {
  func start() {
    let profileViewController = DIContainer.makeProfileViewController()
    profileViewController.coordinator = self
    self.navigationController.pushViewController(
      profileViewController,
      animated: true
    )
  }
  
  func showSetiCloud() {
    let setiCloudSyncViewController = DIContainer.makeSetiCloudSyncViewController()
    setiCloudSyncViewController.coordinator = self
    self.navigationController.pushViewController(
      setiCloudSyncViewController,
      animated: true
    )
  }
  
  func showSetDarkmode() {
    let setDarkModeViewController = DIContainer.makeSetDarkModeViewController()
    setDarkModeViewController.coordinator = self
    self.navigationController.pushViewController(
      setDarkModeViewController,
      animated: true
    )
  }
  
  func showSetScreenLock() {
    let setScreenLockViewController = DIContainer.makeSetScreenLockViewController()
    setScreenLockViewController.coordinator = self
    self.navigationController.pushViewController(
      setScreenLockViewController,
      animated: true
    )
  }
  
  func showMusicChange() {
    let musicChangeViewController = DIContainer.makeMusicChangeViewController()
    musicChangeViewController.coordinator = self
    self.navigationController.pushViewController(
      musicChangeViewController,
      animated: true
    )
  }
  
  func showPdfExport() {
    let pdfExportViewController = DIContainer.makePdfExportViewController()
    pdfExportViewController.coordinator = self
    self.navigationController.pushViewController(
      pdfExportViewController,
      animated: true
    )
  }
  
  func popToRoot() {
    self.navigationController.popToRootViewController(animated: true)
  }
}
