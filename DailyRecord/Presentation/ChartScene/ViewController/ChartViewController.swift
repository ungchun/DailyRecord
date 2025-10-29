//
//  ChartViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 10/20/24.
//

import UIKit

import SnapKit

final class ChartViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: ChartCoordinator?
  
  private let viewModel: ChartViewModel
  
  // MARK: - Views
  
  private let noEmotionLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "omyu_pretty", size: 20)
    label.textColor = .azLightGray
    label.text = L10n.Common.empty
    label.textAlignment = .center
    label.isHidden = true
    return label
  }()
  
  private let monthLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "omyu_pretty", size: 25)
    label.textColor = .azWhite
    label.textAlignment = .center
    return label
  }()
  
  private let leftButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
    let image = UIImage(systemName: "chevron.left", withConfiguration: config)
    
    var configuration = UIButton.Configuration.plain()
    configuration.image = image
    configuration.contentInsets = NSDirectionalEdgeInsets(
      top: 10, leading: 10, bottom: 10, trailing: 10
    )
    button.configuration = configuration
    
    button.tintColor = .azLightGray
    return button
  }()
  
  private let rightButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
    let image = UIImage(systemName: "chevron.right", withConfiguration: config)
    
    var configuration = UIButton.Configuration.plain()
    configuration.image = image
    configuration.contentInsets = NSDirectionalEdgeInsets(
      top: 10, leading: 10, bottom: 10, trailing: 10
    )
    button.configuration = configuration
    
    button.tintColor = .azLightGray
    return button
  }()
  
  private let scrollView: UIScrollView = {
    let view = UIScrollView()
    return view
  }()
  
  private let contentView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()
  
  // MARK: - Init
  
  init(viewModel: ChartViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Amp.track(event: "screen_view", properties: ["screen_name": "chart"])
  }
  
  // MARK: - Functions
  
  override func addView() {
    [leftButton, monthLabel, rightButton, scrollView, noEmotionLabel].forEach {
      view.addSubview($0)
    }
    
    scrollView.addSubview(contentView)
  }
  
  override func setLayout() {
    monthLabel.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      make.centerX.equalToSuperview()
    }
    
    leftButton.snp.makeConstraints { make in
      make.trailing.equalTo(monthLabel.snp.leading).offset(-16)
      make.centerY.equalTo(monthLabel)
      make.width.height.equalTo(44)
    }
    
    rightButton.snp.makeConstraints { make in
      make.leading.equalTo(monthLabel.snp.trailing).offset(16)
      make.centerY.equalTo(monthLabel)
      make.width.height.equalTo(44)
    }
    
    noEmotionLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(monthLabel.snp.bottom).offset(50)
    }
    
    scrollView.snp.makeConstraints { make in
      make.top.equalTo(monthLabel.snp.bottom).offset(20)
      make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
  }
  
  override func setupView() {
    view.backgroundColor = .azBlack
    
    setupMonthNavigation()
    updateMonthLabel()
  }
}

private extension ChartViewController {
  func setupMonthNavigation() {
    leftButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
    rightButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
  }
  
  func updateMonthLabel() {
    monthLabel.text = DateFormatter.localizedYearMonth(viewModel.currentDate)
    
    updateButtonState()
    
    if let year = Int(
      DateFormatter.formattedString(
        viewModel.currentDate,
        format: "yyyy"
      )
    ), let month = Int(
      DateFormatter.formattedString(
        viewModel.currentDate,
        format: "M"
      )
    ) {
      Task { [weak self] in
        guard let self else { return }
        do {
          try await Task.sleep(nanoseconds: 500_000_000)
          try await self.viewModel.fetchMonthRecordTrigger(
            year: year, month: month
          ) {
            DispatchQueue.main.async {
              self.updateEmotionCounts()
              self.updateEmotionViews()
            }
          }
        } catch {
          handleError(self.coordinator!, L10n.Common.error)
        }
      }
    }
  }
  
  func updateButtonState() {
    guard let nextDate = Calendar.current.date(
      byAdding: .month, value: 1, to: viewModel.currentDate
    ) else { return }
    
    rightButton.isHidden = nextDate > Date()
  }
  
