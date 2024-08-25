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
		return view
	}()
	
	private let emotionalImagePopupView: UIView = {
		let view = UIView()
		view.backgroundColor = .azWhite
		view.layer.cornerRadius = 16
		return view
	}()
	
	private let veryHappyEmotion: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "very_happy")
		view.sizeToFit()
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let happyEmotion: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "happy")
		view.sizeToFit()
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let neutralEmotion: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "neutral")
		view.sizeToFit()
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let verySadEmotion: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "very_sad")
		view.sizeToFit()
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let sadEmotion: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "sad")
		view.sizeToFit()
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let angryEmotion: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "angry")
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
		
		[veryHappyEmotion, happyEmotion, neutralEmotion,
		 verySadEmotion, sadEmotion, angryEmotion].forEach {
			emotionalImagePopupView.addSubview($0)
		}
	}
	
	override func setLayout() {
		dimmingView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		veryHappyEmotion.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.left.equalToSuperview().offset(20)
			make.width.height.equalTo(60)
		}
		
		happyEmotion.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.centerX.equalToSuperview()
			make.width.height.equalTo(60)
		}
		
		neutralEmotion.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
			make.width.height.equalTo(60)
		}
		
		verySadEmotion.snp.makeConstraints { make in
			make.top.equalTo(happyEmotion.snp.bottom).offset(20)
			make.left.equalToSuperview().offset(20)
			make.width.height.equalTo(60)
		}
		
		sadEmotion.snp.makeConstraints { make in
			make.top.equalTo(happyEmotion.snp.bottom).offset(20)
			make.centerX.equalToSuperview()
			make.width.height.equalTo(60)
		}
		
		angryEmotion.snp.makeConstraints { make in
			make.top.equalTo(neutralEmotion.snp.bottom).offset(20)
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
		DispatchQueue.main.async { [weak self] in
			self?.dimmingView.alpha = 0
			self?.emotionalImagePopupView.alpha = 0
		}
		addTapGestures()
	}
}

extension EmotionalImagePopupView {
	func showPopup() {
		DispatchQueue.main.async { [weak self] in
			UIView.animate(withDuration: 0.6) {
				self?.dimmingView.alpha = 1
				self?.emotionalImagePopupView.alpha = 1
			}
		}
	}
	
	func hidePopup(completion: @escaping () -> Void) {
		DispatchQueue.main.async { [weak self] in
			UIView.animate(withDuration: 0.3, animations: {
				self?.dimmingView.alpha = 0
				self?.emotionalImagePopupView.alpha = 0
			}) { _ in
				completion()
			}
		}
	}
	
	private func addTapGestures() {
		let veryHappyTapGesture = UITapGestureRecognizer(
			target: self,
			action: #selector(imageTapped(_:))
		)
		veryHappyEmotion.addGestureRecognizer(veryHappyTapGesture)
		veryHappyEmotion.tag = 1
		
		let happyTapGesture = UITapGestureRecognizer(
			target: self,
			action: #selector(imageTapped(_:))
		)
		happyEmotion.addGestureRecognizer(happyTapGesture)
		happyEmotion.tag = 2
		
		let neutralTapGesture = UITapGestureRecognizer(
			target: self,
			action: #selector(imageTapped(_:))
		)
		neutralEmotion.addGestureRecognizer(neutralTapGesture)
		neutralEmotion.tag = 3
		
		let verySadTapGesture = UITapGestureRecognizer(
			target: self,
			action: #selector(imageTapped(_:))
		)
		verySadEmotion.addGestureRecognizer(verySadTapGesture)
		verySadEmotion.tag = 4
		
		let sadTapGesture = UITapGestureRecognizer(
			target: self,
			action: #selector(imageTapped(_:))
		)
		sadEmotion.addGestureRecognizer(sadTapGesture)
		sadEmotion.tag = 5
		
		let angryTapGesture = UITapGestureRecognizer(
			target: self,
			action: #selector(imageTapped(_:))
		)
		angryEmotion.addGestureRecognizer(angryTapGesture)
		angryEmotion.tag = 6
	}
	
	@objc private func imageTapped(_ sender: UITapGestureRecognizer) {
		guard let tappedView = sender.view else { return }
		
		switch tappedView.tag {
		case 1:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(selectEmotionType: .very_happy)
			}
		case 2:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(selectEmotionType: .happy)
			}
		case 3:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(selectEmotionType: .neutral)
			}
		case 4:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(selectEmotionType: .very_sad)
			}
		case 5:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(selectEmotionType: .sad)
			}
		case 6:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(selectEmotionType: .angry)
			}
		default:
			break
		}
	}
}
