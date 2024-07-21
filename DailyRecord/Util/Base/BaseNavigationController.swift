//
//  BaseNavigationController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/21/24.
//

import UIKit

final class BaseNavigationController: UINavigationController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setNavigationBarAppearance()
	}
	
	func setNavigationBarAppearance() {
		view.backgroundColor = .azBlack
		
		let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
		backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
		
		let backButtonImage = UIImage(systemName: "chevron.left")?.withAlignmentRectInsets(
			UIEdgeInsets(top: 0.0, left: -12.0, bottom: -5.0, right: 0.0)
		)
		
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = .azBlack
		appearance.shadowColor = UIColor.clear
		appearance.backButtonAppearance = backButtonAppearance
		appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
		
		navigationBar.standardAppearance = appearance
		navigationBar.scrollEdgeAppearance = appearance
		navigationBar.tintColor = .azLightGray
	}
}
