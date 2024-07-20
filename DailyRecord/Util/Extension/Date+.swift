//
//  Date+.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/13/24.
//

import Foundation

extension Date {
	var millisecondsSince1970: Int64 {
		Int64((self.timeIntervalSince1970 * 1000.0).rounded())
	}
	
	init(milliseconds: Int64) {
		self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
	}
}
