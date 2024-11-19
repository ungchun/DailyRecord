//
//  Widget.swift
//  Widget
//
//  Created by Kim SungHun on 9/21/24.
//

import WidgetKit
import SwiftUI
import CoreData

// MARK: - TimelineProvider

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    let calendar = Calendar.current
    let today = Date()
    let weekday = calendar.component(.weekday, from: today)
    let daysToSubtract = weekday - 1 // 1은 일요일
    
    let startOfWeek = calendar.date(
      byAdding: .day, value: -daysToSubtract, to: today
    )
    
    let startOfDay = calendar.startOfDay(for: startOfWeek ?? Date())
    let startTimestamp = String(Int(startOfDay.timeIntervalSince1970 * 1000))
    
    let todayStartOfDay = calendar.startOfDay(for: today)
    let todayStartTimestamp = String(Int(todayStartOfDay.timeIntervalSince1970 * 1000))
    
    let dayOfWeekPart = formattedDateString(today, format: "EEEE")
    let day = formattedDateString(today, format: "dd")
    
    return SimpleEntry(
      date: Date(),
      weekRecords: [],
      weekStartDate: startTimestamp,
      todayStartDate: todayStartTimestamp,
      currentWeekday: dayOfWeekPart,
      currentDayOfMonth: day
    )
  }
  
  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let calendar = Calendar.current
    let today = Date()
    let weekday = calendar.component(.weekday, from: today)
    let daysToSubtract = weekday - 1 // 1은 일요일
    
    let startOfWeek = calendar.date(
      byAdding: .day, value: -daysToSubtract, to: today
    )
    
    let startOfDay = calendar.startOfDay(for: startOfWeek ?? Date())
    let startTimestamp = String(Int(startOfDay.timeIntervalSince1970 * 1000))
    
    let todayStartOfDay = calendar.startOfDay(for: today)
    let todayStartTimestamp = String(Int(todayStartOfDay.timeIntervalSince1970 * 1000))
    
    let dayOfWeekPart = formattedDateString(today, format: "EEEE")
    let day = formattedDateString(today, format: "dd")
    
    let entry = SimpleEntry(
      date: Date(),
      weekRecords: [],
      weekStartDate: startTimestamp,
      todayStartDate: todayStartTimestamp,
      currentWeekday: dayOfWeekPart,
      currentDayOfMonth: day
    )
    completion(entry)
  }
  
  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let calendar = Calendar.current
    let today = Date()
    let weekday = calendar.component(.weekday, from: today)
    let daysToSubtract = weekday - 1 // 1은 일요일
    
    guard let startOfWeek = calendar.date(
      byAdding: .day, value: -daysToSubtract, to: today
    ) else { return }
    
    let startOfDay = calendar.startOfDay(for: startOfWeek)
    let startTimestamp = String(Int(startOfDay.timeIntervalSince1970 * 1000))
    
    let todayStartOfDay = calendar.startOfDay(for: today)
    let todayStartTimestamp = String(Int(todayStartOfDay.timeIntervalSince1970 * 1000))
    
    let dayOfWeekPart = formattedDateString(today, format: "EEEE")
    let day = formattedDateString(today, format: "dd")
    
    Task {
      do {
        var entries: [SimpleEntry] = []
        let weekRecords = try await fetchCurrentWeekRecords()
        for hoursOffset in 0...1 {
          let entryDate = Calendar.current.date(byAdding: .hour,
                                                value: hoursOffset,
                                                to: Date())!
          let entry = SimpleEntry(
            date: entryDate,
            weekRecords: weekRecords,
            weekStartDate: startTimestamp,
            todayStartDate: todayStartTimestamp,
            currentWeekday: dayOfWeekPart,
            currentDayOfMonth: day
          )
          
          entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
      } catch {
        var entries: [SimpleEntry] = []
        for hoursOffset in 0...1 {
          let entryDate = Calendar.current.date(byAdding: .hour,
                                                value: hoursOffset,
                                                to: Date())!
          let entry = SimpleEntry(
            date: entryDate,
            weekRecords: [],
            weekStartDate: startTimestamp,
            todayStartDate: todayStartTimestamp,
            currentWeekday: dayOfWeekPart,
            currentDayOfMonth: day
          )
          
          entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
      }
    }
  }
}

private extension Provider {
  private func formattedDateString(_ date: Date, format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_kr")
    dateFormatter.timeZone = TimeZone(identifier: "KST")
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
  }
  
  private func fetchCurrentWeekRecords() async throws -> [RecordEntity] {
    let context = CoreDataManager.shared.context
    let calendar = Calendar.current
    
    // 현재 날짜의 주의 시작(일요일)과 끝(토요일) 계산
    let today = Date()
    let weekday = calendar.component(.weekday, from: today)
    let daysToSubtract = weekday - 1 // 1은 일요일
    
    guard let startOfWeek = calendar.date(byAdding: .day,
                                          value: -daysToSubtract,
                                          to: today),
          let endOfWeek = calendar.date(byAdding: .day,
                                        value: 6 - daysToSubtract,
                                        to: today) else {
      throw NSError()
    }
    
    let startOfDay = calendar.startOfDay(for: startOfWeek)
    let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfWeek)!
    
    let startTimestamp = Int(startOfDay.timeIntervalSince1970 * 1000)
    let endTimestamp = Int(endOfDay.timeIntervalSince1970 * 1000)
    
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

// MARK: - TimelineEntry

struct SimpleEntry: TimelineEntry {
  let date: Date
  
