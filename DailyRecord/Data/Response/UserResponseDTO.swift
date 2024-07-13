//
//  UserResponseDTO.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/29/24.
//

import Foundation

struct UserResponseDTO: Decodable {
	let uid: String?
	let nickname: String?
	let platform: String?
	let fcm_token: String?
}

// MARK: - to Entity

extension UserResponseDTO {
	func toEntity() -> User {
		return .init(uid: uid ?? "")
	}
}
