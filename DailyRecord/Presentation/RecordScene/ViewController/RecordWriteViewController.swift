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
	
	private var isChangeContent = false
	private var selectedAssetIdentifiers = [String]()
	private var selections = [String : PHPickerResult]()
	
	// MARK: - Views
	
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.showsVerticalScrollIndicator = false
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
		textView.autocapitalizationType = .none
		textView.spellCheckingType = .no
		textView.autocorrectionType = .no
		textView.setLineSpacing(lineSpacing: 8)
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
		
		self.navigationController?.isNavigationBarHidden = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.navigationController?.isNavigationBarHidden = false
		self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
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
			make.height.equalTo(viewModel.selectData.imageListURL.isEmpty
													? 0 : 100)
		}
		
		inputDiaryView.snp.makeConstraints { make in
			make.top.equalTo(self.attachedImageCollectionView.snp.bottom).offset(20)
			make.left.right.equalToSuperview().inset(20)
			make.bottom.equalToSuperview()
		}
		
		footerView.snp.makeConstraints { make in
			make.bottom.equalToSuperview()
			make.left.right.equalToSuperview()
		}
	}
	
	override func setupView() {
		setupKeyboardNotifications()
		
		setupCustomBackButton()
		
		setupSwipeGesture()
		
		fetchEditData()
		
		DispatchQueue.main.async { [weak self] in
			self?.view.backgroundColor = .azBlack
		}
		
		let date = Date(timeIntervalSince1970:
											TimeInterval(viewModel.selectData.calendarDate) / 1000)
		let datePart = formattedDateString(date, format: "yyyy.MM.dd")
		let dayOfWeekPart = formattedDateString(date, format: "EEEE")
		DispatchQueue.main.async { [weak self] in
			self?.todayDateView.text = "\(datePart)\n\(dayOfWeekPart)"
		}
		
		let showPopupTapGesture = UITapGestureRecognizer(target: self,
																										 action: #selector(showPopupTrigger))
		todayEmotionImageView.addGestureRecognizer(showPopupTapGesture)
		
		footerView.backgroundColor = .azBlack
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

extension RecordWriteViewController: UIGestureRecognizerDelegate {
	private func setupCustomBackButton() {
		let largeConfig = UIImage.SymbolConfiguration(pointSize: 16,
																									weight: .bold, scale: .large)
		let iconImage = UIImage(systemName: "chevron.left",
														withConfiguration: largeConfig)
		let backButton = UIBarButtonItem(
			image: iconImage,
			style: .plain,
			target: self,
			action: #selector(customBackButtonTapped)
		)
		backButton.tintColor = .azWhite
		navigationItem.leftBarButtonItem = backButton
	}
	
	@objc private func customBackButtonTapped() {
		if isChangeContent {
			showAlertToConfirmExit()
		} else {
			navigationController?.popViewController(animated: true)
		}
	}
	
	private func setupSwipeGesture() {
		navigationController?.interactivePopGestureRecognizer?.delegate = self
	}
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		if isChangeContent {
			showAlertToConfirmExit()
			return false
		}
		return true
	}
	
	private func showAlertToConfirmExit() {
		let alert = UIAlertController(
			title: "글쓰기를 중단할까요?",
			message: "변경된 내용이 저장되지 않아요",
			preferredStyle: .alert
		)
		let stayAction = UIAlertAction(title: "계속 작성", style: .default, handler: nil)
		let exitAction = UIAlertAction(title: "나가기", style: .cancel) {_ in
			self.navigationController?.popViewController(animated: true)
		}
		alert.addAction(stayAction)
		alert.addAction(exitAction)
		present(alert, animated: true, completion: nil)
	}
}

private extension RecordWriteViewController {
	func fetchEditData() {
		if viewModel.selectData.createTime != 0 {
			viewModel.setNotImageData {
				self.updateNotImageView()
			}
			
			self.updateImageView()
		}
	}
	
	func updateNotImageView() {
		if !self.viewModel.content.isEmpty {
			DispatchQueue.main.async { [weak self] in
				self?.inputDiaryView.text = self?.viewModel.content
			}
			inputDiaryView.textColor = .azWhite
		}
		
		emotionalImageTapTrigger(selectEmotionType: viewModel.emotionType)
	}
	
	func updateImageView() {
		attachedImageCollectionView.setImages(viewModel.imageList)
	}
}

private extension RecordWriteViewController {
	func setupKeyboardNotifications() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillShow),
			name: UIResponder.keyboardWillShowNotification, object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide),
			name: UIResponder.keyboardWillHideNotification, object: nil
		)
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
				as? NSValue {
			let keyboardHeight = keyboardFrame.cgRectValue.height
			adjustFooterViewForKeyboard(show: true, keyboardHeight: keyboardHeight)
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		adjustFooterViewForKeyboard(show: false, keyboardHeight: 0)
	}
	
	func adjustFooterViewForKeyboard(show: Bool, keyboardHeight: CGFloat) {
		footerView.snp.updateConstraints { make in
			if show {
				make.bottom.equalToSuperview().offset(-(keyboardHeight)+30)
			} else {
				make.bottom.equalToSuperview()
			}
		}
		
		scrollView.contentInset = UIEdgeInsets(
			top: 0.0,
			left: 0.0,
			bottom: keyboardHeight + footerView.frame.size.height,
			right: 0.0
		)
		
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
}

