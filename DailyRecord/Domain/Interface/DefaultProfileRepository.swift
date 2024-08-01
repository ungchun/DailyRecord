//
//  DefaultLoginRepository.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Foundation

protocol DefaultProfileRepository {
	func createUser(data: [String : Any]) async throws
	func getUserInfo() async throws -> UserResponseDTO?
	func updateUserInfo(updateData: [String: Any]) async throws
	func removeUser(fieldID: String) async throws
}
