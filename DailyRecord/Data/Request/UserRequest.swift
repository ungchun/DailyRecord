//
//  UserRequest.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/29/24.
//

import Foundation

struct UserRequest: Encodable {
	let uid: String
	let nickname: String
	let platform: String
	let fcm_token: String
}
