//
//  EmotionalImagePopupView.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/20/24.
//

import UIKit

import SnapKit

protocol EmotionalImagePopupViewDelegate: AnyObject {
	func emotionalImageTapTrigger(tempImageName: String)
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
	
	private let demoImage1: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "cry")
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let demoImage2: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "happy")
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let demoImage3: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "sad")
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let demoImage4: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "smile")
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let demoImage5: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(named: "thinking")
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
		demoImage1.addGestureRecognizer(tapGesture1)
		demoImage1.tag = 1
		
		let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
		demoImage2.addGestureRecognizer(tapGesture2)
		demoImage2.tag = 2
		
		let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
		demoImage3.addGestureRecognizer(tapGesture3)
		demoImage3.tag = 3
		
		let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
		demoImage4.addGestureRecognizer(tapGesture4)
		demoImage4.tag = 4
		
		let tapGesture5 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
		demoImage5.addGestureRecognizer(tapGesture5)
		demoImage5.tag = 5
	}
	
	@objc private func imageTapped(_ sender: UITapGestureRecognizer) {
		guard let tappedView = sender.view else { return }
		
		switch tappedView.tag {
		case 1:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(tempImageName: "cry")
			}
		case 2:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(tempImageName: "happy")
			}
		case 3:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(tempImageName: "sad")
			}
		case 4:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(tempImageName: "smile")
			}
		case 5:
			hidePopup {
				self.delegate?.emotionalImageTapTrigger(tempImageName: "thinking")
			}
		default:
			break
		}
	}
}
