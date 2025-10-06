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
    formatter.locale = Locale.current
    formatter.timeZone = TimeZone.current
    return formatter
  }()
  
  static func formattedString(
    _ date: Date,
    format: String
  ) -> String {
    shared.dateFormat = format
    return shared.string(from: date)
  }
  
  static func localizedYearMonth(_ date: Date) -> String {
    let calendar = Calendar.current
    let year = String(calendar.component(.year, from: date))

    let isKorean = Locale.current.language.languageCode?.identifier == "ko"

    if isKorean {
      let month = String(calendar.component(.month, from: date))
      return L10n.Date.yearMonth(year, month)
    } else {
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale.current
      dateFormatter.dateFormat = "MMM"
      let monthAbbr = dateFormatter.string(from: date)
      return "\(monthAbbr) \(year)"
    }
  }
}
