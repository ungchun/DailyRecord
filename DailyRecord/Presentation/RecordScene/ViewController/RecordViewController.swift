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
	
	// MARK: - Views
	
	private let popupView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.layer.cornerRadius = 10
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOpacity = 0.3
		view.layer.shadowOffset = CGSize(width: 0, height: 2)
		view.layer.shadowRadius = 4
		return view
	}()
	
	private let closeButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Close", for: .normal)
		button.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
		return button
	}()
	
	// TODO: 감정표현 ImageView
	private let todayEmotionImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.backgroundColor = .yellow
		imageView.isUserInteractionEnabled = true
		return imageView
	}()
	
	// TODO: 오늘 날짜
	private let todayDateView: UILabel = {
		let label = UILabel()
		label.text = "오늘 날짜"
		label.textAlignment = .center
		return label
	}()
	
	// TODO: 일기 택스트 필드
	private let inputDiaryView: UIView = {
		let view = UIView()
		view.backgroundColor = .lightGray
		return view
	}()
	
	// TODO: 저장 버튼
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// 작성이 안 되어 있으면 화면 가운데 alert 올라오게
		
		view.backgroundColor = .white
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showPopup))
		todayEmotionImageView.addGestureRecognizer(tapGesture)
	}
	
	private var dimmingView: UIView?
	
	
	@objc func showPopup() {
		dimmingView = UIView(frame: view.bounds)
		dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		view.addSubview(dimmingView!)
		view.addSubview(popupView)
		popupView.addSubview(closeButton)
		
		popupView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.width.equalTo(250)
			make.height.equalTo(150)
		}
		
		closeButton.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.bottom.equalToSuperview().offset(-20)
		}
		
		// 팝업뷰 애니메이션 (선택사항)
		popupView.alpha = 0
		dimmingView?.alpha = 0
		UIView.animate(withDuration: 0.3) {
			self.popupView.alpha = 1
			self.dimmingView?.alpha = 1
		}
	}
	
	@objc func closePopup() {
		UIView.animate(withDuration: 0.3, animations: {
			self.popupView.alpha = 0
			self.dimmingView?.alpha = 0
		}) { _ in
			self.popupView.removeFromSuperview()
			self.dimmingView?.removeFromSuperview()
		}
	}
	
	
	// MARK: - Functions
	
	override func addView() {
		[todayEmotionImageView, todayDateView, inputDiaryView].forEach {
			view.addSubview($0)
		}
	}
	
	override func setLayout() {
		todayEmotionImageView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
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
			make.height.equalTo(200)
		}
	}
	
	override func setupView() {
		
	}
}
