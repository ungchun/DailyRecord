//
//  RecordViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/6/24.
//

import UIKit
import PhotosUI

import SnapKit

final class RecordViewController: BaseViewController {
	
	// MARK: - Properties
	
	var coordinator: RecordCoordinator?
	
	private let viewModel: RecordViewModel
	
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
		imageView.backgroundColor = .yellow
		imageView.isUserInteractionEnabled = true
		return imageView
	}()
	
	private let todayDateView: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		return label
	}()
	
	private lazy var inputDiaryView: UITextView = {
		let textView = UITextView()
		textView.text = "placeholder"
		textView.textColor = .secondaryLabel
		textView.font = .systemFont(ofSize: 15.0)
		textView.delegate = self
		textView.backgroundColor = .green
		textView.isScrollEnabled = false
		return textView
	}()
	
	private let attachedImageCollectionView = AttachedImageCollectionView()
	
	private let footerView = RecordFooterView()
	
	private let emotionalImagePopupView = EmotionalImagePopupView()
	
	// MARK: - Life Cycle
	
	init(
		viewModel: RecordViewModel
	) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// 작성이 안 되어 있으면 화면 가운데 alert 올라오게
	}
	
	// MARK: - Functions
	
	override func addView() {
		[scrollView, footerView].forEach {
			view.addSubview($0)
		}
		
		scrollView.addSubview(contentView)
		
		[todayEmotionImageView, todayDateView, attachedImageCollectionView, inputDiaryView].forEach {
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
			make.width.height.equalTo(100)
		}
		
		todayDateView.snp.makeConstraints { make in
			make.top.equalTo(todayEmotionImageView.snp.bottom).offset(20)
			make.centerX.equalToSuperview()
		}
		
		attachedImageCollectionView.snp.makeConstraints { make in
			make.top.equalTo(todayDateView.snp.bottom).offset(20)
			make.left.right.equalToSuperview().inset(20)
			make.height.equalTo(0)
		}
		
		inputDiaryView.snp.makeConstraints { make in
			make.top.equalTo(self.attachedImageCollectionView.snp.bottom).offset(20)
			make.left.right.equalToSuperview().inset(20)
			make.bottom.equalToSuperview()
		}
		
		footerView.snp.makeConstraints { make in
			make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
			make.left.right.equalToSuperview()
			make.height.equalTo(30)
		}
	}
	
	override func setupView() {
		view.backgroundColor = .white
		
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "ko_KR")
		formatter.dateFormat = "yyyy.MM.dd.EEEE"
		formatter.timeZone = TimeZone(abbreviation: "KST")
		let selectedDateInKST = formatter.string(from: viewModel.selectDate)
		todayDateView.text = selectedDateInKST
		
		let showPopupTapGesture = UITapGestureRecognizer(target: self,
																										 action: #selector(showPopupTrigger))
		todayEmotionImageView.addGestureRecognizer(showPopupTapGesture)
		
		let galleryTapGesture = UITapGestureRecognizer(target: self, action: #selector(galleryTrigger))
		footerView.galleryIcon.addGestureRecognizer(galleryTapGesture)
		
		let saveTapGesture = UITapGestureRecognizer(target: self, action: #selector(saveTrigger))
		footerView.saveIcon.addGestureRecognizer(saveTapGesture)
		
		attachedImageCollectionView.delegate = self
		emotionalImagePopupView.delegate = self
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tapGesture)
	}
}

private extension RecordViewController {
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
		viewModel.imageList = attachedImageCollectionView.images
		Task {
			try await viewModel.createRecordTirgger()
		}
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}

extension RecordViewController: AttachedImageCollectionViewDelegate {
	func collectionViewZeroHeightTrigger() {
		DispatchQueue.main.async { [weak self] in
			self?.attachedImageCollectionView.snp.updateConstraints { make in
				make.height.equalTo(0.5)
			}
		}
	}
}

extension RecordViewController: EmotionalImagePopupViewDelegate {
	func emotionalImageTapTrigger(tempImageName: String) {
		todayEmotionImageView.backgroundColor = .clear
		todayEmotionImageView.image = UIImage(named: tempImageName)
	}
}

extension RecordViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		viewModel.content = textView.text
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		guard textView.textColor == .secondaryLabel else { return }
		textView.text = nil
		textView.textColor = .label
	}
}

extension RecordViewController: PHPickerViewControllerDelegate {
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
