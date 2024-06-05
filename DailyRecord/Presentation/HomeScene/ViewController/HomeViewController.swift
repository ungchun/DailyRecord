//
//  HomeViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/2/24.
//

import UIKit

final class HomeViewController: UIViewController {
	
	var coordinator: HomeCoordinator?
	private let viewModel: HomeViewModel
	
	init(viewModel: HomeViewModel) {
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
