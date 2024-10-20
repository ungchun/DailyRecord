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
  
  private var currentDate: Date = Date()
  private var emotionCounts: [String: Int] = [:]
  
  // MARK: - Views
  
  private let demoTopView: UIView = {
    let view = UIView()
    view.backgroundColor = .blue
    return view
  }()
  
  private let monthLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    return label
  }()
  
  private let leftButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
    let image = UIImage(systemName: "chevron.left", withConfiguration: config)
    button.setImage(image, for: .normal)
    button.tintColor = .white
    return button
  }()
  
  private let rightButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
    let image = UIImage(systemName: "chevron.right", withConfiguration: config)
    button.setImage(image, for: .normal)
    button.tintColor = .white
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
  }
  
  // MARK: - Functions
  
  override func addView() {
    [demoTopView, scrollView].forEach {
      view.addSubview($0)
    }
    
    scrollView.addSubview(contentView)
    
    [monthLabel, leftButton, rightButton].forEach {
      demoTopView.addSubview($0)
    }
  }
  
  override func setLayout() {
    demoTopView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(300)
    }
    
    monthLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    leftButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.centerY.equalTo(monthLabel)
    }
    
    rightButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(-20)
      make.centerY.equalTo(monthLabel)
    }
    
    scrollView.snp.makeConstraints { make in
      make.top.equalTo(demoTopView.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
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
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy년 MM월"
    monthLabel.text = dateFormatter.string(from: currentDate)
    
    if let year = Int(formattedDateString(currentDate, format: "yyyy")),
       let month = Int(formattedDateString(currentDate, format: "M")) {
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
          handleError(self.coordinator!, "에러가 발생했어요")
        }
      }
    }
  }
  
  func updateEmotionCounts() {
    emotionCounts.removeAll()
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: currentDate)
    let startOfMonth = calendar.date(from: components)!
    let endOfMonth = calendar.date(
      byAdding: DateComponents(
        month: 1,
        day: -1
      ),
      to: startOfMonth
    )!
    
    for record in viewModel.records {
      let recordDate = Date(timeIntervalSince1970: TimeInterval(record.calendarDate / 1000))
      if recordDate >= startOfMonth && recordDate <= endOfMonth {
        emotionCounts[record.emotionType, default: 0] += 1
      }
    }
  }
  
  func updateEmotionViews() {
    contentView.subviews.forEach { $0.removeFromSuperview() }
    
    var previousView: UIView?
    
    for (emotionType, count) in emotionCounts.sorted(by: { $0.key < $1.key }) {
      let containerView = UIView()
      contentView.addSubview(containerView)
      
      let stackView = UIStackView()
      stackView.axis = .horizontal
      stackView.alignment = .center
      stackView.spacing = 10
      containerView.addSubview(stackView)
      
      if let image = UIImage(named: emotionType) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
          make.width.height.equalTo(30)
        }
        stackView.addArrangedSubview(imageView)
      }
      
      let countLabel = UILabel()
      countLabel.text = "\(count)"
      countLabel.textColor = .white
      countLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
      stackView.addArrangedSubview(countLabel)
      
      containerView.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        if let previousView = previousView {
          make.top.equalTo(previousView.snp.bottom).offset(40)
        } else {
          make.top.equalToSuperview().offset(20)
        }
        if emotionType == emotionCounts.keys.sorted().last {
          make.bottom.equalToSuperview().offset(-40)
        }
      }
      
      stackView.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.centerY.equalToSuperview()
      }
      
      previousView = containerView
    }
  }
  
  @objc func previousMonth() {
    currentDate = Calendar.current.date(
      byAdding: .month, value: -1, to: currentDate
    ) ?? currentDate
    
    DispatchQueue.main.async { [weak self] in
      self?.updateMonthLabel()
    }
  }
  
  @objc func nextMonth() {
    currentDate = Calendar.current.date(
      byAdding: .month, value: 1, to: currentDate
    ) ?? currentDate
    
    DispatchQueue.main.async { [weak self] in
      self?.updateMonthLabel()
    }
  }
}

private extension ChartViewController {
  func formattedDateString(_ date: Date, format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_kr")
    dateFormatter.timeZone = TimeZone(identifier: "KST")
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
  }
}
