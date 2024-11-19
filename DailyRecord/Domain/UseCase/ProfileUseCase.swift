//
//  LoginUseCase.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import Foundation

protocol DefaultProfileUseCase {
  
}

final class ProfileUseCase: DefaultProfileUseCase {
	let profileRepository: DefaultProfileRepository
	
	init(profileRepository: DefaultProfileRepository) {
		self.profileRepository = profileRepository
	}
}

extension ProfileUseCase {
  
}
