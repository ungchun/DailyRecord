//
//  LoginViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/22/24.
//

import UIKit

import SnapKit

final class LoginViewController: BaseViewController {
	
	// MARK: - Properties
	
	var coordinator: LoginCoordinator?
	
	private let viewModel: LoginViewModel
	
	// MARK: - Views
	
	private let appleLoginButton: UIButton = {
		let button = UIButton()
		button.backgroundColor = .black
		button.setTitle("Apple Login", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 5
		return button
	}()
	
	private let kakaoLoginButton: UIButton = {
		let button = UIButton()
		button.backgroundColor = .yellow
		button.setTitle("Kakao Login", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.layer.cornerRadius = 5
		return button
	}()
	
	// MARK: - Life Cycle
	
	init(
		viewModel: LoginViewModel
	) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	// MARK: - Functions
	
	override func addView() {
		[appleLoginButton, kakaoLoginButton].forEach {
			view.addSubview($0)
		}
	}
	
	override func setLayout() {
		appleLoginButton.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().offset(-30)
			make.width.equalTo(200)
			make.height.equalTo(50)
		}
		
		kakaoLoginButton.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(appleLoginButton.snp.bottom).offset(20)
			make.width.equalTo(200)
			make.height.equalTo(50)
		}
	}
	
	override func setupView() {
		view.backgroundColor = .white
		
		let appleLoginTapGesture = UITapGestureRecognizer(target: self, action: #selector(appleLoginTrigger))
		appleLoginButton.addGestureRecognizer(appleLoginTapGesture)
		
		let kakaoLoginTapGesture = UITapGestureRecognizer(target: self, action: #selector(kakaoLoginTrigger))
		kakaoLoginButton.addGestureRecognizer(kakaoLoginTapGesture)
	}
}

private extension LoginViewController {
	@objc func kakaoLoginTrigger() {
		coordinator?.showCalender()
	}
	
	@objc func appleLoginTrigger() {
		coordinator?.showCalender()
	}
}
