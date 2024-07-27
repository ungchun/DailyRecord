//
//  AttachedImageCollectionView.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/20/24.
//

import UIKit
import SnapKit

protocol AttachedImageCollectionViewDelegate: AnyObject {
	func collectionViewZeroHeightTrigger()
}

final class AttachedImageCollectionView: BaseView {
	
	// MARK: - Properties
	
	weak var delegate: AttachedImageCollectionViewDelegate?
	
	private(set) var images: [UIImage] = []
	
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
			AttachedImageCollectionViewCell.self,
			forCellWithReuseIdentifier: AttachedImageCollectionViewCell.reuseIdentifier
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

extension AttachedImageCollectionView {
	func setImages(_ images: [UIImage]) {
		DispatchQueue.main.async { [weak self] in
			self?.images = images
			self?.collectionView.reloadData()
		}
	}
	
	@objc private func deleteButtonTapped(_ sender: UIButton) {
		if let cell = sender.superview as? AttachedImageCollectionViewCell,
			 let indexPath = self.collectionView.indexPath(for: cell) {
			images.remove(at: indexPath.row)
			collectionView.deleteItems(at: [indexPath])
			
			if images.isEmpty {
				delegate?.collectionViewZeroHeightTrigger()
			}
		}
	}
}

extension AttachedImageCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView,
											numberOfItemsInSection section: Int) -> Int {
		return images.count
	}
	
	func collectionView(_ collectionView: UICollectionView,
											cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: AttachedImageCollectionViewCell.reuseIdentifier,
			for: indexPath
		) as! AttachedImageCollectionViewCell
		cell.imageView.image = images[indexPath.item]
		cell.deleteButton.addTarget(self,
																action: #selector(deleteButtonTapped(_:)),
																for: .touchUpInside)
		return cell
	}
}

final class AttachedImageCollectionViewCell: UICollectionViewCell {
	
	// MARK: - Properties
	
	static var reuseIdentifier: String {
		return String(describing: self)
	}
	
	// MARK: - Views
	
	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.layer.cornerRadius = 12
		imageView.clipsToBounds = true
		return imageView
	}()
	
	let deleteButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
		button.tintColor = .azDarkGray
		return button
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

private extension AttachedImageCollectionViewCell {
	
	// MARK: - Functions
	
	func addView() {
		addSubview(imageView)
		addSubview(deleteButton)
	}
	
	func setupView() {
		imageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		deleteButton.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(5)
			make.right.equalToSuperview().offset(-5)
			make.width.height.equalTo(20)
		}
	}
}
