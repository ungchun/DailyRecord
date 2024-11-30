//
//  DateFormatter+.swift
//  DailyRecord
//
//  Created by Kim SungHun on 11/30/24.
//

import Foundation

extension DateFormatter {
  static let shared: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_kr")
    formatter.timeZone = TimeZone(identifier: "KST")
    return formatter
  }()
  
  static func formattedString(
    _ date: Date,
    format: String
  ) -> String {
    shared.dateFormat = format
    return shared.string(from: date)
  }
}
