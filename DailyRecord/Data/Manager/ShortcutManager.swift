//
//  ShortcutManager.swift
//  DailyRecord
//
//  Created by Kim SungHun on 10/1/24.
//

import UIKit
import AppIntents

protocol CalendarViewControllerDelegate: AnyObject {
  func shortcutShowTodayRecordTrigger()
}

final class ShortcutManager {
  static let shared = ShortcutManager()
  weak var delegate: CalendarViewControllerDelegate?
  
  private init() {}
}

final class ShortcutsProvider: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: OpenAppIntent(),
      phrases: [
        "Write Today's Diary with \(.applicationName)"
      ],
      shortTitle: "today.diary.write",
      systemImageName: "pencil.circle"
    )
  }
}

struct OpenAppIntent: AppIntent {
  static var title: LocalizedStringResource = "today.diary.write"
  static var description = IntentDescription("today.diary.description")
  
  static var openAppWhenRun: Bool = true
  
  @MainActor
  func perform() async throws -> some IntentResult {
    ShortcutManager.shared.delegate?.shortcutShowTodayRecordTrigger()
    return .result()
  }
}
