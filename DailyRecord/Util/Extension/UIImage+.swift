//
//  UIImage+.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/20/24.
//

import UIKit

extension UIImage {
	func resizeImage(to size: CGSize) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
		self.draw(in: CGRect(origin: .zero, size: size))
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return resizedImage
	}
	
	func rotated(by degrees: CGFloat) -> UIImage? {
		let radians = degrees * CGFloat.pi / 180
		var newSize = CGRect(origin: .zero, size: self.size)
			.applying(CGAffineTransform(rotationAngle: radians)).size
		newSize.width = floor(newSize.width)
		newSize.height = floor(newSize.height)
		
		UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
		let context = UIGraphicsGetCurrentContext()!
		
		context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
		context.rotate(by: radians)
		
		self.draw(in: CGRect(x: -self.size.width / 2,
												 y: -self.size.height / 2,
												 width: self.size.width,
												 height: self.size.height))
		
		let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return rotatedImage
	}
}
