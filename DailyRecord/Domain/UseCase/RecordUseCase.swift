//
//  RecordUseCase.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Foundation

protocol DefaultRecordUseCase {
	
}

final class RecordUseCase: DefaultRecordUseCase {
	let recordRepository: DefaultRecordRepository
	
	init(recordRepository: DefaultRecordRepository) {
		self.recordRepository = recordRepository
	}
}
