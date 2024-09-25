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

import FirebaseAuth

final class ProfileViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: ProfileCoordinator?
  
  private let viewModel: ProfileViewModel
  private let calendarViewModel: CalendarViewModel
  private let appleSignInService = AppleSignInService.shared
  
  private var isAnonymously: Bool = false
  
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
    
    isAnonymously = Auth.auth().currentUser?.isAnonymous ?? false
  }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return isAnonymously
    ? viewModel.profileCellItems.count - 2 : viewModel.profileCellItems.count - 1
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: ProfileViewController.reuseIdentifier,
      for: indexPath
    )
    
    let items: [ProfileCellItem] = isAnonymously
    ? [.appleLogin, .darkMode]
    : [.appleLoginComplete, .darkMode, .deleteAccount]
    
    let item = items[indexPath.row]
    
    cell.textLabel?.text = item.rawValue
    cell.textLabel?.font = UIFont(name: "omyu_pretty", size: 16)
    cell.textLabel?.textColor = item == .deleteAccount ? .red : .azWhite
    
    let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .default)
    cell.imageView?.image = UIImage(systemName: item.iconName, withConfiguration: config)
    cell.imageView?.tintColor = item == .deleteAccount ? .red : .azWhite
    
    cell.selectionStyle = .none
    cell.backgroundColor = .azBlack
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let items: [ProfileCellItem] = isAnonymously
    ? [.appleLogin, .darkMode]
    : [.appleLoginComplete, .darkMode, .deleteAccount]
    
    let selectedItem = items[indexPath.row]
    
    switch selectedItem {
    case .appleLogin:
      appleLoginTrigger()
    case .darkMode:
      darkModeTrigger()
    case .deleteAccount:
      showRemoveUserAlert()
    default:
      break
    }
  }
}

extension ProfileViewController {
  private func appleLoginTrigger() {
    Task {
      do {
        let credential = try await appleSignInService.startSignInWithAppleFlow()
        if Auth.auth().currentUser?.isAnonymous == true {
          try await linkAnonymousAccountWithApple(credential: credential)
        } else {
          try await signInWithCredential(credential)
        }
      } catch {
        handleError(self.coordinator!, "애플 로그인 에러 발생")
      }
    }
  }
  
  private func linkAnonymousAccountWithApple(credential: AuthCredential) async throws {
    do {
      let authResult = try await Auth.auth().currentUser?.link(with: credential)
      try await handleAuthResult(authResult)
    } catch {
      /// https://github.com/firebase/firebase-ios-sdk/issues/12146
      let authError = error as? AuthErrorCode
      if let newCredential = authError?.userInfo[AuthErrorUserInfoUpdatedCredentialKey]
          as? AuthCredential {
        let authResult = try await Auth.auth().signIn(with: newCredential)
        try await handleAuthResult(authResult)
      } else {
        handleError(self.coordinator!, "사용자 데이터 생성 중 오류가 발생했어요")
      }
    }
  }
  
  private func signInWithCredential(_ credential: AuthCredential) async throws {
    do {
      let authResult = try await Auth.auth().signIn(with: credential)
      try await handleAuthResult(authResult)
    } catch {
      handleError(self.coordinator!, "사용자 데이터 생성 중 오류가 발생했어요")
    }
  }
  
  private func handleAuthResult(_ authResult: AuthDataResult?) async throws {
    appleSignInService.handleAuthorizationResult(
      authResult: authResult, error: nil
    ) { [weak self] _ in
      guard let self else { return }
      Task {
        do {
          try await self.createUserAndFetchRecord()
        } catch {
          self.handleError(self.coordinator!, "사용자 데이터 생성 중 오류가 발생했어요")
        }
      }
    }
  }
  
  private func createUserAndFetchRecord() async throws {
    do {
      try await viewModel.createUserTirgger()
      if let year = Int(formattedDateString(Date(), format: "yyyy")),
         let month = Int(formattedDateString(Date(), format: "M")) {
        try await calendarViewModel.fetchMonthRecordTrigger(year: year, month: month) {
          WidgetCenter.shared.reloadAllTimelines()
          
          self.handleError(self.coordinator!, "애플 로그인 연동 성공")
          
          self.coordinator?.popToRoot()
        }
      }
    } catch {
      handleError(self.coordinator!, "사용자 데이터 생성 중 오류가 발생했어요")
    }
  }
  
  private func darkModeTrigger() {
    coordinator?.showSetDarkmode()
  }
  
  private func showRemoveUserAlert() {
    let alertController = UIAlertController(
      title: "회원 탈퇴",
      message: "정말 탈퇴 하시겠어요? 회원 탈퇴 후 복구는 어려워요",
      preferredStyle: .alert
    )
    
    let cancelAction = UIAlertAction(title: "탈퇴하기", style: .destructive) { _ in
      Task { [weak self] in
        guard let self else { return }
        do {
          try await self.viewModel.removeUserTrigger()
        } catch {
          // 에러 발생
        }
      }
    }
    
    alertController.addAction(cancelAction)
    
    let deleteAction = UIAlertAction(title: "취소", style: .default) { _ in }
    alertController.addAction(deleteAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  private func formattedDateString(_ date: Date, format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_kr")
    dateFormatter.timeZone = TimeZone(identifier: "KST")
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
  }
}
