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
	
	init(DIContainer: ProfileDIContainer,
			 navigationController: UINavigationController) {
		self.DIContainer = DIContainer
		self.navigationController = navigationController
	}
}

extension ProfileCoordinator {
	func start() {
		let profileViewController = DIContainer.makeProfileViewController()
		profileViewController.coordinator = self
		self.navigationController.pushViewController(profileViewController,
																								 animated: true)
	}
	
	func popToRoot() {
		self.navigationController.popToRootViewController(animated: true)
	}
}
