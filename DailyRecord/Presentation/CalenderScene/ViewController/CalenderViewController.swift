//
//  CalenderViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import UIKit

final class CalenderViewController: UIViewController {
	
	var coordinator: CalenderCoordinator?
	private let viewModel: CalenderViewModel
	
	init(viewModel: CalenderViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .yellow
	}
}
