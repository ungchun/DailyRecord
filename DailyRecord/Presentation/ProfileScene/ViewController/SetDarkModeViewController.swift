//
//  SetDarkModeViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/24/24.
//

import UIKit

import SnapKit

final class SetDarkModeViewController: BaseViewController {
	
	// MARK: - Properties
	
	var coordinator: ProfileCoordinator?
	
	// MARK: - Views
	
	private var selectedMode: UIButton?
	
	private let systemModeLabel: UILabel = {
		let label = UILabel()
		label.text = "시스템 설정"
		label.font = UIFont(name: "omyu_pretty", size: 16)
		label.textColor = .azWhite
		return label
	}()
	
	private let systemModeButton: UIButton = {
		let button = UIButton()
		let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .default)
		button.setImage(UIImage(systemName: "circle", withConfiguration: config), for: .normal)
		button.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: config),
										for: .selected)
		button.tintColor = .azWhite
		return button
	}()
	
	private lazy var systemModeStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [systemModeLabel, systemModeButton])
		stackView.axis = .horizontal
		stackView.distribution = .equalSpacing
		stackView.isUserInteractionEnabled = true
		return stackView
	}()
	
	private let lightModeLabel: UILabel = {
		let label = UILabel()
		label.text = "라이트 모드"
		label.font = UIFont(name: "omyu_pretty", size: 16)
		label.textColor = .azWhite
		return label
	}()
	
	private let lightModeButton: UIButton = {
		let button = UIButton()
		let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .default)
		button.setImage(UIImage(systemName: "circle", withConfiguration: config), for: .normal)
		button.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: config),
										for: .selected)
		button.tintColor = .azWhite
		return button
	}()
	
	private lazy var lightModeStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [lightModeLabel, lightModeButton])
		stackView.axis = .horizontal
		stackView.distribution = .equalSpacing
		stackView.isUserInteractionEnabled = true
		return stackView
	}()
	
	private let darkModeLabel: UILabel = {
		let label = UILabel()
		label.text = "다크 모드"
		label.font = UIFont(name: "omyu_pretty", size: 16)
		label.textColor = .azWhite
		return label
	}()
	
	private let darkModeButton: UIButton = {
		let button = UIButton()
		let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .default)
		button.setImage(UIImage(systemName: "circle", withConfiguration: config), for: .normal)
		button.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: config),
										for: .selected)
		button.tintColor = .azWhite
		return button
	}()
	
	private lazy var darkModeStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [darkModeLabel, darkModeButton])
		stackView.axis = .horizontal
		stackView.distribution = .equalSpacing
		stackView.isUserInteractionEnabled = true
		return stackView
	}()
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	// MARK: - Functions
	
	override func addView() {
		view.addSubview(systemModeStackView)
		view.addSubview(lightModeStackView)
		view.addSubview(darkModeStackView)
	}
	
	override func setLayout() {
		systemModeStackView.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
		}
		
		lightModeStackView.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
			make.top.equalTo(systemModeStackView.snp.bottom).offset(16)
		}
		
		darkModeStackView.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
			make.top.equalTo(lightModeStackView.snp.bottom).offset(16)
		}
	}
	
	override func setupView() {
		view.backgroundColor = .azBlack
		
		let didTapSystemModeGesture = UITapGestureRecognizer(target: self,
																												 action: #selector(didTapModeButton))
		systemModeStackView.addGestureRecognizer(didTapSystemModeGesture)
		
		let didTapLightModeGesture = UITapGestureRecognizer(target: self,
																												action: #selector(didTapModeButton))
		lightModeStackView.addGestureRecognizer(didTapLightModeGesture)
		
		let didTapDarkModeGesture = UITapGestureRecognizer(target: self,
																											 action: #selector(didTapModeButton))
		darkModeStackView.addGestureRecognizer(didTapDarkModeGesture)
	}
}

extension SetDarkModeViewController {
	@objc private func didTapModeButton(_ sender: UITapGestureRecognizer) {
		guard let stackView = sender.view as? UIStackView else { return }
		
		if let tappedButton = stackView.arrangedSubviews.first(
			where: { $0 is UIButton }
		) as? UIButton {
			selectedMode?.isSelected = false
			tappedButton.isSelected = true
			selectedMode = tappedButton
			
			if tappedButton == systemModeButton {
				// 시스템 설정 모드 선택
			} else if tappedButton == lightModeButton {
				// 라이트 모드 선택
			} else if tappedButton == darkModeButton {
				// 다크 모드 선택
			}
		}
	}
}
