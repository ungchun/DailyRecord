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
	
	private var currentNonce: String = ""
	
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
		? [.linkAccount, .deleteAccount]
		: [.appleLogin, .deleteAccount]
		
		let item = items[indexPath.row]
		
		cell.textLabel?.text = item.rawValue
		cell.textLabel?.font = UIFont(name: "omyu_pretty", size: 16)
		cell.textLabel?.textColor = item == .deleteAccount ? .red : .azWhite
		
		cell.imageView?.image = UIImage(systemName: item.iconName)
		cell.imageView?.tintColor = item == .deleteAccount ? .red : .white
		
		cell.selectionStyle = .none
		cell.backgroundColor = .azBlack
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let items: [ProfileCellItem] = UserDefaultsSetting.isAnonymously
		? [.linkAccount, .deleteAccount]
		: [.appleLogin, .deleteAccount]
		
		let selectedItem = items[indexPath.row]
		
		switch selectedItem {
		case .linkAccount:
			appleLoginTrigger()
		case .deleteAccount:
			showRemoveUserAlert()
		default:
			break
		}
	}
}

extension ProfileViewController {
	@objc private func appleLoginTrigger() {
		startSignInWithAppleFlow()
	}
	
	private func showRemoveUserAlert() {
		let alertController = UIAlertController(
			title: "회원 탈퇴",
			message: "정말 탈퇴하시겠습니까? 회원 탈퇴 후 복구는 어렵습니다.",
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
}

extension ProfileViewController: ASAuthorizationControllerDelegate {
	func startSignInWithAppleFlow() {
		let nonce = randomNonceString()
		currentNonce = nonce
		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()
		request.requestedScopes = [.fullName, .email]
		request.nonce = sha256(nonce)
		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
	}
	
	private func sha256(_ input: String) -> String {
		let inputData = Data(input.utf8)
		let hashedData = SHA256.hash(data: inputData)
		let hashString = hashedData.compactMap {
			return String(format: "%02x", $0)
		}.joined()
		
		return hashString
	}
	
	private func randomNonceString(length: Int = 32) -> String {
		precondition(length > 0)
		let charset: Array<Character> =
		Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
		var result = ""
		var remainingLength = length
		
		while remainingLength > 0 {
			let randoms: [UInt8] = (0 ..< 16).map { _ in
				var random: UInt8 = 0
				let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
				if errorCode != errSecSuccess {
					self.showToast(message: "에러가 발생했어요")
					self.coordinator?.popToRoot()
				}
				return random
			}
			
			randoms.forEach { random in
				if remainingLength == 0 {
					return
				}
				
				if random < charset.count {
					result.append(charset[Int(random)])
					remainingLength -= 1
				}
			}
		}
		return result
	}
}

extension ProfileViewController {
	func authorizationController(controller: ASAuthorizationController,
															 didCompleteWithAuthorization authorization: ASAuthorization) {
		if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
			let nonce = currentNonce
			guard let appleIDToken = appleIDCredential.identityToken else {
				self.showToast(message: "에러가 발생했어요")
				self.coordinator?.popToRoot()
				return
			}
			guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
				self.showToast(message: "에러가 발생했어요")
				self.coordinator?.popToRoot()
				return
			}
			
			let credential = OAuthProvider.credential(withProviderID: "apple.com",
																								idToken: idTokenString,
																								rawNonce: nonce)
			
			let appleIDProvider = ASAuthorizationAppleIDProvider()
			appleIDProvider.getCredentialState(forUserID: appleIDCredential.user) {
				(credentialState, error) in
				switch credentialState {
				case .authorized:
					Auth.auth().signIn(with: credential) { (authResult, error) in
						if let error = error {
							if (error as NSError).code == AuthErrorCode.credentialAlreadyInUse.rawValue {
								self.showToast(message: "에러가 발생했어요")
								self.coordinator?.popToRoot()
							}
							return
						} else {
							if let uid = authResult?.user.uid {
								UserDefaultsSetting.isAnonymously = false
								UserDefaultsSetting.uid = uid
								UserDefaultsSetting.idTokenString = idTokenString
								UserDefaultsSetting.nonce = nonce
								
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
										self.showToast(message: "에러가 발생했어요")
										self.coordinator?.popToRoot()
									}
								}
							}
						}
					}
				case .revoked:
					Log.debug("REVOKED")
				case .notFound:
					Auth.auth().currentUser?.link(with: credential) { authResult, error in
						if let error = error {
							Log.error(error)
							self.showToast(message: "에러가 발생했어요")
							self.coordinator?.popToRoot()
						} else {
							if let user = authResult?.user {
								UserDefaultsSetting.isAnonymously = false
								UserDefaultsSetting.uid = user.uid
								UserDefaultsSetting.idTokenString = idTokenString
								UserDefaultsSetting.nonce = nonce
								Task {
									do {
										try await self.viewModel.createUserTirgger()
									} catch {
										Log.error(error)
										self.showToast(message: "에러가 발생했어요")
										self.coordinator?.popToRoot()
									}
								}
							}
						}
					}
				default:
					break
				}
			}
		}
	}
	
	private func formattedDateString(_ date: Date, format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "ko_kr")
		dateFormatter.timeZone = TimeZone(identifier: "KST")
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: date)
	}
}

extension ProfileViewController : ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return self.view.window!
	}
}
