//
//  Widget.swift
//  Widget
//
//  Created by Kim SungHun on 9/21/24.
//

import WidgetKit
import SwiftUI

import Firebase
import FirebaseFirestore

// MARK: - Response

struct RecordResponseDTO: Decodable {
	let uid: String?
	let content: String?
	let emotion_type: String?
	let image_list: [String]?
	let image_identifier: [String]?
	let create_time: Int?
	let calendar_date: Int?
}

// MARK: - TimelineProvider

struct Provider: TimelineProvider {
	func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(
			date: Date(),
			weekRecords: [],
			weekStartDate: "",
			currentWeekday: "",
			currentDayOfMonth: ""
		)
	}
	
	func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
		let entry = SimpleEntry(
			date: Date(),
			weekRecords: [],
			weekStartDate: "",
			currentWeekday: "",
			currentDayOfMonth: ""
		)
		completion(entry)
	}
	
	func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
		let calendar = Calendar.current
		let today = Date()
		let weekday = calendar.component(.weekday, from: today)
		let daysToSubtract = weekday - 1 // 1은 일요일
		
		guard let startOfWeek = calendar.date(byAdding: .day,
																					value: -daysToSubtract,
																					to: today),
					let endOfWeek = calendar.date(byAdding: .day,
																				value: 6 - daysToSubtract,
																				to: today) else {
			return
		}
		
		let startOfDay = calendar.startOfDay(for: startOfWeek)
		let startTimestamp = String(Int(startOfDay.timeIntervalSince1970 * 1000))
		
		let dayOfWeekPart = formattedDateString(today, format: "EEEE")
		let day = formattedDateString(today, format: "dd")
		
		if let userID = Auth.auth().currentUser?.uid {
			Task {
				do {
					var entries: [SimpleEntry] = []
					let weekRecords = try await fetchCurrentWeekRecords(userID: userID)
					for hoursOffset in 0...1 {
						let entryDate = Calendar.current.date(byAdding: .hour,
																									value: hoursOffset,
																									to: Date())!
						let entry = SimpleEntry(
							date: entryDate,
							weekRecords: weekRecords,
							weekStartDate: startTimestamp,
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
}

private extension Provider {
	private func formattedDateString(_ date: Date, format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "ko_kr")
		dateFormatter.timeZone = TimeZone(identifier: "KST")
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: date)
	}
	
	private func fetchCurrentWeekRecords(userID: String) async throws -> [RecordResponseDTO] {
		let db = Firestore.firestore()
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
		
		let documentRef = db.collection("user").document(userID).collection("record")
		let query = documentRef
			.whereField("calendar_date", isGreaterThanOrEqualTo: startTimestamp)
			.whereField("calendar_date", isLessThanOrEqualTo: endTimestamp)
		
		return try await withCheckedThrowingContinuation { continuation in
			query.getDocuments { (querySnapshot, error) in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					do {
						var records: [RecordResponseDTO] = []
						for document in querySnapshot!.documents {
							let data = document.data()
							let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
							let recordResponse = try JSONDecoder().decode(RecordResponseDTO.self,
																														from: jsonData)
							records.append(recordResponse)
						}
						continuation.resume(returning: records)
					} catch {
						continuation.resume(throwing: error)
					}
				}
			}
		}
	}
}

// MARK: - TimelineEntry

struct SimpleEntry: TimelineEntry {
	let date: Date
	
	let weekRecords: [RecordResponseDTO]
	let weekStartDate: String  // 주의 시작 날짜 (일요일)
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
			$0.calendar_date ?? 0 == Int(entry.weekStartDate)
		}
		
		// 비어있거나, 감정표현 X
		if todayRecord.isEmpty || (todayRecord.first?.emotion_type ?? "").isEmpty {
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
						Image(entry.weekRecords.first?.emotion_type ?? "")
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
		let today = Calendar.current.component(.day, from: Date())
		
		VStack(spacing: 20) {
			Text(formatCurrentYearMonth())
				.font(.custom("omyu_pretty", size: 20))
				.foregroundColor(.azWhite)
				.lineLimit(1)
			
			HStack(spacing: 0) {
				ForEach(Array(zip(weekdays, weekDates)), id: \.0) { day, date in
					let isToday = Int(date) == today
					let emotion = getEmotionForDate(date: date)
					
					VStack(spacing: 20) {
						Text(day)
							.font(.custom("omyu_pretty", size: 16))
							.foregroundColor(day == "일" ? .azRed : day == "토" ? .azBlue : .azWhite)
							.lineLimit(1)
						
						ZStack {
							if emotion.isEmpty {
								Text("\(date)")
									.font(.custom("omyu_pretty", size: 16))
									.foregroundColor(isToday ? .azWhite : .azLightGray.opacity(0.5))
									.lineLimit(1)
							} else {
								Image(emotion)
									.resizable()
									.scaledToFit()
									.frame(width: 30, height: 30)
							}
							
							if emotion.isEmpty && isToday {
								Rectangle()
									.fill(.azLightGray.opacity(0.5))
									.frame(width: 30, height: 10)
									.offset(y: 20)
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
	
	func getWeekDates() -> [String] {
		let calendar = Calendar.current
		let weekday = calendar.component(.weekday, from: entry.date)
		let daysToSubtract = weekday - 1 // 1은 일요일
		
		guard let startOfWeek = calendar.date(
			byAdding: .day, value: -daysToSubtract, to: entry.date
		) else {
			return []
		}
		
		return (0...6).map { dayOffset in
			guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else {
				return ""
			}
			return String(calendar.component(.day, from: date))
		}
	}
	
	func getEmotionForDate(date: String) -> String {
		guard let day = Int(date),
					let startOfDay = Calendar.current.date(
						from: DateComponents(
							year: Calendar.current.component(.year, from: entry.date),
							month: Calendar.current.component(.month, from: entry.date),
							day: day
						)
					),
					let endOfDay = Calendar.current.date(
						bySettingHour: 23, minute: 59, second: 59, of: startOfDay
					) else {
			
			return ""
		}
		
		let startTimestamp = Int(startOfDay.timeIntervalSince1970 * 1000)
		let endTimestamp = Int(endOfDay.timeIntervalSince1970 * 1000)
		
		for record in entry.weekRecords {
			if let recordDate = record.calendar_date,
				 let emotionType = record.emotion_type,
				 !emotionType.isEmpty,
				 recordDate >= startTimestamp && recordDate <= endTimestamp {
				return emotionType
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
