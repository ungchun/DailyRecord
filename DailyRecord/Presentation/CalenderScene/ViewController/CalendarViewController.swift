//
//  CalendarViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import UIKit
import Combine

import FSCalendar
import SnapKit

final class CalendarViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: CalendarCoordinator?
  
  private let coreDataManager: CoreDataManager = CoreDataManager.shared
  private let viewModel: CalendarViewModel
  
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Views
  
  private let settingButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
    let image = UIImage(systemName: "gearshape.fill", withConfiguration: config)
    button.setImage(image, for: .normal)
    button.tintColor = .azGray900
    return button
  }()
  
  private let searchButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
    let image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
    button.setImage(image, for: .normal)
    button.tintColor = .azGray900
    return button
  }()
  
  private let chartButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
    let image = UIImage(systemName: "chart.bar.fill", withConfiguration: config)
    button.setImage(image, for: .normal)
    button.tintColor = .azGray900
    return button
  }()
  
  private let drawerButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
    let image = UIImage(systemName: "rectangle.split.1x2.fill", withConfiguration: config)
    button.setImage(image, for: .normal)
    button.tintColor = .azGray900
    return button
  }()

  private let soundButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular, scale: .medium)
    let isSoundOn = UserDefaults.standard.bool(forKey: "isSoundEnabled")
    let imageName = isSoundOn ? "speaker.wave.2.fill" : "speaker.slash.fill"
    let image = UIImage(systemName: imageName, withConfiguration: config)
    button.setImage(image, for: .normal)
    button.tintColor = .azGray900
    button.contentVerticalAlignment = .top
    button.contentHorizontalAlignment = .center
    return button
  }()

  private let writeButton: UIButton = {
    let button = UIButton(type: .system)
    let pencilImage = UIImage(named: "pencil")?.resizeImage(
      to: CGSize(width: 24,height: 24)
    )
    button.setImage(pencilImage, for: .normal)
    button.backgroundColor = .azGray900
    button.tintColor = .azGray50
    button.layer.cornerRadius = 30
    button.layer.masksToBounds = true
    return button
  }()
  
  private let todayButton: UIButton = {
    let button = UIButton(type: .system)
    var config = UIButton.Configuration.filled()
    config.title = L10n.Calendar.today
    config.baseForegroundColor = .azGray100
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
      var outgoing = incoming
      outgoing.font = UIFont.appFont(size: 16)
      return outgoing
    }
    config.background.backgroundColor = .azGray900
    config.background.cornerRadius = 16
    config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    button.configuration = config
    return button
  }()
  
  private let headerContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private lazy var calendarHeaderView: UILabel = {
    let label = UILabel()
    label.font = UIFont.appFont(size: 25)
    label.textColor = .azGray900
    label.text = DateFormatter.localizedYearMonth(Date())
    return label
  }()
  
  private let arrowContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let arrowImageView: UIImageView = {
    let imageView = UIImageView()
    let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
    let image = UIImage(systemName: "chevron.right", withConfiguration: config)
    imageView.image = image
    imageView.tintColor = .azGray800
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private lazy var calendarView: FSCalendar = {
    let calendar = FSCalendar()
    calendar.register(CalendarCell.self,
                      forCellReuseIdentifier: CalendarCell.description())
    calendar.dataSource = self
    calendar.delegate = self
    
    calendar.translatesAutoresizingMaskIntoConstraints = false
    calendar.scrollEnabled = true
    calendar.scrollDirection = .vertical
    calendar.today = nil
    calendar.scope = .month
    calendar.locale = Locale.current
    calendar.placeholderType = .none
    
    calendar.appearance.headerMinimumDissolvedAlpha = 0.0
    calendar.appearance.headerTitleColor = .clear
    calendar.appearance.weekdayFont = UIFont.appFont(size: 14)
    calendar.appearance.weekdayTextColor = .azGray700
    calendar.appearance.todayColor = .azGray700
    calendar.appearance.selectionColor = .clear
    calendar.appearance.titleFont = UIFont.appFont(size: 12)
    
    return calendar
  }()
  
  // MARK: - Init
  
  init(
    viewModel: CalendarViewModel
  ) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
    
    Amp.track(event: "screen_view", properties: ["screen_name": "calendar"])
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.isNavigationBarHidden = false
  }
  
  // MARK: - Functions
  
  override func addView() {
    [headerContainerView, calendarView,
     writeButton, todayButton, settingButton,
     searchButton, chartButton, drawerButton, soundButton].forEach {
      view.addSubview($0)
    }
    
    [calendarHeaderView, arrowContainerView].forEach {
      headerContainerView.addSubview($0)
    }
    
    arrowContainerView.addSubview(arrowImageView)
  }
  
  override func setLayout() {
    headerContainerView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(16)
      make.bottom.equalTo(calendarView.snp.top)
      make.trailing.lessThanOrEqualToSuperview().inset(16)
    }
    
    calendarHeaderView.snp.makeConstraints { make in
      make.leading.top.bottom.equalToSuperview()
    }
    
    arrowContainerView.snp.makeConstraints { make in
      make.leading.equalTo(calendarHeaderView.snp.trailing).offset(4)
      make.top.bottom.equalToSuperview()
      make.width.equalTo(44)
      make.trailing.equalToSuperview()
    }
    
    arrowImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.height.equalTo(16)
    }
    
    calendarView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
      make.height.equalTo(UIScreen.main.bounds.height / 2.5)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
    }
    
    writeButton.snp.makeConstraints { make in
      make.width.height.equalTo(60)
      make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-60)
    }
    
    todayButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(writeButton)
    }
    
    settingButton.snp.makeConstraints { make in
      make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
    }

    searchButton.snp.makeConstraints { make in
      make.trailing.equalTo(chartButton.snp.leading).offset(-16)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
    }

    chartButton.snp.makeConstraints { make in
      make.trailing.equalTo(drawerButton.snp.leading).offset(-16)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
    }

    drawerButton.snp.makeConstraints { make in
      make.trailing.equalTo(soundButton.snp.leading).offset(-16)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
    }

    soundButton.snp.makeConstraints { make in
      make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
      make.width.height.equalTo(28)
    }
  }
  
  override func setupView() {
    ShortcutManager.shared.delegate = self
    
    bindViewModel()
    
    settingButton.addTarget(
      self,
      action: #selector(showProfileTrigger),
      for: .touchUpInside
    )
    
    searchButton.addTarget(
      self,
      action: #selector(showSearchTrigger),
      for: .touchUpInside
    )
    
    writeButton.addTarget(
      self,
      action: #selector(todayWriteTrigger),
      for: .touchUpInside
    )
    
    todayButton.addTarget(
      self,
      action: #selector(todayButtonTapped),
      for: .touchUpInside
    )
    
    chartButton.addTarget(
      self,
      action: #selector(showChartTrigger),
      for: .touchUpInside
    )
    
    drawerButton.addTarget(
      self,
      action: #selector(showDrawerTrigger),
      for: .touchUpInside
    )

    soundButton.addTarget(
      self,
      action: #selector(soundButtonTapped),
      for: .touchUpInside
    )

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
    headerContainerView.addGestureRecognizer(tapGesture)
    
    DispatchQueue.main.async { [weak self] in
      self?.view.backgroundColor = .azGray50
      self?.updateTodayButtonVisibility(for: Date())
    }

    // 사운드 초기 상태 확인 및 재생
    let isSoundEnabled = UserDefaults.standard.bool(forKey: "isSoundEnabled")
    if isSoundEnabled {
      SoundManager.shared.play()
    }

    if let year = Int(DateFormatter.formattedString(Date(), format: "yyyy")),
       let month = Int(DateFormatter.formattedString(Date(), format: "M")) {
      Task { [weak self] in
        guard let self else { return }
        do {
          try await self.viewModel.fetchMonthRecordTrigger(
            year: year, month: month
          ) { }
        } catch {
          handleError(self.coordinator!, L10n.Common.error)
        }
      }
    }
  }

  override func updateFontsAfterChange() {
    calendarView.appearance.weekdayFont = UIFont.appFont(size: 14)
    calendarView.appearance.titleFont = UIFont.appFont(size: 12)
    calendarView.reloadData()
    calendarHeaderView.font = UIFont.appFont(size: 25)
  }
}

