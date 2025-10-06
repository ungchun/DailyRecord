//
//  ProfileViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/1/24.
//

import Foundation

enum ProfileCellItem: CaseIterable {
  case iCloud
  case darkMode
  case language
  case appRating

  var title: String {
    switch self {
    case .iCloud:
      return L10n.Profile.icloudSync
    case .darkMode:
      return L10n.Profile.darkMode
    case .language:
      return L10n.Profile.language
    case .appRating:
      return L10n.Profile.rateApp
    }
  }

  var iconName: String {
    switch self {
    case .iCloud:
      return "icloud"
    case .darkMode:
      return "moon"
    case .language:
      return "globe"
    case .appRating:
      return "star"
    }
  }
}

final class ProfileViewModel: BaseViewModel {
  
  // MARK: - Properties
  
  let profileCellItems = ProfileCellItem.allCases
  
  private let profileUseCase: DefaultProfileUseCase
  
  // MARK: - Init
  
  init(
    profileUseCase: DefaultProfileUseCase
  ) {
    self.profileUseCase = profileUseCase
  }
}
