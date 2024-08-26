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
	case very_happy
	case happy
	case very_sad
	case sad
	case neutral
	case angry
}

// MARK: - 디스플레이 모드

enum DisplayMode: String {
	case system = "system"
	case light = "light"
	case dark = "dark"
}
