//
//  ProfileViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/1/24.
//

import Foundation

enum ProfileCellItem: CaseIterable {
  case screenLock
  case iCloud
  case darkMode
  case language
  case appRating
  case contact
  
  var title: String {
    switch self {
    case .screenLock:
      return L10n.Profile.screenLock
    case .iCloud:
      return L10n.Profile.icloudSync
    case .darkMode:
      return L10n.Profile.darkMode
    case .language:
      return L10n.Profile.language
    case .appRating:
      return L10n.Profile.rateApp
    case .contact:
      return L10n.Profile.contact
    }
  }
  
  var iconName: String {
    switch self {
    case .screenLock:
      return "lock"
    case .iCloud:
      return "icloud"
    case .darkMode:
      return "moon"
    case .language:
      return "globe"
    case .appRating:
      return "star"
    case .contact:
      return "envelope"
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
