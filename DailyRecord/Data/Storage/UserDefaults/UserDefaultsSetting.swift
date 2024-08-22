//
//  UserDefaultsSetting.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/5/24.
//

import Foundation

enum UserDefaultsSetting {
	@UserDefaultsWrapper(key: "isAnonymously", defaultValue: false)
	static var isAnonymously
}
