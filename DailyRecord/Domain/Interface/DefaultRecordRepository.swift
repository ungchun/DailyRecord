//
//  DefaultRecordRepository.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Foundation

protocol DefaultRecordRepository {
	func createRecord(data: [String : Any]) async throws
}
