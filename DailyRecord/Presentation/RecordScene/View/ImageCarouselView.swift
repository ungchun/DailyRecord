//
//  ImageCarouselView.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/27/24.
//

import UIKit

import SnapKit

final class ImageCarouselView: BaseView {
	
	// MARK: - Properties
	
	private(set) var imageURLs: [String] = []
	
	// MARK: - Views
	
	private let layout: UICollectionViewFlowLayout = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.itemSize = CGSize(width: 100, height: 100)
		return layout
	}()
	
	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .clear
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(
			ImageCarouselViewCell.self,
			forCellWithReuseIdentifier: ImageCarouselViewCell.reuseIdentifier
		)
		return collectionView
	}()
	
	// MARK: - Life Cycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	// MARK: - Functions
	
	override func addView() {
		addSubview(collectionView)
	}
	
	override func setupView() {
		collectionView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
}
extension ImageCarouselView {
	func setImages(_ imageURLs: [String]) {
		DispatchQueue.main.async { [weak self] in
			self?.imageURLs = imageURLs
			self?.collectionView.reloadData()
		}
	}
}

extension ImageCarouselView: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView,
											numberOfItemsInSection section: Int) -> Int {
		return imageURLs.count
	}
	
	func collectionView(_ collectionView: UICollectionView,
											cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: ImageCarouselViewCell.reuseIdentifier,
			for: indexPath
		) as! ImageCarouselViewCell
		
		if let url = URL(string: imageURLs[indexPath.item]) {
			cell.loadImage(from: url)
		}
		return cell
	}
}

final class ImageCarouselViewCell: UICollectionViewCell {
	
	// MARK: - Properties
	
	static var reuseIdentifier: String {
		return String(describing: self)
	}
	
	// MARK: - Views
	
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 12
		imageView.layer.masksToBounds = true
		return imageView
	}()
	
	private let loadingIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .medium)
		indicator.hidesWhenStopped = true
		return indicator
	}()
	
	
	// MARK: - Life Cycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		addView()
		setupView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
}

private extension ImageCarouselViewCell {
	
	// MARK: - Functions
	
	func addView() {
		addSubview(imageView)
		addSubview(loadingIndicator)
	}
	
	func setupView() {
		imageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		loadingIndicator.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview()
		}
	}
	
	func loadImage(from url: URL) {
		loadingIndicator.startAnimating()
		URLSession.shared.dataTask(with: url) { data, response, error in
			guard let data = data, error == nil, let image = UIImage(data: data) else {
				DispatchQueue.main.async {
					self.loadingIndicator.stopAnimating()
				}
				return
			}
			DispatchQueue.main.async {
				self.loadingIndicator.stopAnimating()
				self.imageView.image = image
			}
		}.resume()
	}
}
