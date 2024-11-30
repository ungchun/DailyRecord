//
//  DrawerViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 11/30/24.
//

import UIKit

import SnapKit

final class DrawerViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: DrawerCoordinator?
  
  private let viewModel: DrawerViewModel
  
  // MARK: - Init
  
  init(viewModel: DrawerViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .yellow
  }
}
