// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum InfoPlist {
    /// Daon
    internal static let cfBundleDisplayName = L10n.tr("InfoPlist", "CFBundleDisplayName", fallback: "Daon")
  }
  internal enum Action {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "action.cancel", fallback: "Cancel")
    /// Delete
    internal static let confirmDelete = L10n.tr("Localizable", "action.confirm_delete", fallback: "Delete")
    /// Delete
    internal static let delete = L10n.tr("Localizable", "action.delete", fallback: "Delete")
    /// Edit
    internal static let edit = L10n.tr("Localizable", "action.edit", fallback: "Edit")
  }
  internal enum Alert {
    /// Are you sure you want to delete this diary?
    internal static let deleteDiaryMessage = L10n.tr("Localizable", "alert.delete_diary_message", fallback: "Are you sure you want to delete this diary?")
    /// Delete Diary
    internal static let deleteDiaryTitle = L10n.tr("Localizable", "alert.delete_diary_title", fallback: "Delete Diary")
  }
  internal enum Calendar {
    /// Today
    internal static let today = L10n.tr("Localizable", "calendar.today", fallback: "Today")
  }
  internal enum Common {
    /// Diary deleted!
    internal static let diaryDeleted = L10n.tr("Localizable", "common.diary_deleted", fallback: "Diary deleted!")
    /// Diary saved!
    internal static let diarySaved = L10n.tr("Localizable", "common.diary_saved", fallback: "Diary saved!")
    /// Empty
    internal static let empty = L10n.tr("Localizable", "common.empty", fallback: "Empty")
    /// An error occurred
    internal static let error = L10n.tr("Localizable", "common.error", fallback: "An error occurred")
    /// No diary entries
    internal static let noDiary = L10n.tr("Localizable", "common.no_diary", fallback: "No diary entries")
  }
  internal enum Daily {
    /// Daily
    internal static let title = L10n.tr("Localizable", "daily.title", fallback: "Daily")
  }
  internal enum Darkmode {
    /// Dark Mode
    internal static let darkMode = L10n.tr("Localizable", "darkmode.dark_mode", fallback: "Dark Mode")
    /// Light Mode
    internal static let lightMode = L10n.tr("Localizable", "darkmode.light_mode", fallback: "Light Mode")
    /// System Setting
    internal static let systemSetting = L10n.tr("Localizable", "darkmode.system_setting", fallback: "System Setting")
  }
  internal enum Date {
    /// %@ %@
    internal static func yearMonth(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "date.year_month", String(describing: p1), String(describing: p2), fallback: "%@ %@")
    }
  }
  internal enum Icloud {
    /// Daon can automatically backup/save to iCloud
    internal static let description = L10n.tr("Localizable", "icloud.description", fallback: "Daon can automatically backup/save to iCloud")
    /// Please note that syncing will not work if your iCloud storage is full
    internal static let storageWarning = L10n.tr("Localizable", "icloud.storage_warning", fallback: "Please note that syncing will not work if your iCloud storage is full")
    /// Settings > Apple Account > iCloud > Toggle on
    internal static let syncInstruction = L10n.tr("Localizable", "icloud.sync_instruction", fallback: "Settings > Apple Account > iCloud > Toggle on")
    /// Sync Method
    internal static let syncMethod = L10n.tr("Localizable", "icloud.sync_method", fallback: "Sync Method")
  }
  internal enum Mood {
    /// Mood
    internal static let title = L10n.tr("Localizable", "mood.title", fallback: "Mood")
  }
  internal enum Profile {
    /// Dark Mode
    internal static let darkMode = L10n.tr("Localizable", "profile.dark_mode", fallback: "Dark Mode")
    /// iCloud Sync
    internal static let icloudSync = L10n.tr("Localizable", "profile.icloud_sync", fallback: "iCloud Sync")
    /// Language
    internal static let language = L10n.tr("Localizable", "profile.language", fallback: "Language")
    /// Rate App
    internal static let rateApp = L10n.tr("Localizable", "profile.rate_app", fallback: "Rate App")
  }
  internal enum Record {
    /// How was your day today?
    internal static let howWasYourDay = L10n.tr("Localizable", "record.how_was_your_day", fallback: "How was your day today?")
  }
  internal enum Search {
    /// No results found
    internal static let noResults = L10n.tr("Localizable", "search.no_results", fallback: "No results found")
    /// Search diary
    internal static let placeholder = L10n.tr("Localizable", "search.placeholder", fallback: "Search diary")
  }
  internal enum Weekday {
    /// Fri
    internal static let friday = L10n.tr("Localizable", "weekday.friday", fallback: "Fri")
    /// Mon
    internal static let monday = L10n.tr("Localizable", "weekday.monday", fallback: "Mon")
    /// Sat
    internal static let saturday = L10n.tr("Localizable", "weekday.saturday", fallback: "Sat")
    /// Sun
    internal static let sunday = L10n.tr("Localizable", "weekday.sunday", fallback: "Sun")
    /// Thu
    internal static let thursday = L10n.tr("Localizable", "weekday.thursday", fallback: "Thu")
    /// Tue
    internal static let tuesday = L10n.tr("Localizable", "weekday.tuesday", fallback: "Tue")
    /// Wed
    internal static let wednesday = L10n.tr("Localizable", "weekday.wednesday", fallback: "Wed")
  }
  internal enum Widget {
    /// Check today's emotions
    internal static let todayDescription = L10n.tr("Localizable", "widget.today_description", fallback: "Check today's emotions")
    /// TODAY
    internal static let todayWidget = L10n.tr("Localizable", "widget.today_widget", fallback: "TODAY")
    /// Check this week's emotions
    internal static let weekDescription = L10n.tr("Localizable", "widget.week_description", fallback: "Check this week's emotions")
    /// WEEK
    internal static let weekWidget = L10n.tr("Localizable", "widget.week_widget", fallback: "WEEK")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
#if SWIFT_PACKAGE
    return Bundle.module
#else
    return Bundle(for: BundleToken.self)
#endif
  }()
}
// swiftlint:enable convenience_type
