//
//  PasswordInputViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 10/19/24.
//

import UIKit

import SnapKit

enum PasswordInputMode {
  case set
  case confirm
  case change
  case verify
  
  var titleText: String {
    switch self {
    case .set:
      return L10n.ScreenLock.enterPassword
    case .confirm:
      return L10n.ScreenLock.enterPasswordAgain
    case .change:
      return L10n.ScreenLock.enterNewPassword
    case .verify:
      return L10n.ScreenLock.enterPassword
    }
  }
}

final class PasswordInputViewController: UIViewController {
  
  // MARK: - Properties
  
  private var mode: PasswordInputMode
  private var completion: ((String) -> Void)?
  private var firstPassword: String?
  private var isShowingError = false
  private var showCloseButton: Bool
  private var password: String = "" {
    didSet {
      updateIndicators()
      
      // 에러 상태에서 다시 입력 시작하면 타이틀 복구
      if isShowingError && !password.isEmpty {
        titleLabel.text = mode.titleText
        isShowingError = false
      }
      
      if password.count == 4 {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
          guard let self = self else { return }
          self.handlePasswordComplete()
        }
      }
    }
  }
  
  // MARK: - Views
  
  private let closeButton: UIButton = {
    let button = UIButton()
    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .default)
    button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
    button.tintColor = .azWhite
    return button
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "omyu_pretty", size: 18)
    label.textColor = .azWhite
    label.textAlignment = .center
    return label
  }()
  
  private let indicatorStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 24
    stackView.distribution = .fillEqually
    return stackView
  }()
  
  private var indicators: [UIView] = []
  
  private let keypadStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 48
    stackView.distribution = .fillEqually
    return stackView
  }()
  
  // MARK: - Init
  
  init(
    mode: PasswordInputMode,
    showCloseButton: Bool = true,
    completion: @escaping (String) -> Void
  ) {
    self.mode = mode
    self.showCloseButton = showCloseButton
    self.completion = completion
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    addViews()
    setLayout()
    setupKeypad()
  }
  
  // MARK: - Functions
  
  private func setupView() {
    view.backgroundColor = .azBlack
    titleLabel.text = mode.titleText
    
    closeButton.isHidden = !showCloseButton
    closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
  }
  
  private func addViews() {
    view.addSubview(closeButton)
    view.addSubview(titleLabel)
    view.addSubview(indicatorStackView)
    view.addSubview(keypadStackView)
    
    for _ in 0..<4 {
      let indicator = UIView()
      indicator.backgroundColor = .azWhite.withAlphaComponent(0.3)
      indicator.layer.cornerRadius = 8
      indicator.snp.makeConstraints { make in
        make.width.height.equalTo(16)
      }
      indicators.append(indicator)
      indicatorStackView.addArrangedSubview(indicator)
    }
  }
  
  private func setLayout() {
    closeButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
      make.trailing.equalToSuperview().offset(-16)
      make.width.height.equalTo(44)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(200)
    }
    
    indicatorStackView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(titleLabel.snp.bottom).offset(28)
    }
    
    keypadStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(40)
      make.trailing.equalToSuperview().offset(-40)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
    }
  }
  
  private func setupKeypad() {
    let numbers = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [-1, 0, -2]
    ]
    
    for row in numbers {
      let rowStackView = UIStackView()
      rowStackView.axis = .horizontal
      rowStackView.spacing = 20
      rowStackView.distribution = .fillEqually
      
      for num in row {
        if num == -1 {
          let emptyView = UIView()
          rowStackView.addArrangedSubview(emptyView)
        } else if num == -2 {
          let deleteButton = createKeyButton(text: "")
          let config = UIImage.SymbolConfiguration(
            pointSize: 20, weight: .regular, scale: .default
          )
          let deleteImage = UIImage(systemName: "delete.left", withConfiguration: config)
          deleteButton.setImage(deleteImage, for: .normal)
          deleteButton.tintColor = .azWhite
          deleteButton.tag = -2
          rowStackView.addArrangedSubview(deleteButton)
        } else {
          let button = createKeyButton(text: "\(num)")
          button.tag = num
          rowStackView.addArrangedSubview(button)
        }
      }
      
      keypadStackView.addArrangedSubview(rowStackView)
    }
  }
  
  private func createKeyButton(text: String) -> UIButton {
    let button = UIButton()
    button.setTitle(text, for: .normal)
    button.titleLabel?.font = UIFont(name: "omyu_pretty", size: 28)
    button.setTitleColor(.azWhite, for: .normal)
    button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
    return button
  }
  
  private func updateIndicators() {
    for (index, indicator) in indicators.enumerated() {
      if index < password.count {
        indicator.backgroundColor = .azWhite
      } else {
        indicator.backgroundColor = .azWhite.withAlphaComponent(0.3)
      }
    }
  }
  
  @objc private func keyTapped(_ sender: UIButton) {
    if sender.tag == -2 {
      if !password.isEmpty {
        password.removeLast()
      }
    } else {
      if password.count < 4 {
        password.append("\(sender.tag)")
      }
    }
  }
  
  @objc private func closeTapped() {
    dismiss(animated: true)
  }
  
  private func handlePasswordComplete() {
    if mode == .set {
      // 첫 번째 비밀번호 입력 완료
      firstPassword = password
      password = ""
      mode = .confirm
      titleLabel.text = mode.titleText
      titleLabel.textColor = .azWhite
    } else if mode == .confirm {
      // 두 번째 비밀번호 입력 완료 (확인)
      if let first = firstPassword, first == password {
        // 비밀번호 일치
        completion?(password)
      } else {
        // 비밀번호 불일치 - 에러 메시지 표시
        titleLabel.text = L10n.ScreenLock.passwordMismatch
        isShowingError = true
        password = ""
      }
    } else if mode == .change {
      // 새 비밀번호 입력 완료
      firstPassword = password
      password = ""
      mode = .confirm
      titleLabel.text = mode.titleText
      titleLabel.textColor = .azWhite
    } else {
      // verify 모드는 바로 completion 호출
      completion?(password)
    }
  }
  
  func updateTitle(_ newMode: PasswordInputMode) {
    mode = newMode
    titleLabel.text = newMode.titleText
    titleLabel.textColor = .azWhite
    password = ""
  }
  
  func showError(_ message: String) {
    titleLabel.text = message
    isShowingError = true
    password = ""
  }
}
