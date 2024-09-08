//
//  ProfileViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/1/24.
//

import AuthenticationServices
import CryptoKit
import UIKit

import FirebaseAuth

final class ProfileViewController: BaseViewController {
	
	// MARK: - Properties
	
	var coordinator: ProfileCoordinator?
	
	private let viewModel: ProfileViewModel
	private let calendarViewModel: CalendarViewModel
	private let appleSignInService = AppleSignInService.shared
	
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
		return viewModel.profileCellItems.count - 1
	}
	
	func tableView(_ tableView: UITableView,
								 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: ProfileViewController.reuseIdentifier,
			for: indexPath
		)
		
		let items: [ProfileCellItem] = UserDefaultsSetting.isAnonymously
		? [.linkAccount, .darkMode, .deleteAccount]
		: [.appleLogin, .darkMode, .deleteAccount]
		
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
		
		let items: [ProfileCellItem] = UserDefaultsSetting.isAnonymously
		? [.linkAccount, .darkMode, .deleteAccount]
		: [.appleLogin, .darkMode, .deleteAccount]
		
		let selectedItem = items[indexPath.row]
		
		switch selectedItem {
		case .linkAccount:
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
				try await signInWithCredential(credential)
			} catch {
				await MainActor.run {
					self.showToast(message: "Apple 로그인 중 오류가 발생했습니다.")
					self.coordinator?.popToRoot()
				}
			}
		}
	}
	
	private func signInWithCredential(_ credential: AuthCredential) async throws {
		do {
			let authResult = try await Auth.auth().signIn(with: credential)
			appleSignInService.handleAuthorizationResult(
				authResult: authResult, error: nil, completion: {_ in
					Task {
						do {
							try await self.viewModel.createUserTirgger()
							if let year = Int(self.formattedDateString(Date(), format: "yyyy")),
								 let month = Int(self.formattedDateString(Date(), format: "M")) {
								try await self.calendarViewModel.fetchMonthRecordTrigger(
									year: year, month: month
								) {
									self.coordinator?.popToRoot()
								}
							}
						} catch {
							self.showToast(message: "사용자 데이터 생성 중 오류가 발생했습니다.")
							self.coordinator?.popToRoot()
						}
					}
				})
		} catch {
			throw error
		}
	}
	
	private func darkModeTrigger() {
		coordinator?.showSetDarkmode()
	}
	
	private func showRemoveUserAlert() {
		let alertController = UIAlertController(
			title: "회원 탈퇴",
			message: "정말 탈퇴하시겠습니까? 회원 탈퇴 후 복구는 어렵습니다",
			preferredStyle: .alert
		)
		
		let cancelAction = UIAlertAction(title: "탈퇴하기", style: .destructive) { _ in
			Task { [weak self] in
				do {
					try await self?.viewModel.removeUserTrigger()
				} catch {
					self?.showToast(message: "에러가 발생했어요")
					self?.coordinator?.popToRoot()
				}
			}
		}
		alertController.addAction(cancelAction)
		
		let deleteAction = UIAlertAction(title: "취소", style: .cancel) { _ in }
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
