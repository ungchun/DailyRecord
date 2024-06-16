//
//  RecordViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/6/24.
//

import UIKit

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
	
	// TODO: FooterView
	private let footerView: UIView = {
		let view = UIView()
		return view
	}()
	
	private let divider: UIView = {
		let view = UIView()
		view.backgroundColor = .red
		return view
	}()
	
	// TODO: 사진 첨부
	private let galleryIcon: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(systemName: "photo")
		view.contentMode = .scaleAspectFit
		view.isUserInteractionEnabled = true
		return view
	}()
	
	// TODO: 저장
	private let saveIcon: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(systemName: "checkmark")
		view.contentMode = .scaleAspectFit
		view.isUserInteractionEnabled = true
		return view
	}()
	
	// TODO: Custom View로 분리
	private var dimmingView: UIView?
	
	private let emotionalImagePopupView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.layer.cornerRadius = 10
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOpacity = 0.3
		view.layer.shadowOffset = CGSize(width: 0, height: 2)
		view.layer.shadowRadius = 4
		return view
	}()
	
	// TODO: 감정 이미지로 수정
	private let demoImage1: UIView = {
		let view = UIView()
		view.backgroundColor = .blue
		return view
	}()
	private let demoImage2: UIView = {
		let view = UIView()
		view.backgroundColor = .red
		return view
	}()
	private let demoImage3: UIView = {
		let view = UIView()
		view.backgroundColor = .green
		return view
	}()
	private let demoImage4: UIView = {
		let view = UIView()
		view.backgroundColor = .purple
		return view
	}()
	private let demoImage5: UIView = {
		let view = UIView()
		view.backgroundColor = .brown
		return view
	}()
	
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
		
		[todayEmotionImageView, todayDateView, inputDiaryView].forEach {
			contentView.addSubview($0)
		}
		
		[divider, galleryIcon, saveIcon].forEach {
			footerView.addSubview($0)
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
		
		inputDiaryView.snp.makeConstraints { make in
			make.top.equalTo(todayDateView.snp.bottom).offset(20)
			make.left.right.equalToSuperview().inset(20)
			make.bottom.equalToSuperview()
		}
		
		footerView.snp.makeConstraints { make in
			make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
			make.left.right.equalToSuperview()
			make.height.equalTo(30)
		}
		
		divider.snp.makeConstraints { make in
			make.top.equalTo(footerView.snp.top)
			make.left.right.equalToSuperview()
			make.height.equalTo(2)
		}
		
		galleryIcon.snp.makeConstraints { make in
			make.top.equalTo(divider.snp.bottom).offset(8)
			make.leading.equalTo(footerView.snp.leading).offset(16)
		}
		
		saveIcon.snp.makeConstraints { make in
			make.top.equalTo(divider.snp.bottom).offset(8)
			make.trailing.equalTo(footerView.snp.trailing).offset(-16)
		}
	}
	
	override func setupView() {
		view.backgroundColor = .white
		
		todayDateView.text = String(describing: viewModel.selectDate)
		
		let showPopupTapGesture = UITapGestureRecognizer(target: self,
																						action: #selector(showPopupTrigger))
		todayEmotionImageView.addGestureRecognizer(showPopupTapGesture)
		
		let galleryTapGesture = UITapGestureRecognizer(target: self,
																						action: #selector(galleryTrigger))
		galleryIcon.addGestureRecognizer(galleryTapGesture)
		
		let saveTapGesture = UITapGestureRecognizer(target: self,
																						action: #selector(saveTrigger))
		saveIcon.addGestureRecognizer(saveTapGesture)
	}
}

private extension RecordViewController {
	@objc func showPopupTrigger() {
		dimmingView = UIView(frame: view.bounds)
		dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closePopupTrigger))
		dimmingView?.addGestureRecognizer(tapGesture)
		
		view.addSubview(dimmingView!)
		view.addSubview(emotionalImagePopupView)
		
		emotionalImagePopupView.addSubview(demoImage1)
		emotionalImagePopupView.addSubview(demoImage2)
		emotionalImagePopupView.addSubview(demoImage3)
		emotionalImagePopupView.addSubview(demoImage4)
		emotionalImagePopupView.addSubview(demoImage5)
		
		demoImage1.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.left.equalToSuperview().offset(20)
			make.width.height.equalTo(60)
		}
		
		demoImage2.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.centerX.equalToSuperview()
			make.width.height.equalTo(60)
		}
		
		demoImage3.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
			make.width.height.equalTo(60)
		}
		
		demoImage4.snp.makeConstraints { make in
			make.top.equalTo(demoImage1.snp.bottom).offset(20)
			make.centerX.equalToSuperview().offset(-50)
			make.width.height.equalTo(60)
		}
		
		demoImage5.snp.makeConstraints { make in
			make.top.equalTo(demoImage3.snp.bottom).offset(20)
			make.centerX.equalToSuperview().offset(50)
			make.width.height.equalTo(60)
		}
		
		emotionalImagePopupView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.width.equalTo(250)
			make.height.equalTo(180)
		}
		
		emotionalImagePopupView.alpha = 0
		dimmingView?.alpha = 0
		UIView.animate(withDuration: 0.3) {
			self.emotionalImagePopupView.alpha = 1
			self.dimmingView?.alpha = 1
		}
	}
	
	@objc func closePopupTrigger() {
		UIView.animate(withDuration: 0.3, animations: {
			self.emotionalImagePopupView.alpha = 0
			self.dimmingView?.alpha = 0
		}) { _ in
			self.emotionalImagePopupView.removeFromSuperview()
			self.dimmingView?.removeFromSuperview()
		}
	}
	
	@objc func galleryTrigger() {
		
	}
	
	@objc func saveTrigger() {
		Log.debug("save", String(inputDiaryView.text))
	}
}

extension RecordViewController: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		guard textView.textColor == .secondaryLabel else { return }
		textView.text = nil
		textView.textColor = .label
	}
}
