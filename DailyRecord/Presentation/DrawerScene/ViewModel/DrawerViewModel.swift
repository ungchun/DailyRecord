//
//  DrawerViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 11/30/24.
//

import Foundation

final class DrawerViewModel: BaseViewModel {
  
  // MARK: - Properties
  
  private(set) var currentDate: Date
  
  // MARK: - Init
  
  init(
    currentDate: Date
  ) {
    self.currentDate = currentDate
  }
}
