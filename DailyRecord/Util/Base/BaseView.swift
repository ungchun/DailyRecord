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
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFontChange),
      name: .fontDidChange,
      object: nil
    )
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc private func handleFontChange() {
    subviews.forEach { $0.removeFromSuperview() }
    addView()
    setLayout()
    setupView()
    setNeedsLayout()
    layoutIfNeeded()
  }
  
  func addView() { }
  
  func setLayout() { }
  
  func setupView() { }
}
