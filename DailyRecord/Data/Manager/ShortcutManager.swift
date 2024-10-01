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
    AppShortcut(intent: OpenAppIntent(),
                phrases: ["오늘 일기 쓰기 \(.applicationName)"],
                shortTitle: "오늘 일기 쓰기",
                systemImageName: "pencil.circle")
  }
}

struct OpenAppIntent: AppIntent {
  static var title: LocalizedStringResource = "오늘 일기 쓰기"
  static var description = IntentDescription("오늘 일기 쓰기 설명")
  
  static var openAppWhenRun: Bool = true
  
  @MainActor
  func perform() async throws -> some IntentResult {
    ShortcutManager.shared.delegate?.shortcutShowTodayRecordTrigger()
    return .result()
  }
}
