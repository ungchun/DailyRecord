//
//  ProfileViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/1/24.
//

import AuthenticationServices
import CryptoKit
import UIKit
import WidgetKit

final class ProfileViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: ProfileCoordinator?
  
  private let viewModel: ProfileViewModel
  private let calendarViewModel: CalendarViewModel
  
  private static let reuseIdentifier: String = "ProfileCell"
  
  // MARK: - Views
  
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(
      UITableViewCell.self,
      forCellReuseIdentifier: ProfileViewController.reuseIdentifier
    )
    return tableView
  }()
  
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
    [tableView].forEach {
      view.addSubview($0)
    }
  }
  
  override func setLayout() {
    tableView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
  
  override func setupView() {
    view.backgroundColor = .azBlack
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = .azBlack
    tableView.separatorStyle = .none
    tableView.isScrollEnabled = false
  }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.profileCellItems.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: ProfileViewController.reuseIdentifier,
      for: indexPath
    )
    
    let items: [ProfileCellItem] = [.iCloud, .darkMode]
    
    let item = items[indexPath.row]
    
    cell.textLabel?.text = item.rawValue
    cell.textLabel?.font = UIFont(name: "omyu_pretty", size: 16)
    cell.textLabel?.textColor = .azWhite
    
    let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .default)
    cell.imageView?.image = UIImage(systemName: item.iconName, withConfiguration: config)
    cell.imageView?.tintColor = .azWhite
    
    cell.selectionStyle = .none
    cell.backgroundColor = .azBlack
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let items: [ProfileCellItem] = [.iCloud, .darkMode]
    
    let selectedItem = items[indexPath.row]
    
    switch selectedItem {
    case .iCloud:
      showiCloudAlert()
    case .darkMode:
      darkModeTrigger()
    }
  }
}

extension ProfileViewController {
  private func showiCloudAlert() {
    let alertController = UIAlertController(
      title: "iCloud 동기화",
      message: "iCloud 동기화 기능이 개발중에 있어요",
      preferredStyle: .alert
    )
    
    let deleteAction = UIAlertAction(title: "확인", style: .default) { _ in }
    alertController.addAction(deleteAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  private func darkModeTrigger() {
    coordinator?.showSetDarkmode()
  }
}
