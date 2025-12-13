//
//  ProfileViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/1/24.
//

import AuthenticationServices
import CryptoKit
import StoreKit
import UIKit
import UserNotifications
import WidgetKit

final class ProfileViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: ProfileCoordinator?
  
  private let viewModel: ProfileViewModel
  private let calendarViewModel: CalendarViewModel
  
  private let appStoreID = "6664067346"
  
  // MARK: - Views
  
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 20
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  private let topDivider: UIView = {
    let view = UIView()
    view.backgroundColor = .azGray400
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let bottomDivider: UIView = {
    let view = UIView()
    view.backgroundColor = .azGray400
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let dailyReminderIcon: UIImageView = {
    let imageView = UIImageView()
    let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .default)
    imageView.image = UIImage(systemName: "bell", withConfiguration: config)
    imageView.tintColor = .azGray900
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let dailyReminderLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.Diary.Notification.title
    label.font = UIFont.appFont(size: 18)
    label.textColor = .azGray900
    return label
  }()
  
  private lazy var dailyReminderToggle: UISwitch = {
    let toggle = UISwitch()
    toggle.isOn = UserDefaultsSetting.isDailyReminderEnabled
    toggle.onTintColor = .azGray900
    toggle.thumbTintColor = .azGray50
    toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    toggle.addTarget(self, action: #selector(dailyReminderToggleChanged), for: .valueChanged)
    return toggle
  }()
  
  private lazy var dailyReminderStackView: UIStackView = {
    let spacer = UIView()
    let stackView = UIStackView(
      arrangedSubviews: [
        dailyReminderIcon,
        dailyReminderLabel,
        spacer,
        dailyReminderToggle
      ]
    )
    stackView.axis = .horizontal
    stackView.spacing = 10
    stackView.alignment = .center
    return stackView
  }()
  
  private let reminderTimeIcon: UIImageView = {
    let imageView = UIImageView()
    let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .default)
    imageView.image = UIImage(systemName: "clock", withConfiguration: config)
    imageView.tintColor = .azGray900
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let reminderTimeTextLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.Notification.Time.title
    label.font = UIFont.appFont(size: 18)
    label.textColor = .azGray900
    return label
  }()
  
  private let reminderTimeLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.appFont(size: 18)
    label.textColor = .azGray500
    label.textAlignment = .right
    return label
  }()
  
  private lazy var reminderTimeStackView: UIStackView = {
    let spacer = UIView()
    let stackView = UIStackView(
      arrangedSubviews: [
        reminderTimeIcon,
        reminderTimeTextLabel,
        spacer,
        reminderTimeLabel
      ]
    )
    stackView.axis = .horizontal
    stackView.spacing = 10
    stackView.alignment = .center
    stackView.isUserInteractionEnabled = true
    return stackView
  }()
  
  private lazy var screenLockButton: UIButton = self.createButton(for: .screenLock)
  private lazy var iCloudButton: UIButton = self.createButton(for: .iCloud)
  private lazy var darkModeButton: UIButton = self.createButton(for: .darkMode)
  private lazy var musicChangeButton: UIButton = self.createButton(for: .musicChange)
  private lazy var fontChangeButton: UIButton = self.createButton(for: .fontChange)
  private lazy var pdfExportButton: UIButton = self.createButton(for: .pdfExport)
  private lazy var languageButton: UIButton = self.createButton(for: .language)
  private lazy var appRatingButton: UIButton = self.createButton(for: .appRating)
  private lazy var contactButton: UIButton = self.createButton(for: .contact)
  
  // MARK: - Init
  
  init(
    viewModel: ProfileViewModel,
    calendarViewModel: CalendarViewModel
  ) {
    self.viewModel = viewModel
    self.calendarViewModel = calendarViewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Amp.track(event: "screen_view", properties: ["screen_name": "profile"])
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    checkNotificationAuthorizationStatus()
  }
  
  // MARK: - Functions
  
  override func addView() {
    view.addSubview(stackView)
    
    [dailyReminderStackView,
     reminderTimeStackView,
     darkModeButton,
     musicChangeButton,
     fontChangeButton,
     topDivider,
     screenLockButton,
     iCloudButton,
     pdfExportButton,
     languageButton,
     bottomDivider,
     appRatingButton,
     contactButton].forEach {
      stackView.addArrangedSubview($0)
    }
  }
  
  override func setLayout() {
    stackView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    topDivider.snp.makeConstraints { make in
      make.height.equalTo(1)
    }
    
    bottomDivider.snp.makeConstraints { make in
      make.height.equalTo(1)
    }
    
    dailyReminderIcon.snp.makeConstraints { make in
      make.width.equalTo(28)
    }
    
    reminderTimeIcon.snp.makeConstraints { make in
      make.width.equalTo(28)
    }
    
    stackView.setCustomSpacing(14, after: dailyReminderStackView)

    stackView.setCustomSpacing(20, after: darkModeButton)
    stackView.setCustomSpacing(20, after: fontChangeButton)
    stackView.setCustomSpacing(20, after: topDivider)
    stackView.setCustomSpacing(20, after: languageButton)
    stackView.setCustomSpacing(20, after: bottomDivider)
  }
  
  override func setupView() {
    view.backgroundColor = .azGray50
    
    let tapGesture = UITapGestureRecognizer(
      target: self, action: #selector(reminderTimeButtonTapped)
    )
    reminderTimeStackView.addGestureRecognizer(tapGesture)
    
    updateReminderTimeDisplay()
    updateReminderTimeButtonVisibility()
  }
  
  private func createButton(for item: ProfileCellItem) -> UIButton {
    var configuration = UIButton.Configuration.plain()
    configuration.title = item.title
    configuration.titleTextAttributesTransformer
    = UIConfigurationTextAttributesTransformer { incoming in
      var outgoing = incoming
      outgoing.font = UIFont.appFont(size: 18)
      return outgoing
    }
    
    configuration.baseForegroundColor = .azGray900
    
    let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .default)
    if let symbolImage = UIImage(systemName: item.iconName, withConfiguration: config) {
      let iconWidth: CGFloat = 28
      let renderer = UIGraphicsImageRenderer(size: CGSize(width: iconWidth, height: symbolImage.size.height))
      let fixedWidthImage = renderer.image { context in
        let x = (iconWidth - symbolImage.size.width) / 2
        symbolImage.draw(at: CGPoint(x: x, y: 0))
      }
      configuration.image = fixedWidthImage.withRenderingMode(.alwaysTemplate)
    }
    configuration.imagePadding = 10
    configuration.imagePlacement = .leading
    configuration.contentInsets = NSDirectionalEdgeInsets(
      top: 0, leading: 0, bottom: 0, trailing: 0
    )
    
    let button = UIButton(configuration: configuration)
    button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    button.contentHorizontalAlignment = .leading

    return button
  }

  override func updateFontsAfterChange() {
    dailyReminderLabel.font = UIFont.appFont(size: 18)
    reminderTimeTextLabel.font = UIFont.appFont(size: 18)
    reminderTimeLabel.font = UIFont.appFont(size: 18)
  }
}

