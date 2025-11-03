//
//  SetScreenLockViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 10/19/24.
//

import UIKit

import SnapKit

final class SetScreenLockViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: ProfileCoordinator?
  
  // MARK: - Views
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.ScreenLock.description
    label.font = UIFont(name: "omyu_pretty", size: 18)
    label.textColor = .azGray
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()
  
  private let divider: UIView = {
    let view = UIView()
    view.backgroundColor = .azDarkGray
    return view
  }()
  
  private let passwordIcon: UIImageView = {
    let imageView = UIImageView()
    let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .default)
    imageView.image = UIImage(systemName: "lock", withConfiguration: config)
    imageView.tintColor = .azWhite
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let passwordLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.ScreenLock.password
    label.font = UIFont(name: "omyu_pretty", size: 18)
    label.textColor = .azWhite
    return label
  }()
  
  private let passwordSwitch: UISwitch = {
    let toggle = UISwitch()
    toggle.isOn = false
    toggle.onTintColor = .azWhite
    toggle.thumbTintColor = .azBlack
    toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    return toggle
  }()
  
  private lazy var passwordStackView: UIStackView = {
    let spacer = UIView()
    let stackView = UIStackView(
      arrangedSubviews: [
        passwordIcon,
        passwordLabel,
        spacer,
        passwordSwitch
      ]
    )
    stackView.axis = .horizontal
    stackView.spacing = 10
    stackView.alignment = .center
    return stackView
  }()
  
  private let changePasswordIcon: UIImageView = {
    let imageView = UIImageView()
    let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .default)
    imageView.image = UIImage(systemName: "arrow.clockwise", withConfiguration: config)
    imageView.tintColor = .azWhite
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let changePasswordLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.ScreenLock.changePassword
    label.font = UIFont(name: "omyu_pretty", size: 18)
    label.textColor = .azWhite
    return label
  }()
  
  private lazy var changePasswordStackView: UIStackView = {
    let spacer = UIView()
    let stackView = UIStackView(
      arrangedSubviews: [changePasswordIcon, changePasswordLabel, spacer]
    )
    stackView.axis = .horizontal
    stackView.spacing = 10
    stackView.alignment = .center
    stackView.isUserInteractionEnabled = true
    return stackView
  }()
  
  private let biometricIcon: UIImageView = {
    let imageView = UIImageView()
    let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .default)
    imageView.image = UIImage(systemName: "faceid", withConfiguration: config)
    imageView.tintColor = .azWhite
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let biometricLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.ScreenLock.biometric
    label.font = UIFont(name: "omyu_pretty", size: 18)
    label.textColor = .azWhite
    return label
  }()
  
  private let biometricSwitch: UISwitch = {
    let toggle = UISwitch()
    toggle.isOn = false
    toggle.onTintColor = .azWhite
    toggle.thumbTintColor = .azBlack
    toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    return toggle
  }()
  
  private lazy var biometricStackView: UIStackView = {
    let spacer = UIView()
    let stackView = UIStackView(
      arrangedSubviews: [biometricIcon, biometricLabel, spacer, biometricSwitch]
    )
    stackView.axis = .horizontal
    stackView.spacing = 10
    stackView.alignment = .center
    return stackView
  }()
  
  private lazy var containerStackView: UIStackView = {
    let stackView = UIStackView(
      arrangedSubviews: [
        passwordStackView,
        changePasswordStackView,
        biometricStackView
      ]
    )
    stackView.axis = .vertical
    stackView.spacing = 12
    return stackView
  }()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadSettings()
  }
  
  // MARK: - Functions
  
  override func addView() {
    view.addSubview(descriptionLabel)
    view.addSubview(divider)
    view.addSubview(containerStackView)
  }
  
  override func setLayout() {
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
      make.leading.equalToSuperview().offset(16)
      make.trailing.equalToSuperview().offset(-16)
    }
    
    divider.snp.makeConstraints { make in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
      make.height.equalTo(1)
      make.leading.equalToSuperview().offset(32)
      make.trailing.equalToSuperview().offset(-32)
    }
    
    containerStackView.snp.makeConstraints { make in
      make.top.equalTo(divider.snp.bottom).offset(20)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    changePasswordStackView.snp.makeConstraints { make in
      make.height.equalTo(0)
    }
  }
  
  override func setupView() {
    view.backgroundColor = .azBlack
    
    passwordSwitch.addTarget(self, action: #selector(passwordSwitchChanged), for: .valueChanged)
    biometricSwitch.addTarget(self, action: #selector(biometricSwitchChanged), for: .valueChanged)
    
    let changePasswordGesture = UITapGestureRecognizer(
      target: self, action: #selector(changePasswordTapped)
    )
    changePasswordStackView.addGestureRecognizer(changePasswordGesture)
  }
}

extension SetScreenLockViewController {
  private func loadSettings() {
    passwordSwitch.isOn = UserDefaultsSetting.isPasswordEnabled
    biometricSwitch.isOn = UserDefaultsSetting.isBiometricEnabled
    updateChangePasswordVisibility()
  }
  
  private func updateChangePasswordVisibility() {
    let isEnabled = UserDefaultsSetting.isPasswordEnabled
    changePasswordStackView.isHidden = !isEnabled
    
    changePasswordStackView.snp.updateConstraints { make in
      make.height.equalTo(isEnabled ? 24 : 0)
    }
    
    biometricSwitch.isEnabled = isEnabled
    biometricIcon.alpha = isEnabled ? 1.0 : 0.3
    biometricLabel.alpha = isEnabled ? 1.0 : 0.3
    if !isEnabled {
      biometricSwitch.isOn = false
      UserDefaultsSetting.isBiometricEnabled = false
    }
  }
  
  @objc private func passwordSwitchChanged(_ sender: UISwitch) {
    if sender.isOn {
      sender.isOn = false
      showPasswordInputAlert()
    } else {
      disablePassword()
    }
  }
  
  @objc private func biometricSwitchChanged(_ sender: UISwitch) {
    UserDefaultsSetting.isBiometricEnabled = sender.isOn
  }
  
  @objc private func changePasswordTapped() {
    guard UserDefaultsSetting.isPasswordEnabled else {
      return
    }
    showPasswordChangeAlert()
  }
  
  private func showPasswordInputAlert() {
    let vc = PasswordInputViewController(mode: .set) { [weak self] password in
      self?.dismiss(animated: true) {
        self?.savePassword(password)
      }
    }
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true)
  }
  
  private func showPasswordChangeAlert() {
    let vc = PasswordInputViewController(mode: .change) { [weak self] password in
      guard let self = self else { return }
      
      self.dismiss(animated: true) {
        do {
          try KeyChainManager.shared.create(account: .password, data: password)
        } catch {
          self.showAlert(message: L10n.ScreenLock.passwordChangeFailed)
        }
      }
    }
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true)
  }
  
  private func savePassword(_ password: String) {
    do {
      try KeyChainManager.shared.create(account: .password, data: password)
      UserDefaultsSetting.isPasswordEnabled = true
      passwordSwitch.isOn = true
      updateChangePasswordVisibility()
    } catch {
      showAlert(message: L10n.ScreenLock.passwordSaveFailed)
      passwordSwitch.isOn = false
    }
  }
  
  private func disablePassword() {
    do {
      try KeyChainManager.shared.delete(account: .password)
      UserDefaultsSetting.isPasswordEnabled = false
      updateChangePasswordVisibility()
    } catch {
      showAlert(message: L10n.ScreenLock.passwordDeleteFailed)
      passwordSwitch.isOn = true
    }
  }
  
  private func showAlert(message: String) {
    let alert = UIAlertController(
      title: nil,
      message: message,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: L10n.Common.confirm, style: .default))
    present(alert, animated: true)
  }
}
