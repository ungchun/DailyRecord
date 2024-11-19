//
//  UserDefaultsWrapper.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/5/24.
//

import Foundation

@propertyWrapper
struct UserDefaultsWrapper<T> {
	private let key: String
	private let defaultValue: T
	private let suiteName: String?
	
	init(key: String, defaultValue: T, suiteName: String? = nil) {
		self.key = key
		self.defaultValue = defaultValue
		self.suiteName = suiteName
	}
	
	var wrappedValue: T {
		get {
			let userDefaults = getUserDefaults()
			return userDefaults.object(forKey: key) as? T ?? defaultValue
		}
		set {
			let userDefaults = getUserDefaults()
			userDefaults.set(newValue, forKey: key)
		}
	}
	
	private func getUserDefaults() -> UserDefaults {
		if let suiteName = suiteName {
			return UserDefaults(suiteName: suiteName) ?? .standard
		} else {
			return .standard
		}
	}
}
