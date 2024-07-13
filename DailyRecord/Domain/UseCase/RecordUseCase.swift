//
//  RecordUseCase.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Foundation

protocol DefaultRecordUseCase {
	func createRecord(data: [String : Any]) async throws
}

final class RecordUseCase: DefaultRecordUseCase {
	let recordRepository: DefaultRecordRepository
	
	init(recordRepository: DefaultRecordRepository) {
		self.recordRepository = recordRepository
	}
}

extension RecordUseCase {
	func createRecord(data: [String : Any]) async throws {
		try await recordRepository.createRecord(data: data)
	}
}
