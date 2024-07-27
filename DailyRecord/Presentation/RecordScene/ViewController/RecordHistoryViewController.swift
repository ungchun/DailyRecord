//
//  RecordHistoryViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/23/24.
//

import UIKit

import SnapKit

final class RecordHistoryViewController: BaseViewController {
	
	// MARK: - Properties
	
	var coordinator: RecordCoordinator?
	
	private let viewModel: RecordViewModel
	private let calendarViewModel: CalendarViewModel
	
	// MARK: - Views
	
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		return scrollView
	}()
	
	private let contentView: UIView = {
		let view = UIView()
		return view
	}()
	
	private let todayEmotionImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.tintColor = .azLightGray
		imageView.contentMode = .scaleAspectFit
		imageView.isUserInteractionEnabled = true
		return imageView
	}()
	
	private let createDateView: UILabel = {
		let label = UILabel()
		label.font = UIFont(name: "omyu_pretty", size: 16)
		label.textColor = .azLightGray
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()
	
	private let imageCarouselView = ImageCarouselView()
	
	private lazy var inputDiaryView: UITextView = {
		let textView = UITextView()
		textView.font = UIFont(name: "omyu_pretty", size: 16)
		textView.textColor = .azLightGray.withAlphaComponent(0.5)
		textView.backgroundColor = .clear
		textView.isScrollEnabled = false
		textView.isEditable = false
		return textView
	}()
	
	// MARK: - Init
	
	init(
		viewModel: RecordViewModel,
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
		[scrollView].forEach {
			view.addSubview($0)
		}
		
		scrollView.addSubview(contentView)
		
		[todayEmotionImageView, createDateView,
		 imageCarouselView, inputDiaryView].forEach {
			contentView.addSubview($0)
		}
	}
	
	override func setLayout() {
		scrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		contentView.snp.makeConstraints { make in
			make.edges.equalTo(scrollView.contentLayoutGuide)
			make.width.equalTo(scrollView.frameLayoutGuide)
		}
		
		todayEmotionImageView.snp.makeConstraints { make in
			make.top.equalTo(contentView.snp.top).offset(20)
			make.centerX.equalToSuperview()
			make.width.height.equalTo(30)
		}
		
		createDateView.snp.makeConstraints { make in
			make.top.equalTo(todayEmotionImageView.snp.bottom).offset(10)
			make.centerX.equalToSuperview()
		}
		
		imageCarouselView.snp.makeConstraints { make in
			make.top.equalTo(createDateView.snp.bottom).offset(20)
			make.left.right.equalToSuperview().inset(20)
			make.height.equalTo(0)
		}
		
		inputDiaryView.snp.makeConstraints { make in
			make.top.equalTo(imageCarouselView.snp.bottom).offset(20)
			make.left.right.equalToSuperview().inset(20)
			make.bottom.equalToSuperview()
		}
	}
	
	override func setupView() {
		setupNavigationBar()
		
		view.backgroundColor = .azBlack
		
		let date = Date(timeIntervalSince1970:
											TimeInterval(viewModel.selectData.calendarDate) / 1000)
		let datePart = formattedDateString(date, format: "yyyy.MM.dd")
		let dayOfWeekPart = formattedDateString(date, format: "EEEE")
		createDateView.text = "\(datePart)\n\(dayOfWeekPart)"
		
		if let image = UIImage(named: viewModel.selectData.emotionType.rawValue) {
			todayEmotionImageView.backgroundColor = .clear
			todayEmotionImageView.image = image
			let originalWidth = image.size.width
			let originalHeight = image.size.height
			let aspectRatio = originalHeight / originalWidth
			let desiredWidth: CGFloat = 80
			let desiredHeight = desiredWidth * aspectRatio
			todayEmotionImageView.snp.updateConstraints { make in
				make.width.equalTo(desiredWidth)
				make.height.equalTo(desiredHeight)
			}
		}
		
		if !viewModel.selectData.imageList.isEmpty {
			imageCarouselView.setImages(viewModel.selectData.imageList)
			
			DispatchQueue.main.async {
				self.imageCarouselView.snp.updateConstraints { make in
					make.height.equalTo(100)
				}
			}
		}
		
		inputDiaryView.text = viewModel.selectData.content
	}
}

extension RecordHistoryViewController {
	private func setupNavigationBar() {
		let largeConfig = UIImage.SymbolConfiguration(pointSize: 16,
																									weight: .bold, scale: .large)
		let iconImage = UIImage(systemName: "ellipsis",
														withConfiguration: largeConfig)?.rotated(by: 90)
		let editButtonItem = UIBarButtonItem(
			image: iconImage,
			style: .plain,
			target: self, action: #selector(editButtonTapped)
		)
		navigationItem.rightBarButtonItem = editButtonItem
	}
	
	@objc private func editButtonTapped() {
		print("Right bar button tapped")
	}
	
	private func formattedDateString(_ date: Date, format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "ko_kr")
		dateFormatter.timeZone = TimeZone(identifier: "KST")
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: date)
	}
}