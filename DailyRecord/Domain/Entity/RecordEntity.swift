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
	let imageListURL: [String]
	let createTime: Int
	let calendarDate: Int
	
	init(uid: String = "",
			 content: String = "",
			 emotionType: EmotionType = .none,
			 imageListURL: [String] = [],
			 createTime: Int = 0,
			 calendarDate: Int = 0) {
		self.uid = uid
		self.content = content
		self.emotionType = emotionType
		self.imageListURL = imageListURL
		self.createTime = createTime
		self.calendarDate = calendarDate
	}
}
