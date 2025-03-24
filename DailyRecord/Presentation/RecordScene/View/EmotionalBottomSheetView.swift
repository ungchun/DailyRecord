//
//  EmotionalBottomSheetView.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/20/24.
//

import UIKit

import SnapKit

protocol EmotionalBottomSheetViewViewDelegate: AnyObject {
  func emotionalImageTapTrigger(selectEmotionType: EmotionType)
}

final class EmotionalBottomSheetViewController: BaseViewController {
  
  // MARK: - Properties
  
  weak var delegate: EmotionalBottomSheetViewViewDelegate?
  
  private var currentTab: TabType = .mood {
    didSet {
      updateTabContent()
    }
  }
  
  private enum TabType {
    case mood
    case daily
  }
  
  // MARK: - Views
  
  private let topSpacerView: UIView = {
    let view = UIView()
    view.backgroundColor = .azBlack
    return view
  }()
  
  private let tabBarView: UIView = {
    let view = UIView()
    view.backgroundColor = .azBlack
    return view
  }()
  
  private let tabStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 24
    stackView.distribution = .fillEqually
    stackView.backgroundColor = .azBlack
    return stackView
  }()
  
  private let moodTabButton: UIButton = {
    let button = UIButton()
    button.setTitle("기분", for: .normal)
    button.titleLabel?.font = UIFont(name: "omyu_pretty", size: 20)
    button.setTitleColor(.azLightGray, for: .selected)
    button.setTitleColor(.azLightGray.withAlphaComponent(0.5), for: .normal)
    button.isSelected = true
    return button
  }()
  
  private let dailyTabButton: UIButton = {
    let button = UIButton()
    button.setTitle("일상", for: .normal)
    button.titleLabel?.font = UIFont(name: "omyu_pretty", size: 20)
    button.setTitleColor(.azLightGray, for: .selected)
    button.setTitleColor(.azLightGray.withAlphaComponent(0.5), for: .normal)
    return button
  }()
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    return scrollView
  }()
  
  private let contentView: UIView = {
    let view = UIView()
    return view
  }()
  
  private let moodContentView: UIView = {
    let view = UIView()
    return view
  }()
  
  private let dailyContentView: UIView = {
    let view = UIView()
    view.isHidden = true
    return view
  }()
  
  private let veryHappyEmotion: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "very_happy")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let happyEmotion: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "happy")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let neutralEmotion: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "neutral")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let verySadEmotion: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "very_sad")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let sadEmotion: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "sad")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let angryEmotion: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "angry")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let embarrassedEmotion: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "embarrassed")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let hurtEmotion: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "hurt")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let lovelyEmotion: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "lovely")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let sleepyEmotion: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "sleepy")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let surprisedEmotion: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "surprised")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let tiredEmotion: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "tired")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Functions
  
  override func addView() {
    view.addSubview(topSpacerView)
    view.addSubview(tabBarView)
    tabBarView.addSubview(tabStackView)
    tabStackView.addArrangedSubview(moodTabButton)
    tabStackView.addArrangedSubview(dailyTabButton)
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    contentView.addSubview(moodContentView)
    contentView.addSubview(dailyContentView)
    
    [veryHappyEmotion, happyEmotion, lovelyEmotion,
     surprisedEmotion, neutralEmotion, embarrassedEmotion,
     hurtEmotion, sleepyEmotion, tiredEmotion,
     angryEmotion, verySadEmotion, sadEmotion].forEach {
      moodContentView.addSubview($0)
    }
  }
  
  override func setLayout() {
    topSpacerView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(20)
    }
    
    tabBarView.snp.makeConstraints { make in
      make.top.equalTo(topSpacerView.snp.bottom)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(44)
    }
    
    tabStackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.height.equalToSuperview()
    }
    
    scrollView.snp.makeConstraints { make in
      make.top.equalTo(tabBarView.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalTo(scrollView.contentLayoutGuide)
      make.width.equalTo(scrollView.frameLayoutGuide)
    }
    
    moodContentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    dailyContentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    // 1 ROW
    veryHappyEmotion.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(20)
      make.width.height.equalTo(70)
      make.centerX.equalTo(view.snp.leading).offset(view.bounds.width / 4.5)
    }
    
    happyEmotion.snp.makeConstraints { make in
      make.top.equalTo(veryHappyEmotion)
      make.width.height.equalTo(70)
      make.centerX.equalToSuperview()
    }
    
    lovelyEmotion.snp.makeConstraints { make in
      make.top.equalTo(veryHappyEmotion)
      make.width.height.equalTo(70)
      make.centerX.equalTo(view.snp.trailing).offset(-(view.bounds.width / 4.5))
    }
    
    // 2 ROW
    surprisedEmotion.snp.makeConstraints { make in
      make.top.equalTo(veryHappyEmotion.snp.bottom).offset(20)
      make.width.height.equalTo(70)
      make.centerX.equalTo(veryHappyEmotion)
    }
    
    neutralEmotion.snp.makeConstraints { make in
      make.top.equalTo(surprisedEmotion)
      make.width.height.equalTo(70)
      make.centerX.equalTo(happyEmotion)
    }
    
    embarrassedEmotion.snp.makeConstraints { make in
      make.top.equalTo(surprisedEmotion)
      make.width.height.equalTo(70)
      make.centerX.equalTo(lovelyEmotion)
    }
    
    // 3 ROW
    hurtEmotion.snp.makeConstraints { make in
      make.top.equalTo(surprisedEmotion.snp.bottom).offset(20)
      make.width.height.equalTo(70)
      make.centerX.equalTo(veryHappyEmotion)
    }
    
    sleepyEmotion.snp.makeConstraints { make in
      make.top.equalTo(hurtEmotion)
      make.width.height.equalTo(70)
      make.centerX.equalTo(happyEmotion)
    }
    
    tiredEmotion.snp.makeConstraints { make in
      make.top.equalTo(hurtEmotion)
      make.width.height.equalTo(70)
      make.centerX.equalTo(lovelyEmotion)
    }
    
    // 4 ROW
    angryEmotion.snp.makeConstraints { make in
      make.top.equalTo(hurtEmotion.snp.bottom).offset(20)
      make.width.height.equalTo(70)
      make.centerX.equalTo(veryHappyEmotion)
    }
    
    verySadEmotion.snp.makeConstraints { make in
      make.top.equalTo(angryEmotion)
      make.width.height.equalTo(70)
      make.centerX.equalTo(happyEmotion)
    }
    
    sadEmotion.snp.makeConstraints { make in
      make.top.equalTo(angryEmotion)
      make.width.height.equalTo(70)
      make.centerX.equalTo(lovelyEmotion)
      make.bottom.equalToSuperview().offset(-20)
    }
  }
  
  override func setupView() {
    view.backgroundColor = .azBlack
    
    if let sheet = sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.preferredCornerRadius = 24
    }
    
    addTapGestures()
  }
}

