//
//  FontChangeViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 1/15/25.
//

import UIKit

import SnapKit

struct FontItem {
  let displayName: String
  let fileName: String
  var isSelected: Bool = false
}

final class FontChangeViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: ProfileCoordinator?
  
  private var fontItems: [FontItem] = []
  
  private var selectedIndex: Int = 0
  
  // MARK: - Views
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = true
    scrollView.delaysContentTouches = false
    return scrollView
  }()
  
  private let contentView: UIView = {
    let view = UIView()
    return view
  }()
  
  private let fontStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    return stackView
  }()
  
  private let infoBoxView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.azBoxGray
    view.layer.cornerRadius = 12
    return view
  }()
  
  private let infoTitleLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.fontCustomizationDescription
    label.font = UIFont.appFont(size: 16)
    label.textColor = .azGray800
    label.numberOfLines = 0
    label.textAlignment = .left
    return label
  }()
  
  private let infoDescriptionLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.newFontsComing
    label.font = UIFont.appFont(size: 15)
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
  
  private let smallALabel: UILabel = {
    let label = UILabel()
    label.text = "A"
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .azGray900
    return label
  }()
  
  private lazy var fontSizeSlider: UISlider = {
    let slider = UISlider()
    slider.minimumValue = 1
    slider.maximumValue = 7
    slider.value = Float(UserDefaults.standard.integer(forKey: "fontSizeLevel") == 0
                         ? 4 : UserDefaults.standard.integer(forKey: "fontSizeLevel"))
    slider.minimumTrackTintColor = .azGray900
    slider.maximumTrackTintColor = .azGray300
    slider.addTarget(self, action: #selector(fontSizeChanged(_:)), for: .valueChanged)
    return slider
  }()
  
  private let largeALabel: UILabel = {
    let label = UILabel()
    label.text = "A"
    label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    label.textColor = .azGray900
    return label
  }()
  
  // MARK: - Init
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    Amp.track(event: "screen_view", properties: ["screen_name": "font_change"])

    NotificationCenter.default.removeObserver(
      self,
      name: .fontDidChange,
      object: nil
    )

    setupFontItems()
    loadSelectedFont()
    setupFontList()
  }
  
  // MARK: - Functions
  
  override func addView() {
    view.addSubview(infoBoxView)
    infoBoxView.addSubview(infoLabelStackView)
    view.addSubview(smallALabel)
    view.addSubview(fontSizeSlider)
    view.addSubview(largeALabel)
    view.addSubview(scrollView)
    
    scrollView.addSubview(contentView)
    contentView.addSubview(fontStackView)
  }
  
  override func setLayout() {
    infoBoxView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    infoLabelStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.trailing.equalToSuperview().offset(-16)
      make.top.equalToSuperview().offset(16)
      make.bottom.equalToSuperview().offset(-16)
    }
    
    smallALabel.snp.makeConstraints { make in
      make.top.equalTo(infoBoxView.snp.bottom).offset(30)
      make.leading.equalToSuperview().offset(20)
    }
    
    fontSizeSlider.snp.makeConstraints { make in
      make.centerY.equalTo(smallALabel)
      make.leading.equalTo(smallALabel.snp.trailing).offset(16)
      make.trailing.equalTo(largeALabel.snp.leading).offset(-16)
      make.height.equalTo(31)
    }
    
    largeALabel.snp.makeConstraints { make in
      make.centerY.equalTo(smallALabel)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    scrollView.snp.makeConstraints { make in
      make.top.equalTo(fontSizeSlider.snp.bottom).offset(24)
      make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
    
    fontStackView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      make.bottom.equalToSuperview().offset(-16)
    }
  }
  
  override func setupView() {
    view.backgroundColor = .azGray50
    
    navigationController?.navigationBar.tintColor = .azGray900
  }
}

