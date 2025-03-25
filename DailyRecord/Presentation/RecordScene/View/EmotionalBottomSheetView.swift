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
  
  private let moodContentView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.contentInsetAdjustmentBehavior = .never
    return scrollView
  }()
  
  private let dailyContentView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.isHidden = true
    return scrollView
  }()
  
  private let moodContentContainer: UIView = {
    let view = UIView()
    return view
  }()
  
  private let dailyContentContainer: UIView = {
    let view = UIView()
    return view
  }()
  
  private let coffeeImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "coffee")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let foodImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "food")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let mourningImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "mourning")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let sportsImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "sports")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let loveImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "love")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let cultureImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "culture")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let picnicImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "picnic")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let musicImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "music")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let moneyImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "money")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let hospitalImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "hospital")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let sleepImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "sleep")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let bombImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "bomb")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let studyingImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "studying")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let alcoholImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "alcohol")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let bookImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "book")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let showerImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "shower")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let cleaningImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "cleaning")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let shoppingImage: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "shopping")
    view.sizeToFit()
    view.isUserInteractionEnabled = true
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
    view.addSubview(moodContentView)
    view.addSubview(dailyContentView)
    
    moodContentView.addSubview(moodContentContainer)
    dailyContentView.addSubview(dailyContentContainer)
    
    [veryHappyEmotion, happyEmotion, lovelyEmotion,
     surprisedEmotion, neutralEmotion, embarrassedEmotion,
     hurtEmotion, sleepyEmotion, tiredEmotion,
     angryEmotion, verySadEmotion, sadEmotion].forEach {
      moodContentContainer.addSubview($0)
    }
    
    [shoppingImage, coffeeImage, foodImage,
     cultureImage, sleepImage, alcoholImage,
     hospitalImage, musicImage, loveImage,
     studyingImage, cleaningImage, moneyImage,
     showerImage, bookImage, bombImage].forEach {
      dailyContentContainer.addSubview($0)
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
    
    moodContentView.snp.makeConstraints { make in
      make.top.equalTo(tabBarView.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }
    
    moodContentContainer.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
    
    dailyContentView.snp.makeConstraints { make in
      make.top.equalTo(tabBarView.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }
    
    dailyContentContainer.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
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
    
    // 1 ROW
    shoppingImage.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(20)
      make.width.height.equalTo(70)
      make.centerX.equalTo(view.snp.leading).offset(view.bounds.width / 4.5)
    }
    
    coffeeImage.snp.makeConstraints { make in
      make.top.equalTo(shoppingImage)
      make.width.height.equalTo(70)
      make.centerX.equalToSuperview()
    }
    
    foodImage.snp.makeConstraints { make in
      make.top.equalTo(shoppingImage)
      make.width.height.equalTo(70)
      make.centerX.equalTo(view.snp.trailing).offset(-(view.bounds.width / 4.5))
    }
    
    // 2 ROW
    cultureImage.snp.makeConstraints { make in
      make.top.equalTo(shoppingImage.snp.bottom).offset(20)
      make.width.height.equalTo(70)
      make.centerX.equalTo(shoppingImage)
    }
    
    sleepImage.snp.makeConstraints { make in
      make.top.equalTo(cultureImage)
      make.width.height.equalTo(70)
      make.centerX.equalTo(coffeeImage)
    }
    
    alcoholImage.snp.makeConstraints { make in
      make.top.equalTo(cultureImage)
      make.width.height.equalTo(70)
      make.centerX.equalTo(foodImage)
    }
    
    // 3 ROW
    hospitalImage.snp.makeConstraints { make in
      make.top.equalTo(cultureImage.snp.bottom).offset(20)
      make.width.height.equalTo(70)
      make.centerX.equalTo(shoppingImage)
    }
    
    musicImage.snp.makeConstraints { make in
      make.top.equalTo(hospitalImage)
      make.width.height.equalTo(70)
      make.centerX.equalTo(coffeeImage)
    }
    
    loveImage.snp.makeConstraints { make in
      make.top.equalTo(hospitalImage)
      make.width.height.equalTo(70)
      make.centerX.equalTo(foodImage)
    }
    
    // 4 ROW
    studyingImage.snp.makeConstraints { make in
      make.top.equalTo(hospitalImage.snp.bottom).offset(20)
      make.width.height.equalTo(70)
      make.centerX.equalTo(shoppingImage)
    }
    
    cleaningImage.snp.makeConstraints { make in
      make.top.equalTo(studyingImage)
      make.width.height.equalTo(70)
      make.centerX.equalTo(coffeeImage)
    }
    
    moneyImage.snp.makeConstraints { make in
      make.top.equalTo(studyingImage)
      make.width.height.equalTo(70)
      make.centerX.equalTo(foodImage)
    }
    
    // 5 ROW
    showerImage.snp.makeConstraints { make in
      make.top.equalTo(studyingImage.snp.bottom).offset(20)
      make.width.height.equalTo(70)
      make.centerX.equalTo(shoppingImage)
    }
    
    bookImage.snp.makeConstraints { make in
      make.top.equalTo(showerImage)
      make.width.height.equalTo(70)
      make.centerX.equalTo(coffeeImage)
    }
    
    bombImage.snp.makeConstraints { make in
      make.top.equalTo(showerImage)
      make.width.height.equalTo(70)
      make.centerX.equalTo(foodImage)
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
    
    // Mood tab gestures
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
    
    // Daily tab gestures
    let shoppingTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    shoppingImage.addGestureRecognizer(shoppingTapGesture)
    shoppingImage.tag = 1
    
    let coffeeTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    coffeeImage.addGestureRecognizer(coffeeTapGesture)
    coffeeImage.tag = 2
    
    let foodTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    foodImage.addGestureRecognizer(foodTapGesture)
    foodImage.tag = 3
    
    let cultureTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    cultureImage.addGestureRecognizer(cultureTapGesture)
    cultureImage.tag = 4
    
    let sleepTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    sleepImage.addGestureRecognizer(sleepTapGesture)
    sleepImage.tag = 5
    
    let alcoholTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    alcoholImage.addGestureRecognizer(alcoholTapGesture)
    alcoholImage.tag = 6
    
    let hospitalTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    hospitalImage.addGestureRecognizer(hospitalTapGesture)
    hospitalImage.tag = 7
    
    let musicTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    musicImage.addGestureRecognizer(musicTapGesture)
    musicImage.tag = 8
    
    let loveTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    loveImage.addGestureRecognizer(loveTapGesture)
    loveImage.tag = 9
    
    let studyingTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    studyingImage.addGestureRecognizer(studyingTapGesture)
    studyingImage.tag = 10
    
    let cleaningTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    cleaningImage.addGestureRecognizer(cleaningTapGesture)
    cleaningImage.tag = 11
    
    let moneyTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    moneyImage.addGestureRecognizer(moneyTapGesture)
    moneyImage.tag = 12
    
    let showerTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    showerImage.addGestureRecognizer(showerTapGesture)
    showerImage.tag = 13
    
    let bookTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    bookImage.addGestureRecognizer(bookTapGesture)
    bookImage.tag = 14
    
    let bombTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(dailyImageTapped(_:))
    )
    bombImage.addGestureRecognizer(bombTapGesture)
    bombImage.tag = 15
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
  
  @objc func dailyImageTapped(_ sender: UITapGestureRecognizer) {
    guard let tappedView = sender.view else { return }
    
    switch tappedView.tag {
    case 1:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .shopping)
    case 2:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .coffee)
    case 3:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .food)
    case 4:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .culture)
    case 5:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .sleep)
    case 6:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .alcohol)
    case 7:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .hospital)
    case 8:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .music)
    case 9:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .love)
    case 10:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .studying)
    case 11:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .cleaning)
    case 12:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .money)
    case 13:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .shower)
    case 14:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .book)
    case 15:
      delegate?.emotionalImageTapTrigger(selectEmotionType: .bomb)
    default:
      break
    }
    dismiss(animated: true)
  }
}