private extension EmotionalBottomSheetViewController {
  @objc func moodTabTapped() {
    currentTab = .mood
    updateTabBarUI()
  }
  
  @objc func dailyTabTapped() {
    currentTab = .daily
    updateTabBarUI()
  }
  
  func updateTabBarUI() {
    moodTabButton.isSelected = currentTab == .mood
    dailyTabButton.isSelected = currentTab == .daily
  }
  
  func updateTabContent() {
    switch currentTab {
    case .mood:
      moodContentView.isHidden = false
      dailyContentView.isHidden = true
    case .daily:
      moodContentView.isHidden = true
      dailyContentView.isHidden = false
    }
  }
  
  func addTapGestures() {
    moodTabButton.addTarget(self, action: #selector(moodTabTapped), for: .touchUpInside)
    dailyTabButton.addTarget(self, action: #selector(dailyTabTapped), for: .touchUpInside)
    
    let veryHappyTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(imageTapped(_:))
    )
    veryHappyEmotion.addGestureRecognizer(veryHappyTapGesture)
    veryHappyEmotion.tag = 1
    
    let happyTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(imageTapped(_:))
    )
    happyEmotion.addGestureRecognizer(happyTapGesture)
    happyEmotion.tag = 2
    
    let neutralTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(imageTapped(_:))
    )
    neutralEmotion.addGestureRecognizer(neutralTapGesture)
    neutralEmotion.tag = 3
    
    let verySadTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(imageTapped(_:))
    )
    verySadEmotion.addGestureRecognizer(verySadTapGesture)
    verySadEmotion.tag = 4
    
    let sadTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(imageTapped(_:))
    )
    sadEmotion.addGestureRecognizer(sadTapGesture)
    sadEmotion.tag = 5
    
    let angryTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(imageTapped(_:))
    )
    angryEmotion.addGestureRecognizer(angryTapGesture)
    angryEmotion.tag = 6
    
    let embarrassedTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(imageTapped(_:))
    )
    embarrassedEmotion.addGestureRecognizer(embarrassedTapGesture)
    embarrassedEmotion.tag = 7
    
    let hurtTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(imageTapped(_:))
    )
    hurtEmotion.addGestureRecognizer(hurtTapGesture)
    hurtEmotion.tag = 8
    
    let lovelyTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(imageTapped(_:))
    )
    lovelyEmotion.addGestureRecognizer(lovelyTapGesture)
    lovelyEmotion.tag = 9
    
    let sleepyTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(imageTapped(_:))
    )
    sleepyEmotion.addGestureRecognizer(sleepyTapGesture)
    sleepyEmotion.tag = 10
    
    let surprisedTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(imageTapped(_:))
    )
    surprisedEmotion.addGestureRecognizer(surprisedTapGesture)
    surprisedEmotion.tag = 11
    
    let tiredTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(imageTapped(_:))
    )
    tiredEmotion.addGestureRecognizer(tiredTapGesture)
    tiredEmotion.tag = 12
  }
  
  @objc func imageTapped(_ sender: UITapGestureRecognizer) {
    guard let tappedView = sender.view else { return }
    
    switch tappedView.tag {
    case 1:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .very_happy)
    case 2:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .happy)
    case 3:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .neutral)
    case 4:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .very_sad)
    case 5:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .sad)
    case 6:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .angry)
    case 7:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .embarrassed)
    case 8:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .hurt)
    case 9:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .lovely)
    case 10:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .sleepy)
    case 11:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .surprised)
    case 12:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .tired)
    default:
      break
    }
    dismiss(animated: true)
  }
}
