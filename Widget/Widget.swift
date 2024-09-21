//
//  Widget.swift
//  Widget
//
//  Created by Kim SungHun on 9/21/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
	func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date())
	}
	
	func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
		let entry = SimpleEntry(date: Date())
		completion(entry)
	}
	
	func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
		var entries: [SimpleEntry] = []
		
		let currentDate = Date()
		for hourOffset in 0...1 {
			let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
			let entry = SimpleEntry(date: entryDate)
			entries.append(entry)
		}
		
		let timeline = Timeline(entries: entries, policy: .atEnd)
		completion(timeline)
	}
}

struct SimpleEntry: TimelineEntry {
	let date: Date
}

struct WidgetEntryView : View {
	@Environment(\.widgetFamily) private var widgetFamily
	
	var entry: Provider.Entry
	
	var body: some View {
		switch widgetFamily {
		case .systemSmall:
			VStack {
				Text("TODAY")
					.font(.custom("omyu_pretty", size: 20))
					.foregroundColor(.white)
				
				Circle()
					.fill(.yellow)
					.frame(width: 40, height: 40)
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