private extension FontChangeViewController {
  func setupFontItems() {
    let isKorean = Locale.current.language.languageCode?.identifier == "ko"

    fontItems = [
      FontItem(displayName: L10n.fontOmyuDayaeppum, fileName: "omyu_pretty"),
      FontItem(displayName: L10n.fontOngleapParkDahyun, fileName: "Ownglyph_PDH-Rg"),
      FontItem(displayName: L10n.fontOngleapKonkon, fileName: "Ownglyph_corncorn-Rg"),
      FontItem(displayName: L10n.fontPretendard, fileName: "PretendardVariable-Regular")
    ]

    // 한국어인 경우에만 나눔펜 추가
    if isKorean {
      fontItems.append(FontItem(displayName: L10n.fontNanumPen, fileName: "NanumPen"))
    }
  }
  
  func loadSelectedFont() {
    let savedFontName = UserDefaults.standard.string(
      forKey: "selectedFontName"
    ) ?? "omyu_pretty"
    
    if let index = fontItems.firstIndex(where: { $0.fileName == savedFontName }) {
      selectedIndex = index
      fontItems[index].isSelected = true
    } else {
      selectedIndex = 0
      fontItems[0].isSelected = true
    }
  }
  
  func setupFontList() {
    fontStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    for (index, item) in fontItems.enumerated() {
      let itemView = createFontItemView(item: item, index: index)
      fontStackView.addArrangedSubview(itemView)
    }
  }
  
  func createFontItemView(item: FontItem, index: Int) -> UIView {
    let containerView = UIView()
    containerView.tag = index
    
    let titleLabel = UILabel()
    titleLabel.text = item.displayName
    titleLabel.font = UIFont(name: item.fileName, size: 18) ?? UIFont.systemFont(ofSize: 18)
    titleLabel.textColor = .azGray900
    
    let checkImageView = UIImageView()
    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
    checkImageView.image = UIImage(systemName: "checkmark", withConfiguration: config)
    checkImageView.tintColor = .azGray900
    checkImageView.isHidden = !item.isSelected
    
    containerView.addSubview(titleLabel)
    containerView.addSubview(checkImageView)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
      make.top.equalToSuperview().offset(8)
      make.bottom.equalToSuperview().offset(-8)
    }
    
    checkImageView.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.height.equalTo(20)
    }
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(fontItemTapped(_:)))
    containerView.addGestureRecognizer(tapGesture)
    containerView.isUserInteractionEnabled = true
    
    return containerView
  }
  
  @objc private func fontItemTapped(_ gesture: UITapGestureRecognizer) {
    guard let containerView = gesture.view,
          containerView.tag < fontItems.count else { return }
    
    let newIndex = containerView.tag
    
    fontItems[selectedIndex].isSelected = false
    
    selectedIndex = newIndex
    fontItems[selectedIndex].isSelected = true
    
    setupFontList()
    
    let selectedFont = fontItems[selectedIndex]
    UserDefaults.standard.set(selectedFont.fileName, forKey: "selectedFontName")
    
    Amp.track(event: "font_change_complete", properties: [
      "font_display_name": selectedFont.displayName,
      "font_file_name": selectedFont.fileName
    ])
    
    updateFonts()
  }
  
  func updateFonts() {
    infoTitleLabel.font = UIFont.appFont(size: 16)
    infoDescriptionLabel.font = UIFont.appFont(size: 15)
    NotificationCenter.default.post(name: .fontDidChange, object: nil)
  }
  
  @objc private func fontSizeChanged(_ slider: UISlider) {
    let level = Int(slider.value.rounded())
    UserDefaults.standard.set(level, forKey: "fontSizeLevel")
    
    infoTitleLabel.font = UIFont.appFont(size: 16)
    infoDescriptionLabel.font = UIFont.appFont(size: 15)
    setupFontList()
    
    NotificationCenter.default.post(name: .fontDidChange, object: nil)
    
    Amp.track(event: "font_size_change", properties: ["font_size_level": level])
  }
}
