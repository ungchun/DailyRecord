//
//  RecordViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/15/24.
//

import Foundation

final class RecordViewModel: BaseViewModel {
	
	// MARK: - Properties
	
	let selectDate: Date
	
	init(
		selectDate: Date
	) {
		self.selectDate = selectDate
	}
}
