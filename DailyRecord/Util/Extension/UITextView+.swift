//
//  UITextView+.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/26/24.
//

import UIKit

extension UITextView {
	/// 행간
	func setLineSpacing(lineSpacing: CGFloat) {
		guard let existingAttributedString = self.attributedText else {
			return
		}
		let mutableAttributedString = NSMutableAttributedString(
			attributedString: existingAttributedString
		)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = lineSpacing
		
		mutableAttributedString.addAttribute(
			NSAttributedString.Key.paragraphStyle,
			value: paragraphStyle,
			range: NSMakeRange(0, mutableAttributedString.length)
		)
		self.attributedText = mutableAttributedString
	}
	
	/// 자간
	func addCharacterSpacing(_ value: Double = -0.03) {
		let kernValue = self.font!.pointSize * CGFloat(value)
		guard let text = text, !text.isEmpty else { return }
		let string = NSMutableAttributedString(string: text)
		string.addAttribute(NSAttributedString.Key.kern,
												value: kernValue,
												range: NSRange(location: 0, length: string.length - 1))
		attributedText = string
	}
}
