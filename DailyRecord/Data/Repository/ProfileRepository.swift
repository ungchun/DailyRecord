//
//  LoginRepository.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Firebase
import FirebaseFirestore

final class ProfileRepository: NSObject, DefaultProfileRepository {
	private let db = Firestore.firestore()
	
	private let appleSignInService = AppleSignInService.shared
}

extension ProfileRepository {
	func createUser(data: [String : Any]) async throws {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		let documentRef = db.collection("user")
		try await documentRef.document(userID).setData(data)
		try await updateUserInfo(updateData: ["uid": userID])
		try KeyChainManager.shared.create(account: .uid, data: userID)
		UserDefaultsSetting.uid = userID
	}
	
	func getUserInfo() async throws -> UserResponseDTO? {
		guard let userID = Auth.auth().currentUser?.uid else { return nil }
		let documentRef = db.collection("user").document(userID)
		let snapshot = try await documentRef.getDocument()
		
		if let data = snapshot.data() {
			let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
			return try JSONDecoder().decode(UserResponseDTO.self, from: jsonData)
		} else {
			return nil
		}
	}
	
	func updateUserInfo(updateData: [String: Any]) async throws {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		let documentRef = db.collection("user").document(userID)
		try await documentRef.updateData(updateData)
	}
	
	func removeUser() async throws {
		do {
			let credential = try await appleSignInService.startSignInWithAppleFlow()
			try await reauthenticateAndDeleteUser(with: credential)
		} catch {
			throw error
		}
	}
	
	private func reauthenticateAndDeleteUser(with credential: AuthCredential) async throws {
		guard let user = Auth.auth().currentUser else {
			throw NSError()
		}
		
		do {
			_ = try await user.reauthenticate(with: credential)
			try await user.delete()
			try deleteKeychainDataAndSignOut()
		} catch {
			throw error
		}
	}
	
	private func deleteKeychainDataAndSignOut() throws {
		try KeyChainManager.shared.delete(account: .uid)
		try KeyChainManager.shared.delete(account: .idTokenString)
		try KeyChainManager.shared.delete(account: .nonce)
		try Auth.auth().signOut()
		exit(0)
	}
}
