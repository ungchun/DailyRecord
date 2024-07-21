//
//  LoadingIndicator.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/20/24.
//

import UIKit

class LoadingIndicator {
	static func showLoading() {
		DispatchQueue.main.async {
			/// 최상단에 있는 window 객체 획득
			let scenes = UIApplication.shared.connectedScenes
			let windowScene = scenes.first as? UIWindowScene
			if let window = windowScene?.windows.first {
				let loadingIndicatorView: UIActivityIndicatorView
				if let existedView = window.subviews.first(where: {
					$0 is UIActivityIndicatorView
				} ) as? UIActivityIndicatorView {
					loadingIndicatorView = existedView
				} else {
					loadingIndicatorView = UIActivityIndicatorView(style: .medium)
					/// 다른 UI가 눌리지 않도록 indicatorView의 크기를 full로 할당
					loadingIndicatorView.frame = window.frame
					loadingIndicatorView.color = .lightGray
					loadingIndicatorView.backgroundColor = .black.withAlphaComponent(0.5)
					window.addSubview(loadingIndicatorView)
				}
				loadingIndicatorView.startAnimating()
			}
		}
	}
	
	static func hideLoading() {
		DispatchQueue.main.async {
			let scenes = UIApplication.shared.connectedScenes
			let windowScene = scenes.first as? UIWindowScene
			if let window = windowScene?.windows.first {
				window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach {
					$0.removeFromSuperview()
				}
			}
		}
	}
}
