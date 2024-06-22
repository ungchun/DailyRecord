//
//  EmotionalImagePopupView.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/20/24.
//

import UIKit

import SnapKit

final class EmotionalImagePopupView: BaseView {
	
	// MARK: - Views
	
	let dimmingView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		return view
	}()
	
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
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	// MARK: - Functions
	
	override func addView() {
		addSubview(dimmingView)
		addSubview(emotionalImagePopupView)
		
		[demoImage1, demoImage2, demoImage3, demoImage4, demoImage5].forEach {
			emotionalImagePopupView.addSubview($0)
		}
	}
	
	override func setLayout() {
		dimmingView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
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
	}
	
	override func setupView() {
		dimmingView.alpha = 0
		emotionalImagePopupView.alpha = 0
	}
}

extension EmotionalImagePopupView {
	func showPopup() {
		UIView.animate(withDuration: 0.3) {
			self.dimmingView.alpha = 1
			self.emotionalImagePopupView.alpha = 1
		}
	}
	
	func hidePopup(completion: @escaping () -> Void) {
		UIView.animate(withDuration: 0.3, animations: {
			self.dimmingView.alpha = 0
			self.emotionalImagePopupView.alpha = 0
		}) { _ in
			completion()
		}
	}
}
