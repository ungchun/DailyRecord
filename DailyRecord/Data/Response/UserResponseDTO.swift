//
//  UserResponseDTO.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/29/24.
//

import Foundation

struct UserResponseDTO: Decodable {
	let uid: String?
	let docID: String?
	let nickname: String?
	let platForm: String?
	let fcmToken: String?
}

// MARK: - to Entity

extension UserResponseDTO {
	func toEntity() -> User {
		return .init()
	}
}