extension CalendarViewController {
  private func bindViewModel() {
    viewModel.$records
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.calendarView.reloadData()
      }
      .store(in: &cancellables)
  }
  
  @objc private func showSearchTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "search"])
    coordinator?.showSearch(calendarViewModel: viewModel)
  }
  
  @objc private func showProfileTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "profile"])
    coordinator?.showProfile(calendarViewModel: viewModel)
  }
  
  @objc private func todayWriteTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "today_write"])
    
    let nowDate = Calendar.current.startOfDay(for: Date())
    let day = Calendar.current.component(.weekday, from: nowDate) - 1
    if Calendar.current.shortWeekdaySymbols[day] == L10n.Weekday.sunday {
      calendarView.appearance.titleSelectionColor = .azRed
    } else if Calendar.current.shortWeekdaySymbols[day] == L10n.Weekday.saturday {
      calendarView.appearance.titleSelectionColor = .azBlue
    } else {
      calendarView.appearance.titleSelectionColor = .azGray900
    }
    
    // 캘린더를 오늘 날짜로 이동
    let today = Date()
    calendarView.setCurrentPage(today, animated: false)
    
    let selectData = viewModel.todayRecord
    ?? RecordEntity(calendarDate: Int(nowDate.millisecondsSince1970))
    
    coordinator?.showRecord(
      calendarViewModel: viewModel,
      selectData: selectData
    )
  }
  
  @objc private func showChartTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "chart"])
    coordinator?.showChart(currentDate: viewModel.currentDate)
  }
  
  @objc private func showDrawerTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "drawer"])
    coordinator?.showDrawer(
      calendarViewModel: viewModel,
      currentDate: viewModel.currentDate
    )
  }
  
  @objc private func todayButtonTapped() {
    Amp.track(event: "button_click", properties: ["button_name": "today"])

    let today = Date()
    calendarView.setCurrentPage(today, animated: false)
  }

  @objc private func soundButtonTapped() {
    // 현재 사운드 상태 읽기
    let currentState = UserDefaults.standard.bool(forKey: "isSoundEnabled")
    let newState = !currentState

    // 새로운 상태 저장
    UserDefaults.standard.set(newState, forKey: "isSoundEnabled")

    // 버튼 아이콘 업데이트
    let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular, scale: .medium)
    let imageName = newState ? "speaker.wave.2.fill" : "speaker.slash.fill"
    let image = UIImage(systemName: imageName, withConfiguration: config)
    soundButton.setImage(image, for: .normal)

    // 음악 재생/정지
    if newState {
      SoundManager.shared.play()
    } else {
      SoundManager.shared.stop()
    }

    // 분석 이벤트 트래킹
    Amp.track(event: "button_click", properties: [
      "button_name": "sound",
      "sound_enabled": newState
    ])
  }

  private func updateTodayButtonVisibility(for currentPage: Date) {
    let today = Date()
    let calendar = Calendar.current
    
    let currentYear = calendar.component(.year, from: currentPage)
    let currentMonth = calendar.component(.month, from: currentPage)
    let todayYear = calendar.component(.year, from: today)
    let todayMonth = calendar.component(.month, from: today)
    
    let isCurrentMonth = (currentYear == todayYear && currentMonth == todayMonth)
    
    self.todayButton.alpha = isCurrentMonth ? 0 : 1
  }
  
  @objc private func headerTapped() {
    Amp.track(event: "month_picker_open")
    
    let overlayView = UIView()
    overlayView.backgroundColor = .azOverlay
    overlayView.alpha = 0
    overlayView.tag = 1000
    
    let squareView = UIView()
    squareView.backgroundColor = .azGray50
    squareView.layer.cornerRadius = 16
    squareView.alpha = 0
    squareView.tag = 1001
    
    view.addSubview(overlayView)
    overlayView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    view.addSubview(squareView)
    squareView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(32)
      make.trailing.equalToSuperview().offset(-32)
      make.height.equalTo(220)
    }
    
    setupYearMonthPicker(in: squareView)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOverlay))
    overlayView.addGestureRecognizer(tapGesture)
    
    UIView.animate(withDuration: 0.3) {
      overlayView.alpha = 1
      squareView.alpha = 1
    }
  }
  
  @objc private func dismissOverlay() {
    view.subviews.forEach { subview in
      if subview.tag == 1000 || subview.tag == 1001 {
        UIView.animate(withDuration: 0.3, animations: {
          subview.alpha = 0
        }) { _ in
          subview.removeFromSuperview()
        }
      }
    }
  }
  
  private func setupYearMonthPicker(in containerView: UIView) {
    let currentDate = viewModel.currentDate
    let currentYear = Calendar.current.component(.year, from: currentDate)
    
    let yearHeaderView = UIView()
    yearHeaderView.tag = 2000
    containerView.addSubview(yearHeaderView)
    
    let prevYearButton = UIButton(type: .system)
    let prevConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
    let prevImage = UIImage(systemName: "chevron.left", withConfiguration: prevConfig)
    prevYearButton.setImage(prevImage, for: .normal)
    prevYearButton.tintColor = .azGray900
    prevYearButton.tag = 2001
    prevYearButton.addTarget(self, action: #selector(prevYearTapped), for: .touchUpInside)
    
    let yearLabel = UILabel()
    let isKorean = Locale.current.language.languageCode?.identifier == "ko"
    yearLabel.text = isKorean ? "\(currentYear)년" : "\(currentYear)"
    yearLabel.font = UIFont.appFont(size: 20)
    yearLabel.textColor = .azGray900
    yearLabel.textAlignment = .center
    yearLabel.tag = 2002
    
    let nextYearButton = UIButton(type: .system)
    let nextConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
    let nextImage = UIImage(systemName: "chevron.right", withConfiguration: nextConfig)
    nextYearButton.setImage(nextImage, for: .normal)
    nextYearButton.tintColor = .azGray900
    nextYearButton.tag = 2003
    nextYearButton.addTarget(self, action: #selector(nextYearTapped), for: .touchUpInside)
    
    [prevYearButton, yearLabel, nextYearButton].forEach {
      yearHeaderView.addSubview($0)
    }
    
    yearHeaderView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(32)
    }
    
    prevYearButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(44)
    }
    
    yearLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    nextYearButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(-20)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(44)
    }
    
    let monthGridView = UIView()
    monthGridView.tag = 2004
    containerView.addSubview(monthGridView)
    
    monthGridView.snp.makeConstraints { make in
      make.top.equalTo(yearHeaderView.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().offset(-16)
    }
    
    setupMonthGrid(in: monthGridView, for: currentYear)
  }
  
  private func setupMonthGrid(in containerView: UIView, for year: Int) {
    containerView.subviews.forEach { $0.removeFromSuperview() }
    
    let months = (1...12).map { $0 }
    let currentDate = viewModel.currentDate
    let currentYear = Calendar.current.component(.year, from: currentDate)
    let currentMonth = Calendar.current.component(.month, from: currentDate)
    
    for (index, month) in months.enumerated() {
      let button = UIButton(type: .system)
      button.setTitle("\(month)", for: .normal)
      button.titleLabel?.font = UIFont.appFont(size: 16)
      button.backgroundColor = (year == currentYear && month == currentMonth)
      ? .azGray200 : .clear
      button.tintColor = .azGray900
      button.layer.cornerRadius = 16
      button.tag = 3000 + month
      button.addTarget(self, action: #selector(monthButtonTapped(_:)), for: .touchUpInside)
      
      containerView.addSubview(button)
      
      let row = index / 4
      let col = index % 4
      
      button.snp.makeConstraints { make in
        make.height.equalTo(containerView.snp.height).dividedBy(3).offset(-5)
        
        if col == 0 {
          make.leading.equalToSuperview()
        } else {
          let previousButton = containerView.subviews[index - 1]
          make.leading.equalTo(previousButton.snp.trailing).offset(6)
        }
        
        if col == 3 {
          make.trailing.equalToSuperview()
        }
        
        if row == 0 {
          make.top.equalToSuperview()
        } else {
          let buttonAbove = containerView.subviews[index - 4]
          make.top.equalTo(buttonAbove.snp.bottom).offset(8)
        }
        
        make.width.equalTo(containerView.snp.width).dividedBy(4).offset(-5)
      }
    }
  }
  
  @objc private func prevYearTapped() {
    guard let squareView = view.subviews.first(where: { $0.tag == 1001 }),
          let yearLabel = squareView.subviews.first(
            where: { $0.tag == 2000 }
          )?.subviews.first(where: { $0.tag == 2002 }) as? UILabel,
          let monthGridView = squareView.subviews.first(where: { $0.tag == 2004 }),
          let currentYearText = yearLabel.text?.components(
            separatedBy: CharacterSet.decimalDigits.inverted
          ).joined(),
          let currentYear = Int(currentYearText)
    else { return }
    
    let isKorean = Locale.current.language.languageCode?.identifier == "ko"
    let newYear = currentYear - 1
    yearLabel.text = isKorean ? "\(newYear)년" : "\(newYear)"
    setupMonthGrid(in: monthGridView, for: newYear)
  }
  
  @objc private func nextYearTapped() {
    guard let squareView = view.subviews.first(where: { $0.tag == 1001 }),
          let yearLabel = squareView.subviews.first(
            where: { $0.tag == 2000 }
          )?.subviews.first(where: { $0.tag == 2002 }) as? UILabel,
          let monthGridView = squareView.subviews.first(where: { $0.tag == 2004 }),
          let currentYearText = yearLabel.text?.components(
            separatedBy: CharacterSet.decimalDigits.inverted
          ).joined(),
          let currentYear = Int(currentYearText)
    else { return }
    
    let isKorean = Locale.current.language.languageCode?.identifier == "ko"
    let newYear = currentYear + 1
    yearLabel.text = isKorean ? "\(newYear)년" : "\(newYear)"
    setupMonthGrid(in: monthGridView, for: newYear)
  }
  
  @objc private func monthButtonTapped(_ sender: UIButton) {
    guard let squareView = view.subviews.first(where: { $0.tag == 1001 }),
          let yearLabel = squareView.subviews.first(
            where: { $0.tag == 2000 }
          )?.subviews.first(where: { $0.tag == 2002 }) as? UILabel,
          let yearText = yearLabel.text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(),
          let year = Int(yearText)
    else { return }
    
    let month = sender.tag - 3000
    let dateComponents = DateComponents(year: year, month: month, day: 1)
    if let targetDate = Calendar.current.date(from: dateComponents) {
      Amp.track(event: "month_picker_select", properties: [
        "year": year,
        "month": month
      ])
      
      calendarView.setCurrentPage(targetDate, animated: false)
      dismissOverlay()
    }
  }
}

