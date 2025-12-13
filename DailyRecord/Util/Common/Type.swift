//
//  Type.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/14/24.
//

import Foundation

// MARK: - 감정표현 타입

enum EmotionType: String {
  case none
  
  // Mood Types
  case very_happy
  case happy
  case very_sad
  case sad
  case neutral
  case angry
  case embarrassed
  case hurt
  case lovely
  case sleepy
  case surprised
  case tired
  
  // Daily Types
  case shopping
  case coffee
  case food
  case culture
  case sleep
  case alcohol
  case hospital
  case music
  case love
  case studying
  case cleaning
  case money
  case shower
  case book
  case bomb
}

// MARK: - 디스플레이 모드

enum DisplayMode: String {
  case system = "system"
  case light = "light"
  case dark = "dark"
}

// MARK: - Notification

extension Notification.Name {
  static let fontDidChange = Notification.Name("fontDidChange")
}
