//
//  UIFont+.swift
//  DailyRecord
//
//  Created by Kim SungHun on 1/15/25.
//

import UIKit

extension UIFont {
  static func appFont(size: CGFloat) -> UIFont {
    let fontName = UserDefaults.standard.string(forKey: "selectedFontName") ?? "omyu_pretty"
    let level = UserDefaults.standard.integer(forKey: "fontSizeLevel")
    let adjustedLevel = level == 0 ? 4 : level
    let sizeOffset = CGFloat(adjustedLevel - 4)
    let adjustedSize = size + sizeOffset
    
    return UIFont(name: fontName, size: adjustedSize) ?? UIFont.systemFont(ofSize: adjustedSize)
  }
}
