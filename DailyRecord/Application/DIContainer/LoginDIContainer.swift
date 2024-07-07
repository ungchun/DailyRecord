//
//  LoginDIContainer.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/22/24.
//

import UIKit

final class LoginDIContainer: DIContainer {
	private let navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
}

extension LoginDIContainer {
	
	// MARK: - Login
	
	func makeLoginCoordinator() -> LoginCoordinator {
		return LoginCoordinator(DIContainer: self,
														navigationController: navigationController)
	}
	
	func makeLoginViewController() -> LoginViewController {
		return LoginViewController(viewModel: makeLoginViewModel())
	}
	
	private func makeLoginViewModel() -> LoginViewModel {
		return LoginViewModel(loginUseCase: LoginUseCase(loginRepository: LoginRepository()))
	}
	
	// MARK: - Calender
	
	func makeCalenderDIContainer() -> CalenderDIContainer {
		return CalenderDIContainer(
			navigationController: navigationController
		)
	}
}
