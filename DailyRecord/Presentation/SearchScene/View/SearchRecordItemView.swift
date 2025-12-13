//
//  SearchRecordItemView.swift
//  DailyRecord
//
//  Created by Kim SungHun on 3/17/25.
//

import UIKit

import SnapKit

protocol SearchRecordItemViewDelegate: AnyObject {
  func didTapRecord(_ record: RecordEntity)
}

final class SearchRecordItemView: BaseView {
  
  // MARK: - Properties
  
  private let record: RecordEntity
  
  weak var delegate: SearchRecordItemViewDelegate?
  
  // MARK: - Views
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .azBoxGray
    view.layer.cornerRadius = 16
    view.clipsToBounds = true
    return view
  }()
  
  private lazy var mainStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 12
    stackView.alignment = .center
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    return stackView
  }()
  
  private lazy var emotionImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let dateLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "omyu_pretty", size: 16)
    label.textColor = .azGray700
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var imageStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8
    stackView.distribution = .fillEqually
    return stackView
  }()
  
  private let contentLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "omyu_pretty", size: 16)
    label.textColor = .azGray900
    label.numberOfLines = 3
    return label
  }()
  
  // MARK: - Init
  
  init(
    record: RecordEntity
  ) {
    self.record = record
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Functions
  
  override func addView() {
    addSubview(containerView)
    containerView.addSubview(mainStackView)
  }
  
  override func setLayout() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    mainStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    if record.emotionType != "none" {
      mainStackView.addArrangedSubview(emotionImageView)
      emotionImageView.snp.makeConstraints { make in
        make.size.equalTo(40)
      }
    }
    
    mainStackView.addArrangedSubview(dateLabel)
    
    if !record.imageList.isEmpty {
      mainStackView.addArrangedSubview(imageStackView)
      imageStackView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(16)
        make.height.equalTo(imageStackView.snp.width).multipliedBy(0.33)
      }
    }
    
    if !record.content.isEmpty {
      mainStackView.addArrangedSubview(contentLabel)
      contentLabel.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(16)
      }
    }
  }
  
  override func setupView() {
    setContentHuggingPriority(.required, for: .vertical)
    setContentCompressionResistancePriority(.required, for: .vertical)
    
    configureWithRecord()
    setupGesture()
  }
}

private extension SearchRecordItemView {
  func configureWithRecord() {
    if !record.emotionType.isEmpty {
      emotionImageView.image = UIImage(named: record.emotionType)
    }
    
    let date = Date(
      timeIntervalSince1970: TimeInterval(record.calendarDate) / 1000
    )
    let datePart = DateFormatter.formattedString(date, format: "yyyy.MM.dd")
    let dayOfWeekPart = DateFormatter.formattedString(date, format: "EEEE")
    DispatchQueue.main.async { [weak self] in
      self?.dateLabel.text = "\(datePart)\n\(dayOfWeekPart)"
    }
    
    record.imageList.forEach { imageData in
      let imageView = UIImageView()
      imageView.contentMode = .scaleAspectFill
      imageView.clipsToBounds = true
      imageView.layer.cornerRadius = 8
      
      if let image = UIImage(data: imageData) {
        imageView.image = image
      }
      
      imageStackView.addArrangedSubview(imageView)
    }
    
    contentLabel.text = record.content
  }
  
  func setupGesture() {
    let tapGesture = UITapGestureRecognizer(
      target: self, action: #selector(handleTap)
    )
    containerView.addGestureRecognizer(tapGesture)
    containerView.isUserInteractionEnabled = true
  }
  
  @objc func handleTap() {
    delegate?.didTapRecord(record)
  }
}
