//
//  UIViewController+.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/28/24.
//

import UIKit

extension UIViewController {
	func handleError(_ coordinator: any Coordinator,
									 _ message: String) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			
			self.showToast(message: message)
			coordinator.popToRoot()
		}
	}
	
	func showToast(message : String,
								 font: UIFont = UIFont(name: "omyu_pretty", size: 16)!) {
		let scenes = UIApplication.shared.connectedScenes
		let windowScene = scenes.first as? UIWindowScene
		if let window = windowScene?.windows.first {
			let toastLabel = UILabel()
			toastLabel.backgroundColor = .azWhite
			toastLabel.textColor = .azBlack
			toastLabel.font = font
			toastLabel.textAlignment = .center
			toastLabel.text = message
			toastLabel.alpha = 1.0
			toastLabel.layer.cornerRadius = 16
			toastLabel.clipsToBounds = true
			
			let maxWidth = window.frame.width
			let maxSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
			let expectedSize = toastLabel.sizeThatFits(maxSize)
			
			let minWidth: CGFloat = 150
			let labelWidth = max(expectedSize.width + 40, minWidth)
			
			let xPos = (window.frame.width - labelWidth) / 2
			let yPos = window.frame.height - 100
			toastLabel.frame = CGRect(x: xPos,
																y: yPos,
																width: labelWidth,
																height: expectedSize.height + 20)
			
			window.addSubview(toastLabel)
			
			UIView.animate(withDuration: 0.3, delay: 0,
										 options: .curveEaseIn, animations: {
				toastLabel.alpha = 1.0
			}, completion: { _ in
				UIView.animate(withDuration: 1.0, delay: 2.0,
											 options: .curveEaseInOut, animations: {
					toastLabel.alpha = 0.0
				}, completion: { _ in
					toastLabel.removeFromSuperview()
				})
			})
		}
	}
}
