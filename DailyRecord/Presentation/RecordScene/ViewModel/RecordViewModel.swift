//
//  RecordViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/15/24.
//

import Foundation

final class RecordViewModel: BaseViewModel {
	
	// MARK: - Properties
	
	private let recordUseCase: DefaultRecordUseCase
	
	let selectDate: Date
	
	// MARK: - Init
	
	init(
		recordUseCase: DefaultRecordUseCase,
		selectDate: Date
	) {
		self.recordUseCase = recordUseCase
		self.selectDate = selectDate
	}
}
