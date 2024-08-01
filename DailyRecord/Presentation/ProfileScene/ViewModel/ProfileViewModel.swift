//
//  ProfileViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/1/24.
//

import Foundation

import FirebaseAuth

enum LoginPlatForm: String {
	case apple
}

final class ProfileViewModel: BaseViewModel {
	
	// MARK: - Properties
	
	private let profileUseCase: DefaultProfileUseCase
	
	private let randomNickname: [String] = [
		"햇살러버", "포근한위로", "따스한하루", "솔라스마일", "온기드림",
		"블루스카이", "선샤인브리즈", "윈터블룸", "미스틱모먼트", "글로우위시"
	]
	
	// MARK: - Init
	
	init(
		profileUseCase: DefaultProfileUseCase
	) {
		self.profileUseCase = profileUseCase
	}
}

extension ProfileViewModel {
	
	// MARK: - Functions
	
	func createUserTirgger() async throws {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		let resposne = try await profileUseCase.getUserInfo()
		
		if resposne == nil {
			let userRequest = UserRequest(uid: "",
																		nickname: randomNickname.randomElement()!,
																		platform: LoginPlatForm.apple.rawValue,
																		fcm_token: "")
			let userData = try userRequest.asDictionary()
			
			try await profileUseCase.createUser(data: userData)
		} else {
			UserDefaultsSetting.uid = userID
		}
	}
}
