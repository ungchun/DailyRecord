//
//  UserDefaultsSetting.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/5/24.
//

import Foundation

enum UserDefaultsSetting {
	@UserDefaultsWrapper(key: "uid", defaultValue: "")
	static var uid
	
	@UserDefaultsWrapper(key: "idTokenString", defaultValue: "")
	static var idTokenString
	
	@UserDefaultsWrapper(key: "nonce", defaultValue: "")
	static var nonce
	
	@UserDefaultsWrapper(key: "isAnonymously", defaultValue: false)
	static var isAnonymously
}
