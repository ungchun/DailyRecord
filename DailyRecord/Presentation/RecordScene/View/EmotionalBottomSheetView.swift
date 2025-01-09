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
  
  // MARK: - Views
  
  private let topSpacerView: UIView = {
    let view = UIView()
    view.backgroundColor = .azBlack
    return view
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
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    [veryHappyEmotion, happyEmotion, lovelyEmotion,
     surprisedEmotion, neutralEmotion, embarrassedEmotion,
     hurtEmotion, sleepyEmotion, tiredEmotion,
     angryEmotion, verySadEmotion, sadEmotion].forEach {
      contentView.addSubview($0)
    }
  }
  
  override func setLayout() {
    topSpacerView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(20)
    }
    
    scrollView.snp.makeConstraints { make in
      make.top.equalTo(topSpacerView.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalTo(scrollView.contentLayoutGuide)
      make.width.equalTo(scrollView.frameLayoutGuide)
    }
    
    // 1 ROW
    veryHappyEmotion.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(40)
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
  func addTapGestures() {
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
