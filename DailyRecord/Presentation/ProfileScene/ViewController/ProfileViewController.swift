//
//  ProfileViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/1/24.
//

import AuthenticationServices
import CryptoKit
import StoreKit
import UIKit
import WidgetKit

final class ProfileViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: ProfileCoordinator?
  
  private let viewModel: ProfileViewModel
  private let calendarViewModel: CalendarViewModel
  
  private let appStoreID = "6664067346"
  
  // MARK: - Views
  
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 20
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  private let divider: UIView = {
    let view = UIView()
    view.backgroundColor = .azWhite.withAlphaComponent(0.3)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private lazy var iCloudButton: UIButton = self.createButton(for: .iCloud)
  private lazy var darkModeButton: UIButton = self.createButton(for: .darkMode)
  private lazy var appRatingButton: UIButton = self.createButton(for: .appRating)
  
  // MARK: - Init
  
  init(
    viewModel: ProfileViewModel,
    calendarViewModel: CalendarViewModel
  ) {
    self.viewModel = viewModel
    self.calendarViewModel = calendarViewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Functions
  
  override func addView() {
    view.addSubview(stackView)
    
    [iCloudButton, darkModeButton, divider, appRatingButton].forEach {
      stackView.addArrangedSubview($0)
    }
  }
  
  override func setLayout() {
    stackView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    divider.snp.makeConstraints { make in
      make.height.equalTo(1)
    }
  }
  
  override func setupView() {
    view.backgroundColor = .azBlack
  }
  
  private func createButton(for item: ProfileCellItem) -> UIButton {
    var configuration = UIButton.Configuration.plain()
    configuration.title = item.rawValue
    configuration.titleTextAttributesTransformer
    = UIConfigurationTextAttributesTransformer { incoming in
      var outgoing = incoming
      outgoing.font = UIFont(name: "omyu_pretty", size: 16)
      return outgoing
    }
    
    configuration.baseForegroundColor = .azWhite
    
    let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .default)
    configuration.image = UIImage(
      systemName: item.iconName,
      withConfiguration: config
    )?.withRenderingMode(.alwaysTemplate)
    configuration.imagePadding = 10
    configuration.imagePlacement = .leading
    configuration.contentInsets = NSDirectionalEdgeInsets(
      top: 0, leading: 0, bottom: 0, trailing: 0
    )
    
    let button = UIButton(configuration: configuration)
    button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    button.contentHorizontalAlignment = .leading
    
    return button
  }
  
  @objc private func buttonTapped(_ sender: UIButton) {
    if sender == iCloudButton {
      iCloudTrigger()
    } else if sender == darkModeButton {
      darkModeTrigger()
    } else if sender == appRatingButton {
      openAppStore()
    }
  }
}

extension ProfileViewController {
  private func iCloudTrigger() {
    coordinator?.showSetiCloud()
  }
  
  private func darkModeTrigger() {
    coordinator?.showSetDarkmode()
  }
  
  private func openAppStore() {
    let urlStr = "https://itunes.apple.com/app/id\(appStoreID)?action=write-review"
    if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
}
