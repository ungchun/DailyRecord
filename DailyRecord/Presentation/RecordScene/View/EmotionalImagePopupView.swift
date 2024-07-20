//
//  EmotionalImagePopupView.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/20/24.
//

import UIKit

import SnapKit

protocol EmotionalImagePopupViewDelegate: AnyObject {
	func emotionalImageTapTrigger(selectEmotionType: EmotionType)
}

final class EmotionalImagePopupView: BaseView {
	
	// MARK: - Properties
	
	weak var delegate: EmotionalImagePopupViewDelegate?
	
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
	
	private let happyEmotion: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "happy")
		view.sizeToFit()
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let goodEmotion: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "good")
		view.sizeToFit()
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let normalEmotion: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "normal")
		view.sizeToFit()
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let badEmotion: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "bad")
		view.sizeToFit()
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let irritationEmotion: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "irritation")
		view.sizeToFit()
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let sickEmotion: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "sick")
		view.sizeToFit()
		view.isUserInteractionEnabled = true
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
		
		[happyEmotion, goodEmotion, normalEmotion, badEmotion, irritationEmotion, sickEmotion].forEach {
			emotionalImagePopupView.addSubview($0)
		}
	}
	
	override func setLayout() {
		dimmingView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		happyEmotion.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.left.equalToSuperview().offset(20)
			make.width.height.equalTo(60)
		}
		
		goodEmotion.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.centerX.equalToSuperview()
			make.width.equalTo(60)
			make.height.equalTo(50)
		}
		
		normalEmotion.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
			make.width.height.equalTo(60)
		}
		
		badEmotion.snp.makeConstraints { make in
			make.top.equalTo(happyEmotion.snp.bottom).offset(20)
			make.left.equalToSuperview().offset(20)
			make.width.equalTo(60)
			make.height.equalTo(50)
		}
		
		irritationEmotion.snp.makeConstraints { make in
			make.top.equalTo(goodEmotion.snp.bottom).offset(20)
			make.centerX.equalToSuperview()
			make.width.height.equalTo(60)
		}
		
		sickEmotion.snp.makeConstraints { make in
			make.top.equalTo(normalEmotion.snp.bottom).offset(20)
			make.right.equalToSuperview().offset(-20)
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
		
		addTapGestures()
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
	
	private func addTapGestures() {
		let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
		happyEmotion.addGestureRecognizer(tapGesture1)
		happyEmotion.tag = 1
		
		let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
		goodEmotion.addGestureRecognizer(tapGesture2)
		goodEmotion.tag = 2
		
		let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
		normalEmotion.addGestureRecognizer(tapGesture3)
		normalEmotion.tag = 3
		
		let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
		badEmotion.addGestureRecognizer(tapGesture4)
		badEmotion.tag = 4
		
		let tapGesture5 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
		irritationEmotion.addGestureRecognizer(tapGesture5)
		irritationEmotion.tag = 5
	}
	
	@objc private func imageTapped(_ sender: UITapGestureRecognizer) {
		guard let tappedView = sender.view else { return }
		
		switch tappedView.tag {
		case 1:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(selectEmotionType: .happy)
			}
		case 2:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(selectEmotionType: .good)
			}
		case 3:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(selectEmotionType: .normal)
			}
		case 4:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(selectEmotionType: .bad)
			}
		case 5:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(selectEmotionType: .irritation)
			}
		case 6:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(selectEmotionType: .sick)
			}
		default:
			break
		}
	}
}
