//
//  BaseView.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/20/24.
//

import UIKit

class BaseView: UIView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addView()
		setLayout()
		setupView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func addView() { }
	
	func setLayout() { }
	
	func setupView() { }
}
