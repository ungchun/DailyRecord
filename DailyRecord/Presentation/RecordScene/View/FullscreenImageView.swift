//
//  FullscreenImageView.swift
//  DailyRecord
//
//  Created by Kim SungHun on 8/24/24.
//

import UIKit

final class FullscreenImageViewController: BaseViewController {
	
	// MARK: - Properties
	
	private var initialIndex: Int
	
	// MARK: - Views
	
	private var images: [UIImage]
	private var imageView: UIImageView!
	
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView(frame: view.bounds)
		scrollView.isPagingEnabled = true
		scrollView.delegate = self
		scrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(images.count),
																		height: view.bounds.height)
		scrollView.showsHorizontalScrollIndicator = false
		return scrollView
	}()
	
	private var indexLabelContainer: UIView = {
		let containerView = UIView()
		containerView.backgroundColor = .azBlack
		containerView.layer.cornerRadius = 16
		containerView.translatesAutoresizingMaskIntoConstraints = false
		return containerView
	}()
	
	private var indexLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont(name: "omyu_pretty", size: 16)
		label.textColor = .azWhite
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// MARK: - Init
	
	init(images: [UIImage], initialIndex: Int) {
		self.images = images
		self.initialIndex = initialIndex
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func addView() {
		[scrollView, indexLabelContainer].forEach {
			view.addSubview($0)
		}
		
		indexLabelContainer.addSubview(indexLabel)
		
		for (index, image) in images.enumerated() {
			let imageView = createImageView(for: image, at: index)
			scrollView.addSubview(imageView)
		}
	}
	
	override func setLayout() {
		NSLayoutConstraint.activate([
			indexLabel.leadingAnchor.constraint(equalTo: indexLabelContainer.leadingAnchor,
																					constant: 12),
			indexLabel.trailingAnchor.constraint(equalTo: indexLabelContainer.trailingAnchor,
																					 constant: -12),
			indexLabel.topAnchor.constraint(equalTo: indexLabelContainer.topAnchor,
																			constant: 8),
			indexLabel.bottomAnchor.constraint(equalTo: indexLabelContainer.bottomAnchor,
																				 constant: -8)
		])
		
		NSLayoutConstraint.activate([
			indexLabelContainer.bottomAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20
			),
			indexLabelContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])
	}
	
	override func setupView() {
		view.backgroundColor = .azBlack
		
		let initialOffset = CGPoint(x: view.bounds.width * CGFloat(initialIndex), y: 0)
		scrollView.setContentOffset(initialOffset, animated: false)
		
		let panGesture = UIPanGestureRecognizer(target: self,
																						action: #selector(handlePanGesture(_:)))
		view.addGestureRecognizer(panGesture)
		
		updateIndexLabel()
	}
	
	// MARK: - Functions
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let startY = touch.location(in: self.view).y
			if startY < view.bounds.height / 4 {
				self.dismiss(animated: true, completion: nil)
			}
		}
	}
}

extension FullscreenImageViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return scrollView.subviews.first as? UIImageView
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateIndexLabel()
	}
}

extension FullscreenImageViewController {
	private func updateIndexLabel() {
		let currentIndex = Int(scrollView.contentOffset.x / view.bounds.width) + 1
		indexLabel.text = "\(currentIndex) / \(images.count)"
	}
	
	private func createImageView(for image: UIImage, at index: Int) -> UIScrollView {
		let imageScrollView = UIScrollView(frame: CGRect(x: CGFloat(index) * view.bounds.width,
																										 y: 0,
																										 width: view.bounds.width,
																										 height: view.bounds.height))
		imageScrollView.delegate = self
		imageScrollView.minimumZoomScale = 1.0
		imageScrollView.maximumZoomScale = 3.0
		imageScrollView.showsVerticalScrollIndicator = false
		imageScrollView.showsHorizontalScrollIndicator = false
		imageScrollView.backgroundColor = .clear
		
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFit
		imageView.frame = imageScrollView.bounds
		imageScrollView.addSubview(imageView)
		
		let doubleTapGesture = UITapGestureRecognizer(target: self,
																									action: #selector(handleDoubleTap(_:)))
		doubleTapGesture.numberOfTapsRequired = 2
		imageScrollView.addGestureRecognizer(doubleTapGesture)
		
		return imageScrollView
	}
	
	@objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
		guard let scrollView = gesture.view as? UIScrollView else { return }
		
		if scrollView.zoomScale == scrollView.minimumZoomScale {
			scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
		} else {
			scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
		}
	}
	
	@objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: view)
		
		if translation.y > 100 { // 아래로 스크롤한 거리가 100포인트 이상이면 dismiss
			dismiss(animated: true, completion: nil)
		}
	}
}
