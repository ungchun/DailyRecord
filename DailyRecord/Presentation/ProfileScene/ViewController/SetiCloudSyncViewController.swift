//
//  SetiCloudSyncViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 9/28/24.
//

import UIKit
import SnapKit

final class SetiCloudSyncViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: ProfileCoordinator?
  
  // MARK: - Views
  
  private let infoBoxView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.azBoxGray
    view.layer.cornerRadius = 12
    return view
  }()
  
  private let infoTitleLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.Icloud.description
    label.font = UIFont(name: "omyu_pretty", size: 16)
    label.textColor = .azGray800
    label.numberOfLines = 0
    label.textAlignment = .left
    return label
  }()
  
  private let infoDescriptionLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.Icloud.storageWarning
    label.font = UIFont(name: "omyu_pretty", size: 15)
    label.textColor = .azGray500
    label.numberOfLines = 0
    label.textAlignment = .left
    return label
  }()
  
  private lazy var infoLabelStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [infoTitleLabel, infoDescriptionLabel])
    stackView.axis = .vertical
    stackView.spacing = 12
    return stackView
  }()
  
  private let syncMethodTitleLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.Icloud.syncMethod
    label.font = UIFont(name: "omyu_pretty", size: 18)
    label.textColor = .azGray900
    return label
  }()
  
  private let syncMethodDescriptionLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.Icloud.syncInstruction
    label.font = UIFont(name: "omyu_pretty", size: 18)
    label.textColor = .azGray900
    label.numberOfLines = 0
    return label
  }()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Functions
  
  override func addView() {
    view.addSubview(infoBoxView)
    infoBoxView.addSubview(infoLabelStackView)
    
    [syncMethodTitleLabel, syncMethodDescriptionLabel].forEach {
      view.addSubview($0)
    }
  }
  
  override func setLayout() {
    infoBoxView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    infoLabelStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.trailing.equalToSuperview().offset(-16)
      make.top.equalToSuperview().offset(16)
      make.bottom.equalToSuperview().offset(-16)
    }
    
    syncMethodTitleLabel.snp.makeConstraints { make in
      make.top.equalTo(infoBoxView.snp.bottom).offset(24)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    syncMethodDescriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(syncMethodTitleLabel.snp.bottom).offset(10)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
  }
  
  override func setupView() {
    view.backgroundColor = .azGray50
  }
}
