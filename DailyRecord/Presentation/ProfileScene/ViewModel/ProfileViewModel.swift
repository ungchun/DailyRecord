//
//  ProfileViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/1/24.
//

import Foundation

enum ProfileCellItem: String, CaseIterable {
  case iCloud = "iCloud 동기화"
  case darkMode = "다크 모드"
  
  var iconName: String {
    switch self {
    case .iCloud:
      return "icloud"
    case .darkMode:
      return "moon"
    }
  }
}

final class ProfileViewModel: BaseViewModel {
  
  // MARK: - Properties
  
  let profileCellItems = ProfileCellItem.allCases.map { $0.rawValue }
  
  private let profileUseCase: DefaultProfileUseCase
  
  // MARK: - Init
  
  init(
    profileUseCase: DefaultProfileUseCase
  ) {
    self.profileUseCase = profileUseCase
  }
}
