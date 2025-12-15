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
  
  @UserDefaultsWrapper(key: "isPasswordEnabled", defaultValue: false)
  static var isPasswordEnabled
  
  @UserDefaultsWrapper(key: "isBiometricEnabled", defaultValue: false)
  static var isBiometricEnabled
  
  @UserDefaultsWrapper(key: "isDailyReminderEnabled", defaultValue: true)
  static var isDailyReminderEnabled
  
  @UserDefaultsWrapper(key: "dailyReminderTime", defaultValue: "22:00")
  static var dailyReminderTime

  @UserDefaultsWrapper(key: "hasRequestedReview", defaultValue: false)
  static var hasRequestedReview

  @UserDefaultsWrapper(key: "recordSaveCount", defaultValue: 0)
  static var recordSaveCount

  static var currentDisplayMode: DisplayMode {
    get {
      return DisplayMode(rawValue: displayMode) ?? .system
    }
    set {
      displayMode = newValue.rawValue
    }
  }
}
