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
	let profileRepository: DefaultProfileRepository
	
	init(profileRepository: DefaultProfileRepository) {
		self.profileRepository = profileRepository
	}
}

extension ProfileUseCase {
	func createUser(data: [String : Any]) async throws {
		try await profileRepository.createUser(data: data)
	}
	
	func getUserInfo() async throws -> User? {
		return try await profileRepository.getUserInfo()?.toEntity()
	}
	
	func updateUserInfo(updateData: [String : Any]) async throws {
		try await profileRepository.updateUserInfo(updateData: updateData)
	}
	
	func removeUser() async throws {
		try await profileRepository.removeUser()
	}
}
