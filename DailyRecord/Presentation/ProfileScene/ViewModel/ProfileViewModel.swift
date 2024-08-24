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

enum ProfileCellItem: String, CaseIterable {
	case appleLogin = "애플 로그인 연동"
	case linkAccount = "계정 연동"
	case darkMode = "다크 모드"
	case deleteAccount = "회원 탈퇴"
	
	var iconName: String {
		switch self {
		case .appleLogin:
			return "apple.logo"
		case .linkAccount:
			return "link.circle"
		case .darkMode:
			return "moon"
		case .deleteAccount:
			return "trash"
		}
	}
}

final class ProfileViewModel: BaseViewModel {
	
	// MARK: - Properties
	
	let profileCellItems = ProfileCellItem.allCases.map { $0.rawValue }
	
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
			try KeyChainManager.shared.create(account: .uid, data: userID)
		}
	}
	
	func removeUserTrigger() async throws {
		try await profileUseCase.removeUser()
	}
}