extension ProfileViewController {
  @objc private func buttonTapped(_ sender: UIButton) {
    if sender == screenLockButton {
      screenLockTrigger()
    } else if sender == iCloudButton {
      iCloudTrigger()
    } else if sender == darkModeButton {
      darkModeTrigger()
    } else if sender == musicChangeButton {
      musicChangeTrigger()
    } else if sender == fontChangeButton {
      fontChangeTrigger()
    } else if sender == pdfExportButton {
      pdfExportTrigger()
    } else if sender == languageButton {
      languageTrigger()
    } else if sender == appRatingButton {
      openAppStore()
    } else if sender == contactButton {
      openEmail()
    }
  }
  
  @objc private func dailyReminderToggleChanged(_ sender: UISwitch) {
    if sender.isOn {
      // 알림 켜기 - 권한 확인 후 처리
      let center = UNUserNotificationCenter.current()
      center.getNotificationSettings { settings in
        DispatchQueue.main.async {
          if settings.authorizationStatus == .authorized {
            // 권한 허용됨 - 알림 등록
            UserDefaultsSetting.isDailyReminderEnabled = true
            self.updateReminderTimeButtonVisibility()
            self.scheduleDailyNotification()
            Amp.track(event: "daily_reminder_toggle", properties: ["enabled": true])
          } else if settings.authorizationStatus == .notDetermined {
            // 최초 요청 - 권한 요청 alert 표시
            self.requestNotificationPermission()
          } else {
            // 권한 거부됨 - 토글 OFF로 유지하고 설정으로 이동 안내
            sender.isOn = false
            UserDefaultsSetting.isDailyReminderEnabled = false
            self.showNotificationSettingsAlert()
          }
        }
      }
    } else {
      // 알림 끄기
      UserDefaultsSetting.isDailyReminderEnabled = false
      updateReminderTimeButtonVisibility()
      cancelDailyNotification()
      Amp.track(event: "daily_reminder_toggle", properties: ["enabled": false])
    }
  }
  
  @objc private func reminderTimeButtonTapped() {
    Amp.track(event: "button_click", properties: ["button_name": "reminder_time"])
    showTimePicker()
  }
  
  private func updateReminderTimeDisplay() {
    let timeString = UserDefaultsSetting.dailyReminderTime
    let components = timeString.split(separator: ":")
    if components.count == 2,
       let hour = Int(components[0]),
       let minute = Int(components[1]) {
      var dateComponents = DateComponents()
      dateComponents.hour = hour
      dateComponents.minute = minute
      
      if let date = Calendar.current.date(from: dateComponents) {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale.current
        reminderTimeLabel.text = formatter.string(from: date)
      }
    }
  }
  
  private func updateReminderTimeButtonVisibility() {
    reminderTimeStackView.isHidden = !UserDefaultsSetting.isDailyReminderEnabled
  }
  
