//
//  RecordRequest.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Foundation

struct RecordRequest: Encodable {
	let user_id: String
	let content: String
	let emotion_type: String
	let image_list: [String]
	let image_identifier: [String]
	let create_time: Int
	let calendar_date: Int
}
