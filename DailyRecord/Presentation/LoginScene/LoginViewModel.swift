//
//  LoginViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/22/24.
//

import Foundation

import FirebaseAuth

enum LoginPlatForm: String {
	case apple
}

final class LoginViewModel: BaseViewModel {
	
	// MARK: - Properties
	
	let firestoreService = FirestoreService.shared
	
	let randomNickname: [String] = [
		"햇살러버", "포근한위로", "따스한하루", "솔라스마일", "온기드림",
		"블루스카이", "선샤인브리즈", "윈터블룸", "미스틱모먼트", "글로우위시"
	]
}

extension LoginViewModel {
	
	// MARK: - Functions
	
	@MainActor
	func createUserTirgger() async throws {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		let resposne = try await firestoreService.read(collectionPath: .user,
																									 docID: userID)
		if resposne == nil {
			let userRequest = UserRequest(uid: "",
																		nickname: randomNickname.randomElement()!,
																		platForm: LoginPlatForm.apple.rawValue,
																		fcmToken: "")
			let userData = try userRequest.asDictionary()
			try await firestoreService.create(collectionPath: .user,
																				data: userData)
			
		} else {
			UserDefaultsSetting.uid = userID
		}
	}
}