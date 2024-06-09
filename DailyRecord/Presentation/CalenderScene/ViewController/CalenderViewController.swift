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
	
	private lazy var calendarView: FSCalendar = {
		let calendar = FSCalendar()
		calendar.dataSource = self
		calendar.delegate = self
		
		calendar.scrollEnabled = true
		calendar.scrollDirection = .vertical
		
		// 첫 열을 월요일로 설정
		calendar.firstWeekday = 2
		// week 또는 month 가능
		calendar.scope = .month
		
		calendar.locale = Locale(identifier: "ko_KR")
		
		// 현재 달의 날짜들만 표기하도록 설정
		calendar.placeholderType = .none
		
		// 헤더뷰 설정
		calendar.headerHeight = 55
		calendar.appearance.headerDateFormat = "MM월"
		calendar.appearance.headerTitleColor = .black
		
		// 요일 UI 설정
		//			calendar.appearance.weekdayFont = UIFont.font(.pretendardRegular, ofSize: 12)
		calendar.appearance.weekdayTextColor = .black
		
		// 날짜 UI 설정
		calendar.appearance.titleTodayColor = .black
		//			calendar.appearance.titleFont = UIFont.font(.pretendardRegular, ofSize: 16)
		//			calendar.appearance.subtitleFont = UIFont.font(.pretendardMedium, ofSize: 10)
		//			calendar.appearance.subtitleTodayColor = .korailPrimaryColor
		calendar.appearance.todayColor = .white
		
		// 일요일 라벨의 textColor를 red로 설정
		calendar.calendarWeekdayView.weekdayLabels.last!.textColor = .red
		return calendar
	}()
	
	// MARK: - Life Cycle
	
	init(viewModel: CalenderViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		
		demo()
	}
	
	// MARK: - Functions
	
	override func addView() {
		
	}
	
	override func setLayout() {
		
	}
	
	override func setupView() {
		
	}
	
	func demo() {
		view.addSubview(calendarView)
		calendarView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.height.equalTo(296)
			make.width.equalTo(356)
		}
	}
}

// MARK: - FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance
extension CalenderViewController: FSCalendarDelegate,
																	FSCalendarDataSource,
																	FSCalendarDelegateAppearance {
	
	// 공식 문서에서 레이아우울을 위해 아래의 코드 요구
	func calendar(_ calendar: FSCalendar,
								boundingRectWillChange bounds: CGRect,
								animated: Bool) {
		calendar.snp.updateConstraints { (make) in
			make.height.equalTo(bounds.height)
			// Do other updates
		}
		self.view.layoutIfNeeded()
	}
	
	// 날짜 클릭
	func calendar(_ calendar: FSCalendar, didSelect date: Date,
								at monthPosition: FSCalendarMonthPosition) {
		Log.debug("tap")
		coordinator?.showRecord()
	}
	
	// 오늘 cell에 subtitle 생성
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