  let weekRecords: [RecordEntity]
  let weekStartDate: String  // 주의 시작 날짜 (일요일)
  let todayStartDate: String  // 오늘 날짜
  let currentWeekday: String // 현재 요일 (예: "일", "월", "화" 등)
  let currentDayOfMonth: String // 현재 일자 (1~31)
}

// MARK: - WidgetEntryView

struct WidgetEntryView : View {
  @Environment(\.widgetFamily) private var widgetFamily
  
  var entry: Provider.Entry
  
  var body: some View {
    switch widgetFamily {
    case .systemSmall:
      systemSmallView()
    case .systemMedium:
      systemMediumView()
    default:
      EmptyView()
    }
  }
}

private extension WidgetEntryView {
  @ViewBuilder
  func systemSmallView() -> some View {
    let todayRecord = entry.weekRecords.filter{
      $0.calendarDate == Int(entry.todayStartDate)
    }
    
    // 비어있거나, 감정표현 X
    if todayRecord.isEmpty || (todayRecord.first?.emotionType ?? "").isEmpty {
      ZStack(alignment: .topLeading) {
        HStack {
          Text("\(entry.currentWeekday)")
            .font(.custom("omyu_pretty", size: 16))
            .foregroundColor(.azWhite)
            .lineLimit(1)
          Spacer()
        }
        
        VStack {
          Spacer()
          HStack {
            Spacer()
            Text("\(entry.currentDayOfMonth)")
              .font(.custom("omyu_pretty", size: 40))
              .foregroundColor(.azWhite)
              .lineLimit(1)
            Spacer()
          }
          Spacer()
        }
      }
    } else {
      // 감정표현 O
      ZStack(alignment: .topLeading) {
        HStack {
          VStack(alignment: .leading) {
            Text("\(entry.currentWeekday)")
              .font(.custom("omyu_pretty", size: 16))
              .foregroundColor(.azWhite)
              .lineLimit(1)
            Text("\(entry.currentDayOfMonth)")
              .font(.custom("omyu_pretty", size: 16))
              .foregroundColor(.azWhite)
              .lineLimit(1)
          }
          Spacer()
        }
        
        VStack {
          Spacer()
          HStack {
            Spacer()
            Image(todayRecord.first?.emotionType ?? "")
              .resizable()
              .frame(width: 60, height: 60)
            Spacer()
          }
          Spacer()
        }
      }
    }
  }
  
  @ViewBuilder
  func systemMediumView() -> some View {
    let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    let weekDates = getWeekDates()
    let today = Calendar.current.startOfDay(for: Date())
    
    VStack(spacing: 20) {
      Text(formatCurrentYearMonth())
        .font(.custom("omyu_pretty", size: 20))
        .foregroundColor(.azWhite)
        .lineLimit(1)
      
      HStack(spacing: 0) {
        ForEach(Array(zip(weekdays, weekDates)), id: \.0) { day, dateInfo in
          let isToday = Calendar.current.isDate(dateInfo.date, inSameDayAs: today)
          let emotion = getEmotionForDate(date: dateInfo.date)
          
          VStack(spacing: 20) {
            Text(day)
              .font(.custom("omyu_pretty", size: 16))
              .foregroundColor(day == "일" ? .azRed : day == "토" ? .azBlue : .azWhite)
              .lineLimit(1)
            
            ZStack {
              if emotion.isEmpty {
                Text(dateInfo.day)
                  .font(.custom("omyu_pretty", size: 16))
                  .foregroundColor(isToday
                                   ? .azWhite
                                   : .azLightGray.opacity(0.5))
                  .lineLimit(1)
              } else {
                Image(emotion)
                  .resizable()
                  .scaledToFit()
                  .frame(width: 30, height: 30)
              }
              
              if emotion.isEmpty && isToday {
                Rectangle()
                  .fill(.azLightGray.opacity(0.2))
                  .frame(width: 30, height: 10)
                  .offset(y: 8)
              }
            }
            .frame(height: 30)
          }
          .frame(maxWidth: .infinity)
        }
      }
    }
  }
}

private extension WidgetEntryView {
  func formatCurrentYearMonth() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.dateFormat = "yyyy년 M월"
    return dateFormatter.string(from: entry.date)
  }
  
  func getWeekDates() -> [(day: String, date: Date)] {
    let calendar = Calendar.current
    let weekday = calendar.component(.weekday, from: entry.date)
    let daysToSubtract = weekday - 1 // 1은 일요일
    
    guard let startOfWeek = calendar.date(
      byAdding: .day, value: -daysToSubtract, to: entry.date
    ) else {
      return []
    }
    
    return (0...6).compactMap { dayOffset in
      guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else {
        return nil
      }
      let day = String(calendar.component(.day, from: date))
      return (day: day, date: date)
    }
  }
  
  func getEmotionForDate(date: Date) -> String {
    let calendar = Calendar.current
    guard let startOfDay = calendar.startOfDay(for: date) as Date?,
          let endOfDay = calendar.date(
            bySettingHour: 23, minute: 59, second: 59, of: date
          ) else {
      return ""
    }
    
    let startTimestamp = Int(startOfDay.timeIntervalSince1970 * 1000)
    let endTimestamp = Int(endOfDay.timeIntervalSince1970 * 1000)
    
    for record in entry.weekRecords {
      if !record.emotionType.isEmpty,
         record.calendarDate >= startTimestamp && record.calendarDate <= endTimestamp {
        return record.emotionType
      }
    }
    
    return ""
  }
}

// MARK: - Widget

struct DailyRecordWidget: Widget {
  let kind: String = "Widget"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      if #available(iOS 17.0, *) {
        WidgetEntryView(entry: entry)
          .containerBackground(.fill.tertiary, for: .widget)
      } else {
        WidgetEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("투데이 위젯")
    .description("위젯으로 다온 일기를 한눈에 파악할 수 있어요!")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
