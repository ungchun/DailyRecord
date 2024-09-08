//
//  AppleSignInService.swift
//  DailyRecord
//
//  Created by Kim SungHun on 9/8/24.
//

import AuthenticationServices
import CryptoKit

import FirebaseAuth

final class AppleSignInService: NSObject {
	static let shared = AppleSignInService()
	
	private var currentNonce: String = ""
	private var authCompletion: ((Result<AuthCredential, Error>) -> Void)?
	
	private override init() {
		super.init()
	}
}

extension AppleSignInService {
	func startSignInWithAppleFlow() async throws -> AuthCredential {
		return try await withCheckedThrowingContinuation { continuation in
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
			
			self.authCompletion = { result in
				switch result {
				case .success(let credential):
					continuation.resume(returning: credential)
				case .failure(let error):
					continuation.resume(throwing: error)
				}
			}
		}
	}
	
	func handleAuthorizationResult(authResult: AuthDataResult?, error: Error?,
																 completion: @escaping (Result<Void, Error>) -> Void) {
		if let error = error {
			completion(.failure(error))
			return
		}
		
		guard let uid = authResult?.user.uid,
					let idTokenString = authResult?.user.uid else {
			completion(.failure(NSError()))
			return
		}
		
		do {
			UserDefaultsSetting.isAnonymously = false
			try KeyChainManager.shared.create(account: .uid, data: uid)
			try KeyChainManager.shared.create(account: .idTokenString, data: idTokenString)
			try KeyChainManager.shared.create(account: .nonce, data: currentNonce)
			completion(.success(()))
		} catch {
			completion(.failure(error))
		}
	}
	
	private func randomNonceString(length: Int = 32) -> String {
		precondition(length > 0)
		let charset: [Character]
		= Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
		var result = ""
		var remainingLength = length
		
		while remainingLength > 0 {
			let randoms: [UInt8] = (0 ..< 16).map { _ in
				var random: UInt8 = 0
				let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
				if errorCode != errSecSuccess {
					fatalError("\(errorCode)")
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
	
	private func sha256(_ input: String) -> String {
		let inputData = Data(input.utf8)
		let hashedData = SHA256.hash(data: inputData)
		let hashString = hashedData.compactMap {
			String(format: "%02x", $0)
		}.joined()
		
		return hashString
	}
}

extension AppleSignInService: ASAuthorizationControllerDelegate {
	func authorizationController(
		controller: ASAuthorizationController,
		didCompleteWithAuthorization authorization: ASAuthorization
	) {
		if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
			 let appleIDToken = appleIDCredential.identityToken,
			 let idTokenString = String(data: appleIDToken, encoding: .utf8) {
			
			let credential = OAuthProvider.credential(withProviderID: "apple.com",
																								idToken: idTokenString,
																								rawNonce: currentNonce)
			authCompletion?(.success(credential))
		} else {
			authCompletion?(.failure(NSError()))
		}
	}
	
	func authorizationController(
		controller: ASAuthorizationController,
		didCompleteWithError error: Error
	) {
		authCompletion?(.failure(error))
	}
}

extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		let scenes = UIApplication.shared.connectedScenes
		let windowScene = scenes.first as? UIWindowScene
		let window = windowScene?.windows.first
		return window!
	}
}
