//
//  BaseViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/9/24.
//

import UIKit

class BaseViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addView()
    setLayout()
    setupView()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFontChange),
      name: .fontDidChange,
      object: nil
    )
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc private func handleFontChange() {
    view.subviews.forEach { $0.removeFromSuperview() }
    addView()
    setLayout()
    setupView()
    updateFontsAfterChange()
    view.setNeedsLayout()
    view.layoutIfNeeded()
  }
  
  func addView() { }
  
  func setLayout() { }
  
  func setupView() { }
  
  func updateFontsAfterChange() { }
}
