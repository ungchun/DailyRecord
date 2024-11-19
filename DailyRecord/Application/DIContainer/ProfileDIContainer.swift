//
//  ProfileDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/1/24.
//

import UIKit

final class ProfileDIContainer: DIContainer {
	private let navigationController: UINavigationController
	
	private let calendarViewModel: CalendarViewModel
	
	init(
		navigationController: UINavigationController,
		calendarViewModel: CalendarViewModel
	) {
		self.navigationController = navigationController
		self.calendarViewModel = calendarViewModel
	}
}

extension ProfileDIContainer {
	
	// MARK: - Profile
	
	func makeProfileCoordinator() -> ProfileCoordinator {
		return ProfileCoordinator(DIContainer: self,
															navigationController: navigationController)
	}
	
	func makeProfileViewController() -> ProfileViewController {
		return ProfileViewController(
			viewModel: makeProfileViewModel(),
			calendarViewModel: calendarViewModel
		)
	}
	
	private func makeProfileViewModel() -> ProfileViewModel {
		return ProfileViewModel(
			profileUseCase: ProfileUseCase(profileRepository: ProfileRepository())
		)
	}
	
  func makeSetiCloudSyncViewController() -> SetiCloudSyncViewController {
    return SetiCloudSyncViewController()
  }
  
	func makeSetDarkModeViewController() -> SetDarkModeViewController {
		return SetDarkModeViewController()
	}
}
