//
//  RecordViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/6/24.
//

import UIKit
import PhotosUI

import SnapKit

final class RecordWriteViewController: BaseViewController {
	
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
		imageView.image = UIImage(systemName: "plus.circle")
		imageView.tintColor = .azLightGray
		imageView.contentMode = .scaleAspectFit
		imageView.isUserInteractionEnabled = true
		return imageView
	}()
	
	private let todayDateView: UILabel = {
		let label = UILabel()
		label.font = UIFont(name: "omyu_pretty", size: 16)
		label.textColor = .azLightGray
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()
	
	private lazy var inputDiaryView: UITextView = {
		let textView = UITextView()
		textView.delegate = self
		textView.font = UIFont(name: "omyu_pretty", size: 16)
		textView.textColor = .azLightGray.withAlphaComponent(0.5)
		textView.text = "오늘 하루는 어떠셨나요"
		textView.backgroundColor = .clear
		textView.isScrollEnabled = false
		return textView
	}()
	
	private let attachedImageCollectionView = AttachedImageCollectionView()
	
	private let footerView = RecordFooterView()
	
	private let emotionalImagePopupView = EmotionalImagePopupView()
	
	// MARK: - Life Cycle
	
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// 작성이 안 되어 있으면 화면 가운데 alert 올라오게
		
		fetchEditData()
	}
	
	// MARK: - Functions
	
	override func addView() {
		[scrollView, footerView].forEach {
			view.addSubview($0)
		}
		
		scrollView.addSubview(contentView)
		
		[todayEmotionImageView, todayDateView,
		 attachedImageCollectionView, inputDiaryView].forEach {
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
		
		todayDateView.snp.makeConstraints { make in
			make.top.equalTo(todayEmotionImageView.snp.bottom).offset(10)
			make.centerX.equalToSuperview()
		}
		
		attachedImageCollectionView.snp.makeConstraints { make in
			make.top.equalTo(todayDateView.snp.bottom).offset(20)
			make.left.right.equalToSuperview().inset(20)
			make.height.equalTo(viewModel.selectData.imageList.isEmpty
													? 0 : 100)
		}
		
		inputDiaryView.snp.makeConstraints { make in
			make.top.equalTo(self.attachedImageCollectionView.snp.bottom).offset(20)
			make.left.right.equalToSuperview().inset(20)
			make.bottom.equalToSuperview()
		}
		
		footerView.snp.makeConstraints { make in
			make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
			make.left.right.equalToSuperview()
			make.height.equalTo(30)
		}
	}
	
	override func setupView() {
		view.backgroundColor = .azBlack
		let date = Date(timeIntervalSince1970:
											TimeInterval(viewModel.selectData.calendarDate) / 1000)
		let datePart = formattedDateString(date, format: "yyyy.MM.dd")
		let dayOfWeekPart = formattedDateString(date, format: "EEEE")
		todayDateView.text = "\(datePart)\n\(dayOfWeekPart)"
		
		let showPopupTapGesture = UITapGestureRecognizer(target: self,
																										 action: #selector(showPopupTrigger))
		todayEmotionImageView.addGestureRecognizer(showPopupTapGesture)
		
		let galleryTapGesture = UITapGestureRecognizer(target: self,
																									 action: #selector(galleryTrigger))
		footerView.galleryIcon.addGestureRecognizer(galleryTapGesture)
		
		let saveTapGesture = UITapGestureRecognizer(target: self, action: #selector(saveTrigger))
		footerView.saveIcon.addGestureRecognizer(saveTapGesture)
		
		attachedImageCollectionView.delegate = self
		emotionalImagePopupView.delegate = self
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tapGesture)
	}
}

private extension RecordWriteViewController {
	func fetchEditData() {
		if viewModel.selectData.createTime != 0 {
			viewModel.setNotImageData {
				self.updateNotImageView()
			}
			
			viewModel.setImageData {
				if !self.viewModel.imageList.isEmpty {
					self.updateImageView()
				}
			}
		}
	}
	
	func updateNotImageView() {
		inputDiaryView.text = viewModel.content
		emotionalImageTapTrigger(selectEmotionType: viewModel.emotionType)
	}
	
	func updateImageView() {
		attachedImageCollectionView.setImages(viewModel.imageList)
	}
}

private extension RecordWriteViewController {
	@objc func showPopupTrigger() {
		emotionalImagePopupView.frame = view.bounds
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closePopupTrigger))
		emotionalImagePopupView.dimmingView.addGestureRecognizer(tapGesture)
		
		view.addSubview(emotionalImagePopupView)
		emotionalImagePopupView.showPopup()
	}
	
	@objc func closePopupTrigger() {
		emotionalImagePopupView.hidePopup { [weak self] in
			self?.emotionalImagePopupView.removeFromSuperview()
		}
	}
	
	@objc func galleryTrigger() {
		var configuration = PHPickerConfiguration()
		configuration.filter = .images
		configuration.selectionLimit = 5
		
		let picker = PHPickerViewController(configuration: configuration)
		picker.delegate = self
		present(picker, animated: true, completion: nil)
	}
	
	@objc func saveTrigger() {
		LoadingIndicator.showLoading()
		viewModel.imageList = attachedImageCollectionView.images
		Task { [weak self] in
			try await self?.viewModel.createRecordTirgger()
			
			if let calendarDate = self?.viewModel.selectData.calendarDate {
				let date = Date(timeIntervalSince1970:
													TimeInterval(calendarDate) / 1000)
				if let dayOfyear = self?.formattedDateString(date, format: "yyyy"),
					 let dayOfmonth = self?.formattedDateString(date, format: "M") {
					if let year = Int(dayOfyear),
						 let month = Int(dayOfmonth) {
						// TODO: TOAST
						self?.calendarViewModel.fetchMonthRecordTrigger(year: year, month: month)
						LoadingIndicator.hideLoading()
						self?.coordinator?.popToRoot()
					}
				}
			}
		}
	}
	
	private func formattedDateString(_ date: Date, format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "ko_kr")
		dateFormatter.timeZone = TimeZone(identifier: "KST")
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: date)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}

extension RecordWriteViewController: AttachedImageCollectionViewDelegate {
	func collectionViewZeroHeightTrigger() {
		DispatchQueue.main.async { [weak self] in
			self?.attachedImageCollectionView.snp.updateConstraints { make in
				make.height.equalTo(0.5)
			}
		}
	}
}

extension RecordWriteViewController: EmotionalImagePopupViewDelegate {
	func emotionalImageTapTrigger(selectEmotionType: EmotionType) {
		if let image = UIImage(named: selectEmotionType.rawValue) {
			closePopupTrigger()
			
			viewModel.emotionType = selectEmotionType
			
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
	}
}

extension RecordWriteViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		viewModel.content = textView.text
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text == "오늘 하루는 어떠셨나요" {
			guard textView.textColor == .azLightGray.withAlphaComponent(0.5) else { return }
			textView.text = nil
			textView.textColor = .azLightGray
		}
	}
}

extension RecordWriteViewController: PHPickerViewControllerDelegate {
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		picker.dismiss(animated: true, completion: nil)
		var selectedImages: [UIImage] = []
		for result in results {
			result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
				if let image = image as? UIImage {
					selectedImages.append(image)
					if results.count == selectedImages.count {
						self?.attachedImageCollectionView.setImages(selectedImages)
						DispatchQueue.main.async {
							self?.attachedImageCollectionView.snp.updateConstraints { make in
								make.height.equalTo(100)
							}
						}
					}
				}
			}
		}
	}
}
