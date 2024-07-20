//
//  UIColor+.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/20/24.
//

import UIKit

extension UIColor {
	static let azBlack = UIColor.rgbColor(red: 25, green: 25, blue: 25)
	static let azLightGray = UIColor.rgbColor(red: 125, green: 124, blue: 124)
	static let azDarkGray = UIColor.rgbColor(red: 39, green: 40, blue: 41)
	static let azWhite = UIColor.rgbColor(red: 180, green: 180, blue: 180)
	static let azRed = UIColor.rgbColor(red: 255, green: 138, blue: 174)
	static let azBlue = UIColor.rgbColor(red: 114, green: 134, blue: 211)
	
	static func rgbColor(red: CGFloat, green: CGFloat,
											 blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
		return UIColor(red: red / 255.0, green: green / 255.0,
									 blue: blue / 255.0, alpha: alpha)
	}
}
