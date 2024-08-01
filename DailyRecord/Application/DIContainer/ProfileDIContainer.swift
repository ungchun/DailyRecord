//
//  ProfileDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/1/24.
//

import UIKit

final class ProfileDIContainer: DIContainer {
	private let navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
}

extension ProfileDIContainer {
	
	// MARK: - Profile
	
	func makeProfileCoordinator() -> ProfileCoordinator {
		return ProfileCoordinator(DIContainer: self,
															navigationController: navigationController)
	}
	
	func makeProfileViewController() -> ProfileViewController {
		return ProfileViewController(viewModel: makeProfileViewModel())
	}
	
	private func makeProfileViewModel() -> ProfileViewModel {
		return ProfileViewModel(
			profileUseCase: ProfileUseCase(profileRepository: ProfileRepository())
		)
	}
}
