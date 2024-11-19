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
  case appRating = "앱 평가하기"
  
  var iconName: String {
    switch self {
    case .iCloud:
      return "icloud"
    case .darkMode:
      return "moon"
    case .appRating:
      return "star"
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
