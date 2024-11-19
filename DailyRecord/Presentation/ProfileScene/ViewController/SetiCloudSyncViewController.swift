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
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.text = "다온은 iCloud에 자동으로 백업/저장 할 수 있어요"
    label.numberOfLines = 0
    label.font = UIFont(name: "omyu_pretty", size: 18)
    label.textColor = .azWhite
    label.textAlignment = .center
    return label
  }()
  
  private let divider: UIView = {
    let view = UIView()
    view.backgroundColor = .azDarkGray
    return view
  }()
  
  private let syncMethodTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "동기화 방법"
    label.font = UIFont(name: "omyu_pretty", size: 16)
    label.textColor = .azWhite
    return label
  }()
  
  private let syncMethodDescriptionLabel: UILabel = {
    let label = UILabel()
    label.text = "설정 > Apple 계정 > iCloud > 다온 토글 on"
    label.font = UIFont(name: "omyu_pretty", size: 16)
    label.textColor = .azWhite
    label.numberOfLines = 0
    return label
  }()
  
  private let cautionLabel: UILabel = {
    let label = UILabel()
    label.text = "iCloud 용량이 가득 찬 경우 동기화가 되지 않으니 주의해주세요"
    label.numberOfLines = 0
    label.font = UIFont(name: "omyu_pretty", size: 14)
    label.textColor = .azWhite
    return label
  }()
    
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Functions
  
  override func addView() {
    [descriptionLabel, divider,
     syncMethodTitleLabel, syncMethodDescriptionLabel, cautionLabel].forEach {
      view.addSubview($0)
    }
  }
  
  override func setLayout() {
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
      make.leading.equalToSuperview().offset(16)
      make.trailing.equalToSuperview().offset(-16)
    }
    
    divider.snp.makeConstraints { make in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
      make.height.equalTo(1)
      make.leading.equalToSuperview().offset(32)
      make.trailing.equalToSuperview().offset(-32)
    }
    
    syncMethodTitleLabel.snp.makeConstraints { make in
      make.top.equalTo(divider.snp.bottom).offset(20)
      make.leading.equalToSuperview().offset(16)
      make.trailing.equalToSuperview().offset(-16)
    }
    
    syncMethodDescriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(syncMethodTitleLabel.snp.bottom).offset(10)
      make.leading.equalToSuperview().offset(16)
      make.trailing.equalToSuperview().offset(-16)
    }
    
    cautionLabel.snp.makeConstraints { make in
      make.top.equalTo(syncMethodDescriptionLabel.snp.bottom).offset(20)
      make.leading.equalToSuperview().offset(16)
      make.trailing.equalToSuperview().offset(-16)
    }
  }
  
  override func setupView() {
    view.backgroundColor = .azBlack
  }
}
