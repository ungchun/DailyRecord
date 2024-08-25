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
	
	@UserDefaultsWrapper(key: "displayMode", defaultValue: DisplayMode.system.rawValue)
	static var displayMode
	
	static var currentDisplayMode: DisplayMode {
		get {
			return DisplayMode(rawValue: displayMode) ?? .system
		}
		set {
			displayMode = newValue.rawValue
		}
	}
}
