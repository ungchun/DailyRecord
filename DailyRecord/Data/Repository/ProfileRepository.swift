//
//  LoginRepository.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Firebase
import FirebaseFirestore

final class ProfileRepository: DefaultProfileRepository {
	private let db = Firestore.firestore()
}

extension ProfileRepository {
	func createUser(data: [String : Any]) async throws {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		let documentRef = db.collection("user")
		try await withCheckedThrowingContinuation {
			(continuation: CheckedContinuation<Void, Error>) in
			documentRef.document(userID).setData(data) { [weak self] error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					Task { [weak self] in
						guard let self = self else { return }
						do {
							try await self.updateUserInfo(updateData: ["uid": userID])
							UserDefaultsSetting.uid = userID
							continuation.resume()
						} catch {
							continuation.resume(throwing: error)
						}
					}
				}
			}
		}
	}
	
	func getUserInfo() async throws -> UserResponseDTO? {
		guard let userID = Auth.auth().currentUser?.uid else { return nil }
		let documentRef = db.collection("user").document(userID)
		return try await withCheckedThrowingContinuation {
			(continuation: CheckedContinuation<UserResponseDTO?, Error>) in
			documentRef.getDocument { (snapshot, error) in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					if let data = snapshot?.data() {
						do {
							let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
							let userResponse = try JSONDecoder().decode(UserResponseDTO.self, from: jsonData)
							continuation.resume(returning: userResponse)
						} catch {
							continuation.resume(throwing: error)
						}
					} else {
						continuation.resume(returning: nil)
					}
				}
			}
		}
	}
	
	func updateUserInfo(updateData: [String: Any]) async throws {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		let documentRef = db.collection("user").document(userID)
		try await withCheckedThrowingContinuation {
			(continuation: CheckedContinuation<Void, Error>) in
			documentRef.updateData(updateData) { error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume()
				}
			}
		}
	}
	
	func removeUser() async throws {
		try await withCheckedThrowingContinuation {
			(continuation: CheckedContinuation<Void, Error>) in
			let credential = OAuthProvider.credential(withProviderID: "apple.com",
																								idToken: UserDefaultsSetting.idTokenString,
																								rawNonce: UserDefaultsSetting.nonce)
			Auth.auth().currentUser?.reauthenticate(with: credential) { _,_ in
				if let user = Auth.auth().currentUser {
					user.delete { error in
						if let error = error {
							continuation.resume(throwing: error)
						} else {
							Task {
								UserDefaultsSetting.uid = ""
								UserDefaultsSetting.idTokenString = ""
								UserDefaultsSetting.nonce = ""
								try Auth.auth().signOut()
								continuation.resume()
								exit(0)
							}
						}
					}
				} else {
					Log.debug("로그인 정보가 존재하지 않습니다.")
				}
			}
		}
	}
}
