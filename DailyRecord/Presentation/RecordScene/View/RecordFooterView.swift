//
//  RecordFooterView.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/20/24.
//

import UIKit

import SnapKit

final class RecordFooterView: BaseView {
	
	// MARK: - Views
	
	private let divider: UIView = {
		let view = UIView()
		view.backgroundColor = .azDarkGray
		return view
	}()
	
	let galleryIcon: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(systemName: "photo")
		view.contentMode = .scaleAspectFit
		view.isUserInteractionEnabled = true
		view.tintColor = .azWhite
		return view
	}()
	
	let saveIcon: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(systemName: "checkmark")
		view.contentMode = .scaleAspectFit
		view.isUserInteractionEnabled = true
		view.tintColor = .azWhite
		return view
	}()
	
	// MARK: - Functions
	
	override func addView() {
		[divider, galleryIcon, saveIcon].forEach {
			addSubview($0)
		}
	}
	
	override func setLayout() {
		divider.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.left.right.equalToSuperview()
			make.height.equalTo(2)
		}
		
		galleryIcon.snp.makeConstraints { make in
			make.top.equalTo(divider.snp.bottom).offset(10)
			make.leading.equalToSuperview().offset(24)
			make.width.height.equalTo(20)
			make.bottom.equalToSuperview().inset(10)
		}
		
		saveIcon.snp.makeConstraints { make in
			make.top.equalTo(divider.snp.bottom).offset(10)
			make.trailing.equalToSuperview().offset(-24)
			make.width.height.equalTo(20)
			make.bottom.equalToSuperview().inset(10)
		}
		
		self.snp.makeConstraints { make in
			make.height.equalTo(20 + 10 + 10 + 2)
		}
	}
	
	override func setupView() {
		
	}
}