private extension RecordWriteViewController {
	@objc func showPopupTrigger() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.emotionalImagePopupView.frame = self.view.bounds
		}
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closePopupTrigger))
		emotionalImagePopupView.dimmingView.addGestureRecognizer(tapGesture)
		
		view.addSubview(emotionalImagePopupView)
		emotionalImagePopupView.showPopup()
	}
	
	@objc func closePopupTrigger() {
		DispatchQueue.main.async { [weak self] in
			self?.emotionalImagePopupView.hidePopup { [weak self] in
				self?.emotionalImagePopupView.removeFromSuperview()
			}
		}
		isChangeContent = true
	}
	
	@objc func galleryTrigger() {
		var configuration = PHPickerConfiguration(photoLibrary: .shared())
		configuration.filter = .images
		configuration.selectionLimit = 5
		configuration.selection = .ordered
		configuration.preselectedAssetIdentifiers = selectedAssetIdentifiers
		configuration.preferredAssetRepresentationMode = .current
		
		let picker = PHPickerViewController(configuration: configuration)
		picker.delegate = self
		present(picker, animated: true, completion: nil)
	}
	
	@objc func saveTrigger() {
		view.endEditing(true)
		LoadingIndicator.showLoading()
		viewModel.imageList = attachedImageCollectionView.images
		Task { [weak self] in
			guard let self else { return }
			do {
				try await self.viewModel.createRecordTirgger()
				
				let calendarDate = self.viewModel.selectData.calendarDate
				let date = Date(timeIntervalSince1970: TimeInterval(calendarDate) / 1000)
				let dayOfyear = self.formattedDateString(date, format: "yyyy")
				let dayOfmonth = self.formattedDateString(date, format: "M")
				
				if let year = Int(dayOfyear),
					 let month = Int(dayOfmonth) {
					do {
						try await self.calendarViewModel.fetchMonthRecordTrigger(
							year: year, month: month
						) { }
					} catch {
						handleError(self.coordinator!, "에러가 발생했어요")
					}
					LoadingIndicator.hideLoading()
					handleError(self.coordinator!, "일기를 작성했어요!")
				}
			} catch {
				handleError(self.coordinator!, "에러가 발생했어요")
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
	}
}

extension RecordWriteViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		viewModel.content = textView.text
		isChangeContent = true
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text == "오늘 하루는 어떠셨나요" {
			guard textView.textColor == .azLightGray.withAlphaComponent(0.5) else { return }
			textView.text = nil
			textView.textColor = .azWhite
		}
	}
}

extension RecordWriteViewController: PHPickerViewControllerDelegate {
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		picker.dismiss(animated: true, completion: nil)
		
		let dispatchGroup = DispatchGroup()
		
		var newSelections = [String: PHPickerResult]()
		for result in results {
			let identifier = result.assetIdentifier!
			newSelections[identifier] = selections[identifier] ?? result
		}
		
		selections = newSelections
		selectedAssetIdentifiers = results.compactMap { $0.assetIdentifier }
		
		var imagesDict = [String: UIImage]()
		var selectedImages: [UIImage] = []
		
		for (identifier, result) in selections {
			
			dispatchGroup.enter()
			
			let itemProvider = result.itemProvider
			if itemProvider.canLoadObject(ofClass: UIImage.self) {
				itemProvider.loadObject(ofClass: UIImage.self) { image, error in
					if let image = image as? UIImage {
						imagesDict[identifier] = image
						dispatchGroup.leave()
					}
				}
			}
		}
		
		dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
			guard let self = self else { return }
			for identifier in self.selectedAssetIdentifiers {
				guard let image = imagesDict[identifier] else { return }
				selectedImages.append(image)
				
				if results.count == selectedImages.count {
					DispatchQueue.main.async { [weak self] in
						self?.attachedImageCollectionView.setImages(selectedImages)
						self?.attachedImageCollectionView.snp.updateConstraints { make in
							make.height.equalTo(100)
						}
					}
				}
			}
		}
	}
}
