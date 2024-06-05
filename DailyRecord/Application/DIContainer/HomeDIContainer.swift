//
//  HomeDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import UIKit

final class HomeDIContainer: DIContainer {
	private let navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
}

extension HomeDIContainer {
	func makeHomeCoordinator() -> HomeCoordinator {
		return HomeCoordinator(DIContainer: self,
													 navigationController: navigationController)
	}
	
	func makeHomeViewController() -> HomeViewController {
		return HomeViewController(viewModel: makeHomeViewModel())
	}
	
	private func makeHomeViewModel() -> HomeViewModel {
		return HomeViewModel()
	}
}