/// Shortcut "오늘 일기 작성"으로 접근 시
extension CalendarViewController: CalendarViewControllerDelegate {
  func shortcutShowTodayRecordTrigger() {
    let nowDate = Calendar.current.startOfDay(for: Date())
    var selectData = RecordEntity(calendarDate: Int(nowDate.millisecondsSince1970))
    
    if let matchedEntity = viewModel.records.first(where: { entity in
      let seconds = TimeInterval(entity.calendarDate) / 1000
      let responseDate = Date(timeIntervalSince1970: seconds)
      return nowDate == responseDate
    }) {
      selectData = matchedEntity
    }
    
    coordinator?.showRecord(
      calendarViewModel: viewModel,
      selectData: selectData
    )
  }
}

// MARK: - FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance

extension CalendarViewController: FSCalendarDelegate,
                                  FSCalendarDataSource,
                                  FSCalendarDelegateAppearance {
  func calendar(_ calendar: FSCalendar,
                boundingRectWillChange bounds: CGRect,
                animated: Bool) {
    calendar.snp.updateConstraints { (make) in
      make.height.equalTo(bounds.height)
    }
    
    self.view.layoutIfNeeded()
  }
  
  func calendar(
    _ calendar: FSCalendar,
    didSelect date: Date,
    at monthPosition: FSCalendarMonthPosition
  ) {
    // 미래 날짜는 선택 불가
    if date > Date() {
      calendar.deselect(date)
      return
    }
    
    let day = Calendar.current.component(.weekday, from: date) - 1
    if day == 0 { // 일요일
      calendar.appearance.titleSelectionColor = .azRed
    } else if day == 6 { // 토요일
      calendar.appearance.titleSelectionColor = .azBlue
    } else {
      calendar.appearance.titleSelectionColor = .azGray900
    }
    
    var selectData = RecordEntity(calendarDate: Int(date.millisecondsSince1970))
    let hasRecord = viewModel.records.contains(where: { entity in
      let seconds = TimeInterval(entity.calendarDate) / 1000
      let responseDate = Date(timeIntervalSince1970: seconds)
      return date == responseDate
    })
    
    if let matchedEntity = viewModel.records.first(where: { entity in
      let seconds = TimeInterval(entity.calendarDate) / 1000
      let responseDate = Date(timeIntervalSince1970: seconds)
      return date == responseDate
    }) {
      selectData = matchedEntity
    }
    
    Amp.track(event: "date_select", properties: [
      "has_record": hasRecord,
      "date": DateFormatter.formattedString(date, format: "yyyy-MM-dd")
    ])
    
    coordinator?.showRecord(
      calendarViewModel: viewModel,
      selectData: selectData
    )
  }
  
  // 일요일에 해당되는 모든 날짜의 색상 red로 변경
  func calendar(
    _ calendar: FSCalendar,
    appearance: FSCalendarAppearance,
    titleDefaultColorFor date: Date
  ) -> UIColor? {
    let day = Calendar.current.component(.weekday, from: date) - 1
    
    if date > Date() {
      return .azGray500
    }
    
    if day == 0 { // 일요일
      return .azRed
    } else if day == 6 { // 토요일
      return .azBlue
    } else {
      return .azGray900
    }
  }
  
  func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    let currentPage = calendar.currentPage
    
    viewModel.updateCurrentDate(currentPage)
    
    Amp.track(event: "month_change", properties: [
      "year_month": DateFormatter.formattedString(currentPage, format: "yyyy-MM")
    ])
    
    DispatchQueue.main.async { [weak self] in
      self?.calendarHeaderView.text = DateFormatter.localizedYearMonth(currentPage)
      self?.updateTodayButtonVisibility(for: currentPage)
    }
    
    if let year = Int(DateFormatter.formattedString(currentPage, format: "yyyy")),
       let month = Int(DateFormatter.formattedString(currentPage, format: "M")) {
      Task { [weak self] in
        guard let self else { return }
        do {
          try await Task.sleep(nanoseconds: 500_000_000)
          try await self.viewModel.fetchMonthRecordTrigger(
            year: year, month: month
          ) { }
        } catch {
          handleError(self.coordinator!, L10n.Common.error)
        }
      }
    }
  }
  
  func calendar(
    _ calendar: FSCalendar,
    cellFor date: Date,
    at position: FSCalendarMonthPosition
  ) -> FSCalendarCell {
    guard let cell = calendar.dequeueReusableCell(
      withIdentifier: CalendarCell.description(),
      for: date,
      at: position
    ) as? CalendarCell else { return FSCalendarCell() }
    
    DispatchQueue.main.async {
      cell.backImageView.image = nil
      cell.titleLabel.isHidden = false
      cell.contentView.subviews.forEach { subview in
        if subview.tag == 1001 {
          subview.removeFromSuperview()
        }
      }
    }
    
    if Calendar.current.isDateInToday(date) {
      DispatchQueue.main.async {
        let squareView = UIView()
        squareView.backgroundColor = .azGray200
        squareView.tag = 1001
        
        cell.contentView.addSubview(squareView)
        squareView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          squareView.widthAnchor.constraint(equalTo: cell.contentView.widthAnchor,
                                            multiplier: 0.5),
          squareView.heightAnchor.constraint(equalToConstant: 10),
          squareView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
          squareView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor,
                                              constant: 10)
        ])
      }
    }
    
    viewModel.records.forEach { entity in
      let seconds = TimeInterval(entity.calendarDate) / 1000
      let responseDate = Date(timeIntervalSince1970: seconds)
      if date == responseDate {
        if let image = UIImage(
          named: EmotionType(rawValue: entity.emotionType)?.rawValue ?? ""
        ) {
          DispatchQueue.main.async {
            cell.backImageView.image = image
            cell.titleLabel.isHidden = true
            
            if Calendar.current.isDateInToday(date) {
              cell.contentView.subviews.forEach { subview in
                if subview.tag == 1001 {
                  subview.removeFromSuperview()
                }
              }
            }
          }
        } else {
          DispatchQueue.main.async {
            cell.circleView.isHidden = false
          }
        }
      }
    }
    
    return cell
  }
}

