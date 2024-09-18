//
//  RecordResponseDTO.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Foundation

struct RecordResponseDTO: Decodable {
	let uid: String?
	let content: String?
	let emotion_type: String?
	let image_list: [String]?
	let image_identifier: [String]?
	let create_time: Int?
	let calendar_date: Int?
}

// MARK: - to Entity

extension RecordResponseDTO {
	func toEntity() -> RecordEntity {
		return .init(uid: uid ?? "",
								 content: content ?? "",
								 emotionType: EmotionType(rawValue: emotion_type ?? "") ?? .none,
								 imageListURL: image_list ?? [],
								 imageIdentifiers: image_identifier ?? [],
								 createTime: create_time ?? 0,
								 calendarDate: calendar_date ?? 0)
	}
}
