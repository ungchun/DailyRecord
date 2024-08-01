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
	
	private var currentNonce: String = ""
	
	// MARK: - Views
	
	// MARK: - Init
	
	init(
		viewModel: ProfileViewModel
	) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .yellow
	}
	
	// MARK: - Functions
	
	override func addView() {
		
	}
	
	override func setLayout() {
		
	}
	
	override func setupView() {
		
	}
}

extension ProfileViewController {
	
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
					Log.debug("SecRandomCopyBytes failed", errorCode)
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
				Log.debug("Unable to fetch identity token")
				return
			}
			guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
				Log.debug("Unable to serialize token string from data",
									"\(appleIDToken.debugDescription)")
				return
			}
			
			let credential = OAuthProvider.credential(withProviderID: "apple.com",
																								idToken: idTokenString,
																								rawNonce: nonce)
			Auth.auth().signIn(with: credential) { [weak self] authResult, error in
				if let error = error {
					Log.error(error)
					return
				}
				
				Task {
					do {
						try await self?.viewModel.createUserTirgger()
					} catch {
						self?.showToast(message: "에러가 발생했어요")
						self?.coordinator?.popToRoot()
					}
				}
			}
		}
	}
}

extension ProfileViewController : ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return self.view.window!
	}
}
