//
//  RecordEntity.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/14/24.
//

import Foundation

struct RecordEntity {
	let uid: String
	let content: String
	let emotionType: EmotionType
	let imageList: [String]
	let createTime: Int
	let calendarDate: Int
}
