//
//  RecordFooterView.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/20/24.
//

import UIKit

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
		view.tintColor = .azLightGray
		return view
	}()
	
	let saveIcon: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(systemName: "checkmark")
		view.contentMode = .scaleAspectFit
		view.isUserInteractionEnabled = true
		view.tintColor = .azLightGray
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
			make.height.equalTo(1)
		}
		
		galleryIcon.snp.makeConstraints { make in
			make.top.equalTo(divider.snp.bottom).offset(16)
			make.leading.equalToSuperview().offset(24)
			make.width.height.equalTo(20)
		}
		
		saveIcon.snp.makeConstraints { make in
			make.top.equalTo(divider.snp.bottom).offset(16)
			make.trailing.equalToSuperview().offset(-24)
			make.width.height.equalTo(20)
		}
	}
	
	override func setupView() {
		
	}
}
