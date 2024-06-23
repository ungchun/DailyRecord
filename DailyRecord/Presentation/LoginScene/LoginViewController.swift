//
//  LoginViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/22/24.
//

import AuthenticationServices
import CryptoKit
import UIKit

import FirebaseAuth
import KakaoSDKAuth
import KakaoSDKUser
import SnapKit

final class LoginViewController: BaseViewController {
	
	// MARK: - Properties
	
	var coordinator: LoginCoordinator?
	
	private let viewModel: LoginViewModel
	
	private var currentNonce: String = ""
	
	// MARK: - Views
	
	private let appleLoginButton: UIButton = {
		let button = UIButton()
		button.backgroundColor = .black
		button.setTitle("Apple Login", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 5
		return button
	}()
	
	private let anonymousButton: UIButton = {
		let button = UIButton()
		button.backgroundColor = .white
		button.setTitle("둘러보기", for: .normal)
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
		[appleLoginButton, anonymousButton].forEach {
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
		
		anonymousButton.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(appleLoginButton.snp.bottom).offset(20)
			make.width.equalTo(200)
			make.height.equalTo(50)
		}
	}
	
	override func setupView() {
		view.backgroundColor = .white
		
		let appleLoginTapGesture = UITapGestureRecognizer(target: self,
																											action: #selector(appleLoginTrigger))
		appleLoginButton.addGestureRecognizer(appleLoginTapGesture)
		
		let anonymousTapGesture = UITapGestureRecognizer(target: self,
																										 action: #selector(anonymousTrigger))
		anonymousButton.addGestureRecognizer(anonymousTapGesture)
	}
}

private extension LoginViewController {
	@objc func appleLoginTrigger() {
		startSignInWithAppleFlow()
	}
	
	@objc func anonymousTrigger() {
		// TODO: 둘러보기, 캘린더 뷰로 이동
	}
	
	@objc func kakaoLoginTrigger() {
		// TODO: 앱 출시 후 카카오 로그인 추가
	}
}

extension LoginViewController: ASAuthorizationControllerDelegate {
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

extension LoginViewController {
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
				self?.coordinator?.showCalender()
			}
		}
	}
}

extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return self.view.window!
	}
}
