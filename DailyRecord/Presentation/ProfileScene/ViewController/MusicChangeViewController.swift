//
//  MusicChangeViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 1/15/25.
//

import UIKit

import SnapKit

struct MusicItem {
  let title: String
  let fileName: String
  var isSelected: Bool = false
}

final class MusicChangeViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: ProfileCoordinator?
  
  private var musicItems: [MusicItem] = [
    MusicItem(title: L10n.Music.quietForest, fileName:"background_music_1"),
    MusicItem(title: L10n.Music.freshDawn, fileName: "background_music_2"),
    MusicItem(title: L10n.Music.calmRiverside, fileName: "background_music_3")
  ]
  
  private var selectedIndex: Int = 0
  
  // MARK: - Views
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = true
    return scrollView
  }()
  
  private let contentView: UIView = {
    let view = UIView()
    return view
  }()
  
  private let musicStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    return stackView
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
    
    Amp.track(event: "screen_view", properties: ["screen_name": "music_change"])
    
    loadSelectedMusic()
    setupMusicList()
  }
  
  // MARK: - Functions
  
  override func addView() {
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    contentView.addSubview(musicStackView)
  }
  
  override func setLayout() {
    scrollView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
    
    musicStackView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.leading.equalToSuperview().offset(16)
      make.trailing.equalToSuperview().offset(-16)
      make.bottom.equalToSuperview().offset(-16)
    }
  }
  
  override func setupView() {
    view.backgroundColor = .azGray50
    
    navigationController?.navigationBar.tintColor = .azGray900
  }
}

private extension MusicChangeViewController {
  func loadSelectedMusic() {
    let savedFileName = UserDefaults.standard.string(
      forKey: "selectedMusicFileName"
    ) ?? "background_music_1"
    
    if let index = musicItems.firstIndex(where: { $0.fileName == savedFileName }) {
      selectedIndex = index
      musicItems[index].isSelected = true
    } else {
      selectedIndex = 0
      musicItems[0].isSelected = true
    }
  }
  
  func setupMusicList() {
    musicStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    for (index, item) in musicItems.enumerated() {
      let itemView = createMusicItemView(item: item, index: index)
      musicStackView.addArrangedSubview(itemView)
    }
  }
  
  func createMusicItemView(item: MusicItem, index: Int) -> UIView {
    let containerView = UIView()
    containerView.tag = index
    
    let titleLabel = UILabel()
    titleLabel.text = item.title
    titleLabel.font = UIFont(name: "omyu_pretty", size: 18)
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
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(musicItemTapped(_:)))
    containerView.addGestureRecognizer(tapGesture)
    containerView.isUserInteractionEnabled = true
    
    return containerView
  }
  
  @objc private func musicItemTapped(_ gesture: UITapGestureRecognizer) {
    guard let containerView = gesture.view,
          containerView.tag < musicItems.count else { return }
    
    let newIndex = containerView.tag
    
    musicItems[selectedIndex].isSelected = false
    
    selectedIndex = newIndex
    musicItems[selectedIndex].isSelected = true
    
    setupMusicList()
    
    let selectedMusic = musicItems[selectedIndex]
    UserDefaults.standard.set(selectedMusic.fileName, forKey: "selectedMusicFileName")
    SoundManager.shared.play(fileName: selectedMusic.fileName, fileExtension: "mp3")
    
    Amp.track(event: "music_change_complete", properties: [
      "music_name": selectedMusic.title,
      "file_name": selectedMusic.fileName
    ])
  }
}