final class CalendarCell: FSCalendarCell {
  var backImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFit
    view.clipsToBounds = true
    return view
  }()
  
  var circleView: UIView = {
    let view = UIView()
    view.backgroundColor = .red
    view.layer.cornerRadius = 2
    view.layer.masksToBounds = true
    view.isHidden = true
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.titleLabel.snp.makeConstraints { make in
      make.center.equalTo(contentView)
    }
    
    contentView.insertSubview(backImageView, at: 0)
    backImageView.snp.makeConstraints { make in
      make.center.equalTo(contentView)
      make.size.equalTo(minSize())
    }
    
    contentView.addSubview(circleView)
    circleView.snp.makeConstraints { make in
      make.top.equalTo(contentView).offset(4)
      make.trailing.equalTo(contentView).offset(-4)
      make.width.height.equalTo(4)
    }
  }
  
  required init(coder aDecoder: NSCoder!) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let size = minSize()
    backImageView.layer.cornerRadius = (size / 2)
    backImageView.layer.masksToBounds = true
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    DispatchQueue.main.async { [weak self] in
      self?.backImageView.image = nil
      self?.circleView.isHidden = true
    }
  }
  
  func minSize() -> CGFloat {
    let width = contentView.bounds.width
    let height = contentView.bounds.height
    return (width > height) ? height : width
  }
}