  func updateEmotionCounts() {
    viewModel.removeEmotionCounts()
    
    let calendar = Calendar.current
    let components = calendar.dateComponents(
      [.year, .month],
      from: viewModel.currentDate
    )
    let startOfMonth = calendar.date(from: components)!
    let endOfMonth = calendar.date(
      byAdding: DateComponents(
        month: 1,
        day: -1
      ),
      to: startOfMonth
    )!
    
    for record in viewModel.records {
      let recordDate = Date(timeIntervalSince1970: TimeInterval(
        record.calendarDate / 1000)
      )
      if recordDate >= startOfMonth && recordDate <= endOfMonth {
        viewModel.incrementEmotionCount(record.emotionType)
      }
    }
  }
  
  func updateEmotionViews() {
    contentView.subviews.forEach { $0.removeFromSuperview() }
    
    if viewModel.emotionCounts.isEmpty {
      noEmotionLabel.isHidden = false
    } else {
      noEmotionLabel.isHidden = true
      
      var previousView: UIView?
      let maxCount = viewModel.emotionCounts.values.max() ?? 1
      let progressBarWidth = UIScreen.main.bounds.width * 0.55
      
      let sortedEmotions = viewModel.emotionCounts.sorted { $0.value > $1.value }
      
      for (emotionType, count) in sortedEmotions {
        if emotionType != "none" {
          let containerView = UIView()
          contentView.addSubview(containerView)
          
          let stackView = UIStackView()
          stackView.axis = .horizontal
          stackView.alignment = .center
          stackView.spacing = 20
          containerView.addSubview(stackView)
          
          if let image = UIImage(named: emotionType) {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.snp.makeConstraints { make in
              make.width.height.equalTo(40)
            }
            stackView.addArrangedSubview(imageView)
          }
          
          let progressContainer = UIView()
          progressContainer.backgroundColor = .azBlack
          progressContainer.layer.cornerRadius = 5
          stackView.addArrangedSubview(progressContainer)
          
          let progressView = UIView()
          progressView.backgroundColor = getColorForEmotionType(emotionType)
          progressView.layer.cornerRadius = 5
          progressContainer.addSubview(progressView)
          
          let countLabel = UILabel()
          countLabel.text = "\(count)"
          countLabel.textColor = .azWhite
          countLabel.font = UIFont(name: "omyu_pretty", size: 20)
          stackView.addArrangedSubview(countLabel)
          
          containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if let previousView = previousView {
              make.top.equalTo(previousView.snp.bottom).offset(20)
            } else {
              make.top.equalToSuperview().offset(20)
            }
            if emotionType == sortedEmotions.last?.key {
              make.bottom.equalToSuperview().offset(-20)
            }
            make.height.equalTo(44)
          }
          
          stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
          }
          
          progressContainer.snp.makeConstraints { make in
            make.height.equalTo(10)
            make.width.equalTo(progressBarWidth)
          }
          
          let progressWidth = (CGFloat(count) / CGFloat(maxCount)) * progressBarWidth
          progressView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(progressWidth)
          }
          
          previousView = containerView
        }
      }
    }
  }
}

private extension ChartViewController {
  @objc func previousMonth() {
    Amp.track(event: "button_click", properties: ["button_name": "chart_previous_month"])
    
    viewModel.updateCurrentDate(
      Calendar.current.date(
        byAdding: .month, value: -1, to: viewModel.currentDate
      ) ?? viewModel.currentDate
    )
    
    DispatchQueue.main.async { [weak self] in
      self?.updateMonthLabel()
    }
  }
  
  @objc func nextMonth() {
    guard let nextDate = Calendar.current.date(
      byAdding: .month,
      value: 1,
      to: viewModel.currentDate
    ), nextDate <= Date() else {
      return
    }
    
    Amp.track(event: "button_click", properties: ["button_name": "chart_next_month"])
    
    viewModel.updateCurrentDate(nextDate)
    
    DispatchQueue.main.async { [weak self] in
      self?.updateMonthLabel()
    }
  }
}

private extension ChartViewController {
  func getColorForEmotionType(_ type: String) -> UIColor {
    switch type {
    case "sad":
      return .sad
    case "very_sad":
      return .verySad
    case "angry":
      return .angry
    case "neutral":
      return .neutral
    case "happy":
      return .happy
    case "very_happy":
      return .veryHappy
    case "embarrassed":
      return .embarrassed
    case "hurt":
      return .hurt
    case "lovely":
      return .lovely
    case "sleepy":
      return .sleepy
    case "surprised":
      return .surprised
    case "tired":
      return .tired
    default:
      return .systemGray
    }
  }
}
