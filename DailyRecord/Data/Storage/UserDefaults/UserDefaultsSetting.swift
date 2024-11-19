//
//  UserDefaultsSetting.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/5/24.
//

import Foundation

enum UserDefaultsSetting {
	@UserDefaultsWrapper(key: "displayMode", defaultValue: DisplayMode.system.rawValue)
	static var displayMode
	
	@UserDefaultsWrapper(key: "uid", defaultValue: "", suiteName: "group.ungchun.DailyRecord")
	static var uid
	
	static var currentDisplayMode: DisplayMode {
		get {
			return DisplayMode(rawValue: displayMode) ?? .system
		}
		set {
			displayMode = newValue.rawValue
		}
	}
}
