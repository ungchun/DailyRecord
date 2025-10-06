//
//  DrawerViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 11/30/24.
//

import UIKit

import SnapKit

final class DrawerViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: DrawerCoordinator?
  
  private let viewModel: DrawerViewModel
  private let calendarViewModel: CalendarViewModel
  
  // MARK: - Views
  
  private let emptyStateLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "omyu_pretty", size: 20)
    label.textColor = .azLightGray
    label.text = L10n.Common.noDiary
    label.textAlignment = .center
    label.isHidden = true
    return label
  }()
  
  private lazy var titleView: UIStackView = {
    let stackView = UIStackView(
      arrangedSubviews: [leftButton, monthLabel, rightButton]
    )
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.spacing = 8
    return stackView
  }()
  
  private let monthLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "omyu_pretty", size: 20)
    label.textColor = .azWhite
    label.textAlignment = .center
    return label
  }()
  
  private let leftButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
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
    let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
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
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = true
    scrollView.alwaysBounceVertical = true
    return scrollView
  }()
  
  private lazy var contentView: UIView = {
    let view = UIView()
    return view
  }()
  
  private lazy var recordStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.distribution = .fill
    return stackView
  }()
  
  // MARK: - Init
  
  init(
    viewModel: DrawerViewModel,
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
  }
  
  // MARK: - Functions
  
  override func addView() {
    view.addSubview(scrollView)
    view.addSubview(emptyStateLabel)
    
    scrollView.addSubview(contentView)
    contentView.addSubview(recordStackView)
  }
  
  override func setLayout() {
    scrollView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.trailing.bottom.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
    
    recordStackView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.leading.trailing.equalToSuperview().inset(16)
      make.bottom.equalToSuperview().offset(-16)
    }
    
    emptyStateLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  override func setupView() {
    view.backgroundColor = .azBlack
    
    navigationItem.titleView = titleView
    
    setupMonthNavigation()
    
    updateMonthLabel()
  }
  
  private func updateRecordViews() {
    recordStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    if viewModel.records.isEmpty {
      // 레코드가 없을 때
      recordStackView.isHidden = true
      emptyStateLabel.isHidden = false
    } else {
      // 레코드가 있을 때
      recordStackView.isHidden = false
      emptyStateLabel.isHidden = true
      
      // 새로운 레코드 뷰들 추가
      viewModel.records.forEach { record in
        let recordView = DrawerRecordItemView(record: record)
        recordView.delegate = self
        recordStackView.addArrangedSubview(recordView)
      }
    }
  }
}

private extension DrawerViewController {
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
              self.updateRecordViews()
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
    
    let shouldHideNextButton = nextDate > Date()
    rightButton.alpha = shouldHideNextButton ? 0 : 1
  }
}

private extension DrawerViewController {
  @objc func previousMonth() {
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
    
    viewModel.updateCurrentDate(nextDate)
    
    DispatchQueue.main.async { [weak self] in
      self?.updateMonthLabel()
    }
  }
}

extension DrawerViewController: DrawerRecordItemViewDelegate {
  func didTapRecord(_ record: RecordEntity) {
    coordinator?.showRecord(
      calendarViewModel: calendarViewModel,
      selectData: record
    )
  }
}
