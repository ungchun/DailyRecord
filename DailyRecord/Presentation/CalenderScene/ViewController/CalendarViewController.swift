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

class LoadingIndicator {
	static func showLoading() {
		DispatchQueue.main.async {
			/// 최상단에 있는 window 객체 획득
			let scenes = UIApplication.shared.connectedScenes
			let windowScene = scenes.first as? UIWindowScene
			if let window = windowScene?.windows.first {
				let loadingIndicatorView: UIActivityIndicatorView
				if let existedView = window.subviews.first(where: {
					$0 is UIActivityIndicatorView
				} ) as? UIActivityIndicatorView {
					loadingIndicatorView = existedView
				} else {
					loadingIndicatorView = UIActivityIndicatorView(style: .medium)
					/// 다른 UI가 눌리지 않도록 indicatorView의 크기를 full로 할당
					loadingIndicatorView.frame = window.frame
					loadingIndicatorView.color = .lightGray
					loadingIndicatorView.backgroundColor = .black.withAlphaComponent(0.5)
					window.addSubview(loadingIndicatorView)
				}
				loadingIndicatorView.startAnimating()
			}
		}
	}
	
	static func hideLoading() {
		DispatchQueue.main.async {
			let scenes = UIApplication.shared.connectedScenes
			let windowScene = scenes.first as? UIWindowScene
			if let window = windowScene?.windows.first {
				window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach {
					$0.removeFromSuperview()
				}
			}
		}
	}
}

final class CalendarViewController: BaseViewController {
	
	// MARK: - Properties
	
	var coordinator: CalendarCoordinator?
	
	private let viewModel: CalendarViewModel
	
	private var cancellables = Set<AnyCancellable>()
	
	// MARK: - Views
	
	private let writeButton: UIButton = {
		let button = UIButton(type: .system)
		let pencilImage = UIImage(named: "pencil")?.resizeImage(to: CGSize(width: 24,
																																			 height: 24))
		button.setImage(pencilImage, for: .normal)
		button.backgroundColor = .azDarkGray
		button.tintColor = .white
		button.layer.cornerRadius = 30
		button.layer.masksToBounds = true
		return button
	}()
	
	private lazy var calendarHeaderView: UILabel = {
		let label = UILabel()
		label.font = UIFont(name: "omyu_pretty", size: 40)
		label.textColor = .azLightGray
		label.text = dateFormat(Date(), format: "M월")
		return label
	}()
	
	private lazy var calendarView: FSCalendar = {
		let calendar = FSCalendar()
		calendar.register(CalendarCell.self, forCellReuseIdentifier: CalendarCell.description())
		calendar.dataSource = self
		calendar.delegate = self
		
		calendar.translatesAutoresizingMaskIntoConstraints = false
		calendar.scrollEnabled = true
		calendar.scrollDirection = .vertical
		calendar.today = nil
		calendar.scope = .month
		calendar.locale = Locale(identifier: "ko_KR")
		calendar.placeholderType = .none
		
		calendar.appearance.headerMinimumDissolvedAlpha = 0.0
		calendar.appearance.headerTitleColor = .clear
		calendar.appearance.weekdayTextColor = .azLightGray
		calendar.appearance.todayColor = .azDarkGray
		calendar.appearance.selectionColor = .clear
		
		calendar.appearance.titleFont = UIFont(name: "omyu_pretty", size: 12)
		return calendar
	}()
	
	// MARK: - Life Cycle
	
	init(
		viewModel: CalendarViewModel
	) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		bindViewModel()
		
		view.backgroundColor = .azBlack
		
		let currentPageDate = Date()
		if let year = Int(dateFormat(Date(), format: "yyyy")),
			 let month = Int(dateFormat(Date(), format: "M")) {
			viewModel.fetchMonthRecordTrigger(year: year, month: month)
		}
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
		[calendarHeaderView, calendarView, writeButton].forEach {
			view.addSubview($0)
		}
	}
	
	override func setLayout() {
		calendarHeaderView.snp.makeConstraints { make in
			make.leading.equalToSuperview().inset(16)
			make.bottom.equalTo(calendarView.snp.top).inset(20)
		}
		
		calendarView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.height.equalTo(296)
			make.width.equalTo(356)
			make.leading.equalToSuperview().inset(16)
			make.trailing.equalToSuperview().inset(16)
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

extension CalendarViewController {
	private func bindViewModel() {
		viewModel.$records
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.calendarView.reloadData()
				Log.debug("AZHY CALL")
			}
			.store(in: &cancellables)
	}
	
	private func dateFormat(_ date: Date, format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "ko_kr")
		dateFormatter.timeZone = TimeZone(identifier: "KST")
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: date)
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
	
	func calendar(_ calendar: FSCalendar, didSelect date: Date,
								at monthPosition: FSCalendarMonthPosition) {
		coordinator?.showRecord(selectDate: date)
	}
	
	// 일요일에 해당되는 모든 날짜의 색상 red로 변경
	func calendar(_ calendar: FSCalendar,
								appearance: FSCalendarAppearance,
								titleDefaultColorFor date: Date) -> UIColor? {
		let day = Calendar.current.component(.weekday, from: date) - 1
		
		if date > Date() {
			return .azLightGray
		}
		
		if Calendar.current.shortWeekdaySymbols[day] == "Sun" {
			return .azRed
		} else if Calendar.current.shortWeekdaySymbols[day] == "Sat" {
			return .azBlue
		} else {
			return .azWhite
		}
	}
	
	// 오늘 이후의 날짜는 선택이 불가능하다
	func maximumDate(for calendar: FSCalendar) -> Date {
		return Date()
	}
	
	func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
		let currentPage = calendar.currentPage
		calendarHeaderView.text = dateFormat(currentPage, format: "M월")
		if let year = Int(dateFormat(currentPage, format: "yyyy")),
			 let month = Int(dateFormat(currentPage, format: "M")) {
			viewModel.fetchMonthRecordTrigger(year: year, month: month)
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
		
		cell.backImageView.image = nil
		cell.titleLabel.isHidden = false
		
		viewModel.records.forEach { entity in
			let seconds = TimeInterval(entity.calendarDate) / 1000
			let responseDate = Date(timeIntervalSince1970: seconds)
			if date == responseDate {
				if let image = UIImage(named: entity.emotionType.rawValue) {
					DispatchQueue.main.async {
						cell.backImageView.image = image
						cell.titleLabel.isHidden = true
					}
				}
			}
		}
		return cell
	}
}

class CalendarCell: FSCalendarCell {
	
	// 뒤에 표시될 이미지
	var backImageView = {
		let view = UIImageView()
		view.contentMode = .scaleAspectFit
		view.clipsToBounds = true
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		// 날짜 텍스트가 디폴트로 약간 위로 올라가 있어서, 아예 레이아웃을 잡아준다
		self.titleLabel.snp.makeConstraints { make in
			make.center.equalTo(contentView)
		}
		
		contentView.insertSubview(backImageView, at: 0)
		backImageView.snp.makeConstraints { make in
			make.center.equalTo(contentView)
			make.size.equalTo(minSize())
		}
		
		/// Circle Image
		// backImageView.layer.cornerRadius = minSize()/2
	}
	
	required init(coder aDecoder: NSCoder!) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		backImageView.image = nil
	}
	
	/// 셀의 높이와 너비 중 작은 값을 리턴한다
	func minSize() -> CGFloat {
		let width = contentView.bounds.width - 5
		let height = contentView.bounds.height - 5
		return (width > height) ? height : width
	}
}
