//
//  CalenderUseCase.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/13/24.
//

import Foundation

protocol DefaultCalenderUseCase {
	func readMonthRecord() async throws -> [RecordEntity]
}

final class CalenderUseCase: DefaultCalenderUseCase {
	let calenderRepository: DefaultCalenderRepository
	
	init(calenderRepository: DefaultCalenderRepository) {
		self.calenderRepository = calenderRepository
	}
}

extension CalenderUseCase {
	func readMonthRecord() async throws -> [RecordEntity] {
		return try await calenderRepository.readMonthRecord().map{$0.toEntity()}
	}
}
