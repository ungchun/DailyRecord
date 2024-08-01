//
//  LoginUseCase.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Foundation

protocol DefaultProfileUseCase {
	func createUser(data: [String : Any]) async throws
	func getUserInfo() async throws -> User?
	func updateUserInfo(updateData: [String: Any]) async throws
	func removeUser() async throws
}

final class ProfileUseCase: DefaultProfileUseCase {
	let loginRepository: DefaultLoginRepository
	
	init(loginRepository: DefaultLoginRepository) {
		self.loginRepository = loginRepository
	}
}

extension ProfileUseCase {
	func createUser(data: [String : Any]) async throws {
		try await loginRepository.createUser(data: data)
	}
	
	func getUserInfo() async throws -> User? {
		return try await loginRepository.getUserInfo()?.toEntity()
	}
	
	func updateUserInfo(updateData: [String : Any]) async throws {
		try await loginRepository.updateUserInfo(updateData: updateData)
	}
	
	func removeUser() async throws {
		
	}
}
