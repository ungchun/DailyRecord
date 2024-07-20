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
}
