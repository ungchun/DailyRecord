//
//  DefaultCalenderRepository.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/13/24.
//

import Foundation

protocol DefaultCalenderRepository {
	func readMonthRecord() async throws -> [RecordResponseDTO]
}
