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
								 font: UIFont = UIFont(name: "omyu_pretty", size: 12)!) {
		let toastLabel = UILabel(frame: CGRect(
			x: self.view.frame.size.width/2 - 75,
			y: self.view.frame.size.height-100, width: 150, height: 35))
		toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
		toastLabel.textColor = UIColor.white
		toastLabel.font = font
		toastLabel.textAlignment = .center
		toastLabel.text = message
		toastLabel.alpha = 1.0
		toastLabel.layer.cornerRadius = 16
		toastLabel.clipsToBounds  =  true
		self.view.addSubview(toastLabel)
		UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
			toastLabel.alpha = 0.0
		}, completion: {(isCompleted) in
			toastLabel.removeFromSuperview()
		})
	}
}
