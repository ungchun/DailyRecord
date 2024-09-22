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

struct RecordResponseDTO: Decodable {
	let uid: String?
	let content: String?
	let emotion_type: String?
	let image_list: [String]?
	let image_identifier: [String]?
	let create_time: Int?
	let calendar_date: Int?
}

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
		
		guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today),
					let endOfWeek = calendar.date(byAdding: .day, value: 6 - daysToSubtract, to: today) else {
			return
		}
		
		// 시작 날짜를 00:00:00으로, 종료 날짜를 23:59:59로 설정
		let startOfDay = calendar.startOfDay(for: startOfWeek)
		let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfWeek)!
		
		let startTimestamp = String(Int(startOfDay.timeIntervalSince1970 * 1000))
		let endTimestamp = String(Int(endOfDay.timeIntervalSince1970 * 1000))
		
		let dayOfWeekPart = formattedDateString(today, format: "EEEE")
		let day = formattedDateString(today, format: "dd")
		
		if let userID = Auth.auth().currentUser?.uid {
			
			Task {
				do {
					var entries: [SimpleEntry] = []
					let weekRecords = try await fetchCurrentWeekRecords(userID: userID)
					for hoursOffset in 0...1 {
						let entryDate = Calendar.current.date(byAdding: .hour, value: hoursOffset, to: Date())!
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
						let entryDate = Calendar.current.date(byAdding: .hour, value: hoursOffset, to: Date())!
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
		
		guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today),
					let endOfWeek = calendar.date(byAdding: .day, value: 6 - daysToSubtract, to: today) else {
			throw NSError()
		}
		
		// 시작 날짜를 00:00:00으로, 종료 날짜를 23:59:59로 설정
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
							let recordResponse = try JSONDecoder().decode(RecordResponseDTO.self, from: jsonData)
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

struct SimpleEntry: TimelineEntry {
	let date: Date
	
	let weekRecords: [RecordResponseDTO]
	let weekStartDate: String  // 주의 시작 날짜 (일요일)
	let currentWeekday: String // 현재 요일 (예: "일", "월", "화" 등)
	let currentDayOfMonth: String // 현재 일자 (1~31)
}

struct WidgetEntryView : View {
	@Environment(\.widgetFamily) private var widgetFamily
	
	var entry: Provider.Entry
	
	var body: some View {
		switch widgetFamily {
		case .systemSmall:
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
		case .systemMedium:
			EmptyView()
		default:
			EmptyView()
		}
	}
}

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
