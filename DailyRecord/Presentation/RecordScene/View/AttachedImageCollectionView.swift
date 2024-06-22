//
//  AttachedImageCollectionView.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/20/24.
//

import UIKit
import SnapKit

final class AttachedImageCollectionView: BaseView {
	
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
		//		collectionView.isHidden = true
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.reuseIdentifier)
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
			make.height.equalTo(0)
		}
	}
}

extension AttachedImageCollectionView {
	func showCollectionView() {
		//		collectionView.isHidden = false
		//		collectionView.snp.updateConstraints { make in
		//			make.height.equalTo(100)
		//		}
	}
	
	@objc private func deleteButtonTapped(_ sender: UIButton) {
		if let cell = sender.superview as? CustomCollectionViewCell,
			 let indexPath = self.collectionView.indexPath(for: cell) {
			// 여기에 삭제 동작을 구현
			print("Delete button tapped at indexPath: \(indexPath)")
			// 예시: 데이터 소스에서 해당 항목을 삭제하고 컬렉션 뷰를 업데이트
			// dataSource.remove(at: indexPath.row)
			// collectionView.deleteItems(at: [indexPath])
		}
	}
}

extension AttachedImageCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView,
											numberOfItemsInSection section: Int) -> Int {
		return 5 // 5개의 셀
	}
	
	func collectionView(_ collectionView: UICollectionView,
											cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: CustomCollectionViewCell.reuseIdentifier,
			for: indexPath
		) as! CustomCollectionViewCell
		// 셀에 필요한 데이터 설정
		cell.backgroundColor = .blue // 임시 배경 색상
		// cell.imageView.image = UIImage(named: "your_image_name") // 이미지 설정 예시
		cell.deleteButton.addTarget(self,
																action: #selector(deleteButtonTapped(_:)),
																for: .touchUpInside)
		return cell
	}
}

final class CustomCollectionViewCell: UICollectionViewCell {
	
	// MARK: - Properties
	
	static var reuseIdentifier: String {
		return String(describing: self)
	}
	
	// MARK: - Views
	
	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		return imageView
	}()
	
	let deleteButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
		button.tintColor = .red
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

private extension CustomCollectionViewCell {
	
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
