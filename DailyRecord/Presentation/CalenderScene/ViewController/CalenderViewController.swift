//
//  CalenderViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import UIKit

import FSCalendar
import SnapKit

final class CalenderViewController: BaseViewController {
	
	// MARK: - Properties
	
	var coordinator: CalenderCoordinator?
	
	private let viewModel: CalenderViewModel
	
	// MARK: - Views
	
	private let writeButton: UIButton = {
		let button = UIButton(type: .system)
		let largeConfig = UIImage.SymbolConfiguration(pointSize: 20)
		let pencilImage = UIImage(systemName: "pencil.line", withConfiguration: largeConfig)
		button.setImage(pencilImage, for: .normal)
		button.backgroundColor = .systemBlue
		button.tintColor = .white
		button.layer.cornerRadius = 30
		button.layer.masksToBounds = true
		return button
	}()
	
	private lazy var calendarView: FSCalendar = {
		let calendar = FSCalendar()
		calendar.dataSource = self
		calendar.delegate = self
		calendar.scrollEnabled = true
		calendar.scrollDirection = .vertical
		calendar.firstWeekday = 2
		calendar.scope = .month
		calendar.locale = Locale(identifier: "ko_KR")
		calendar.placeholderType = .none
		calendar.headerHeight = 55
		calendar.appearance.headerDateFormat = "MM월"
		calendar.appearance.headerTitleColor = .black
		calendar.appearance.weekdayTextColor = .black
		calendar.appearance.titleTodayColor = .black
		calendar.appearance.todayColor = .white
		calendar.calendarWeekdayView.weekdayLabels.last!.textColor = .red
		return calendar
	}()
	
	// MARK: - Life Cycle
	
	init(
		viewModel: CalenderViewModel
	) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.isNavigationBarHidden = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.isNavigationBarHidden = false
	}
	
	// MARK: - Functions
	
	override func addView() {
		[calendarView, writeButton].forEach {
			view.addSubview($0)
		}
	}
	
	override func setLayout() {
		calendarView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.height.equalTo(296)
			make.width.equalTo(356)
		}
		
		writeButton.snp.makeConstraints { make in
			make.width.height.equalTo(60)
			make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-20)
			make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
		}
	}
	
	override func setupView() {
		
	}
}

// MARK: - FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance

extension CalenderViewController: FSCalendarDelegate,
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
	
	func calendar(_ calendar: FSCalendar, didSelect date: Date,
								at monthPosition: FSCalendarMonthPosition) {
		coordinator?.showRecord(selectDate: date)
	}
	
	func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "ko_KR")
		dateFormatter.timeZone = TimeZone(abbreviation: "KST")
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		switch dateFormatter.string(from: date) {
		case dateFormatter.string(from: Date()):
			return "오늘"
			
		default:
			return nil
		}
	}
	
	// 일요일에 해당되는 모든 날짜의 색상 red로 변경
	func calendar(_ calendar: FSCalendar,
								appearance: FSCalendarAppearance,
								titleDefaultColorFor date: Date) -> UIColor? {
		let day = Calendar.current.component(.weekday, from: date) - 1
		
		if Calendar.current.shortWeekdaySymbols[day] == "일" {
			return .systemRed
		} else {
			return .label
		}
	}
}
