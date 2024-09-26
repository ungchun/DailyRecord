//
//  CalendarRepository.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/13/24.
//

import CoreData

final class CalendarRepository: DefaultCalendarRepository {
  private let coreDataManager = CoreDataManager.shared
}

extension CalendarRepository {
  func readMonthRecord(year: Int, month: Int) throws -> [RecordEntity] {
    let context = coreDataManager.context
    
    // 월의 시작과 끝을 설정
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = 1
    let calendar = Calendar.current
    
    guard let startOfMonth = calendar.date(from: components) else {
      throw NSError()
    }
    
    components.month = month + 1
    components.day = 0
    
    guard let endOfMonth = calendar.date(from: components) else {
      throw NSError()
    }
    
    let startTimestamp = Int64(startOfMonth.timeIntervalSince1970 * 1000)
    let endTimestamp = Int64(endOfMonth.timeIntervalSince1970 * 1000) + 86399999
    
    let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
    fetchRequest.predicate = NSPredicate(
      format: "calendar_date > 0 AND calendar_date >= %lld AND calendar_date <= %lld",
      startTimestamp, endTimestamp
    )
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "calendar_date", ascending: true)]
    
    do {
      let records = try context.fetch(fetchRequest)
      return records.compactMap { record in
        return RecordEntity(
          content: record.content ?? "",
          emotionType: record.emotion_type ?? "",
          imageList: record.image_list as? [Data] ?? [],
          imageIdentifier: record.image_identifier as? [String] ?? [],
          createTime: Int(record.create_time),
          calendarDate: Int(record.calendar_date)
        )
      }
    } catch {
      throw error
    }
  }
}