  private func showTimePicker() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .time
    datePicker.preferredDatePickerStyle = .wheels
    datePicker.locale = Locale.current
    
    let timeString = UserDefaultsSetting.dailyReminderTime
    let components = timeString.split(separator: ":")
    if components.count == 2,
       let hour = Int(components[0]),
       let minute = Int(components[1]) {
      var dateComponents = DateComponents()
      dateComponents.hour = hour
      dateComponents.minute = minute
      if let date = Calendar.current.date(from: dateComponents) {
        datePicker.date = date
      }
    }
    
    let vc = UIViewController()
    vc.view = datePicker
    vc.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 250)
    
    alert.setValue(vc, forKey: "contentViewController")
    
    let confirmAction = UIAlertAction(
      title: L10n.Common.confirm, style: .default
    ) { [weak self] _ in
      let calendar = Calendar.current
      let components = calendar.dateComponents([.hour, .minute], from: datePicker.date)
      if let hour = components.hour, let minute = components.minute {
        let timeString = String(format: "%02d:%02d", hour, minute)
        UserDefaultsSetting.dailyReminderTime = timeString
        self?.updateReminderTimeDisplay()
        Amp.track(event: "reminder_time_set", properties: ["time": timeString])
        
        if UserDefaultsSetting.isDailyReminderEnabled {
          self?.scheduleDailyNotification()
        }
      }
    }
    
    let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: nil)
    
    alert.addAction(confirmAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  private func screenLockTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "screen_lock"])
    coordinator?.showSetScreenLock()
  }
  
  private func iCloudTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "icloud"])
    coordinator?.showSetiCloud()
  }
  
  private func darkModeTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "dark_mode"])
    coordinator?.showSetDarkmode()
  }
  
  private func musicChangeTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "music_change"])
    coordinator?.showMusicChange()
  }

  private func fontChangeTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "font_change"])
    coordinator?.showFontChange()
  }

  private func pdfExportTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "pdf_export"])
    coordinator?.showPdfExport()
  }

  private func languageTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "language"])
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  private func openAppStore() {
    Amp.track(event: "button_click", properties: ["button_name": "app_rating"])
    let urlStr = "https://itunes.apple.com/app/id\(appStoreID)?action=write-review"
    if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  private func openEmail() {
    Amp.track(event: "button_click", properties: ["button_name": "contact"])
    let email = "leedool3003@gmail.com"
    if let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
}

extension ProfileViewController {
  private func checkNotificationAuthorizationStatus() {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { settings in
      DispatchQueue.main.async {
        if settings.authorizationStatus == .denied {
          if UserDefaultsSetting.isDailyReminderEnabled {
            self.dailyReminderToggle.isOn = false
            UserDefaultsSetting.isDailyReminderEnabled = false
            self.updateReminderTimeButtonVisibility()
          }
        }
      }
    }
  }
  
  private func requestNotificationPermission() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      DispatchQueue.main.async {
        if granted {
          UserDefaultsSetting.isDailyReminderEnabled = true
          self.updateReminderTimeButtonVisibility()
          self.scheduleDailyNotification()
        } else {
          self.dailyReminderToggle.isOn = false
          UserDefaultsSetting.isDailyReminderEnabled = false
          self.updateReminderTimeButtonVisibility()
        }
      }
    }
  }
  
  private func scheduleDailyNotification() {
    let center = UNUserNotificationCenter.current()
    
    center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    
    guard UserDefaultsSetting.isDailyReminderEnabled else { return }
    
    let content = UNMutableNotificationContent()
    content.title = L10n.App.name
    content.body = L10n.Diary.question
    content.sound = .default
    
    let timeString = UserDefaultsSetting.dailyReminderTime
    let components = timeString.split(separator: ":")
    guard components.count == 2,
          let hour = Int(components[0]),
          let minute = Int(components[1]) else { return }
    
    var dateComponents = DateComponents()
    dateComponents.hour = hour
    dateComponents.minute = minute
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    
    let request = UNNotificationRequest(
      identifier: "dailyReminder",
      content: content,
      trigger: trigger
    )
    
    // 알림 등록
    center.add(request) { error in
      if error != nil {
        
      } else {
        Amp.track(event: "daily_reminder_scheduled", properties: ["time": timeString])
      }
    }
  }
  
  private func cancelDailyNotification() {
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    Amp.track(event: "daily_reminder_cancelled")
  }
  
  private func showNotificationSettingsAlert() {
    let alert = UIAlertController(
      title: L10n.Notification.Permission.title,
      message: L10n.Notification.Permission.message,
      preferredStyle: .alert
    )
    
    let settingsAction = UIAlertAction(
      title: L10n.Notification.Permission.action, style: .default
    ) { _ in
      if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
      }
    }
    
    let cancelAction = UIAlertAction(
      title: L10n.Common.cancel, style: .cancel
    ) { [weak self] _ in
      self?.dailyReminderToggle.isOn = false
      UserDefaultsSetting.isDailyReminderEnabled = false
    }
    
    alert.addAction(settingsAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true)
  }
}
