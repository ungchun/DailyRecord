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
			make.width.height.equalTo(0)
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
		
		DispatchQueue.main.async { [weak self] in
			self?.view.backgroundColor = .azBlack
		}
		
		let date = Date(timeIntervalSince1970:
											TimeInterval(viewModel.selectData.calendarDate) / 1000)
		let datePart = formattedDateString(date, format: "yyyy.MM.dd")
		let dayOfWeekPart = formattedDateString(date, format: "EEEE")
		DispatchQueue.main.async { [weak self] in
			self?.createDateView.text = "\(datePart)\n\(dayOfWeekPart)"
		}
		
		if let image = UIImage(named: viewModel.selectData.emotionType.rawValue) {
			DispatchQueue.main.async { [weak self] in
				self?.todayEmotionImageView.backgroundColor = .clear
				self?.todayEmotionImageView.image = image
			}
			
			let originalWidth = image.size.width
			let originalHeight = image.size.height
			let aspectRatio = originalHeight / originalWidth
			let desiredWidth: CGFloat = 80
			let desiredHeight = desiredWidth * aspectRatio
			DispatchQueue.main.async { [weak self] in
				self?.todayEmotionImageView.snp.updateConstraints { make in
					make.width.equalTo(desiredWidth)
					make.height.equalTo(desiredHeight)
				}
			}
		}
		
		if !viewModel.selectData.imageListURL.isEmpty {
			viewModel.setImageData {
				if !self.viewModel.imageList.isEmpty {
					self.imageCarouselView.setImages(self.viewModel.imageList)
					DispatchQueue.main.async { [weak self] in
						self?.imageCarouselView.snp.updateConstraints { make in
							make.height.equalTo(100)
						}
					}
				}
			}
		}
		
		DispatchQueue.main.async { [weak self] in
			self?.inputDiaryView.text = self?.viewModel.selectData.content
		}
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
			primaryAction: nil,
			menu: menu
		)
		navigationItem.rightBarButtonItem = editButtonItem
	}
	
	private var menu: UIMenu {
		return UIMenu(title: "",
									image: nil,
									identifier: nil,
									options: [], children: menuItems)
	}
	
	private var menuItems: [UIAction] {
		return [UIAction(title: "수정하기",
										 image: UIImage(systemName: "pencil"),
										 handler: { _ in
			self.coordinator?.showWriteViewController(self.viewModel)}),
						UIAction(title: "삭제하기",
										 image: UIImage(systemName: "trash"),
										 attributes: .destructive,
										 handler: { _ in
			let alert = UIAlertController (title: "일기 삭제", message:
																			"정말로 일기를 삭제할까요?", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "취소", style: .default) { _ in })
			alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
				Task { [weak self] in
					do {
						try await self?.viewModel.removeRecordTirgger()
						if let calendarDate = self?.viewModel.selectData.calendarDate {
							let date = Date(timeIntervalSince1970:
																TimeInterval(calendarDate) / 1000)
							if let dayOfyear = self?.formattedDateString(date, format: "yyyy"),
								 let dayOfmonth = self?.formattedDateString(date, format: "M") {
								if let year = Int(dayOfyear),
									 let month = Int(dayOfmonth) {
									do {
										try await self?.calendarViewModel.fetchMonthRecordTrigger(
											year: year, month: month
										) { }
									} catch {
										self?.showToast(message: "에러가 발생했어요")
										self?.coordinator?.popToRoot()
									}
									self?.showToast(message: "일기를 삭제했어요!")
									self?.coordinator?.popToRoot()
								}
							}
						}
					} catch {
						self?.showToast(message: "에러가 발생했어요")
						self?.coordinator?.popToRoot()
					}
				}
			})
			self.present(alert, animated: true, completion: nil)
		})]
	}
	
	private func formattedDateString(_ date: Date, format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "ko_kr")
		dateFormatter.timeZone = TimeZone(identifier: "KST")
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: date)
	}
}
