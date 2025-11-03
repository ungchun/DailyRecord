//
//  RecordViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/6/24.
//

import UIKit
import WidgetKit
import PhotosUI

import SnapKit

final class RecordWriteViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: RecordCoordinator?
  
  private let viewModel: RecordViewModel
  private let calendarViewModel: CalendarViewModel
  
  // MARK: - Views
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.showsVerticalScrollIndicator = false
    return scrollView
  }()
  
  private let contentView: UIView = {
    let view = UIView()
    return view
  }()
  
  private let todayEmotionImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "plus.circle")
    imageView.tintColor = .azLightGray
    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = true
    return imageView
  }()
  
  private let todayDateView: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "omyu_pretty", size: 16)
    label.textColor = .azLightGray
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var inputDiaryView: UITextView = {
    let textView = UITextView()
    textView.delegate = self
    textView.font = UIFont(name: "omyu_pretty", size: 16)
    textView.textColor = .azLightGray.withAlphaComponent(0.5)
    textView.text = L10n.Record.howWasYourDay
    textView.backgroundColor = .clear
    textView.isScrollEnabled = false
    textView.autocapitalizationType = .none
    textView.spellCheckingType = .no
    textView.autocorrectionType = .no
    textView.setLineSpacing(lineSpacing: 8)
    return textView
  }()
  
  private let attachedImageCollectionView = AttachedImageCollectionView()
  
  private let footerView = RecordFooterView()
  
  // MARK: - Life Cycle
  
  init(
    viewModel: RecordViewModel,
    calendarViewModel: CalendarViewModel
  ) {
    self.viewModel = viewModel
    self.calendarViewModel = calendarViewModel
    super.init(nibName: nil, bundle: nil)
    
    self.navigationController?.isNavigationBarHidden = true
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let screenName = viewModel.selectData.createTime != 0 ? "record_edit" : "record_write"
    Amp.track(event: "screen_view", properties: ["screen_name": screenName])
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.isNavigationBarHidden = false
    self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Functions
  
  override func addView() {
    [scrollView, footerView].forEach {
      view.addSubview($0)
    }
    
    scrollView.addSubview(contentView)
    
    [todayEmotionImageView, todayDateView,
     attachedImageCollectionView, inputDiaryView].forEach {
      contentView.addSubview($0)
    }
  }
  
  override func setLayout() {
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalTo(scrollView.contentLayoutGuide)
      make.width.equalTo(scrollView.frameLayoutGuide)
    }
    
    todayEmotionImageView.snp.makeConstraints { make in
      make.top.equalTo(contentView.snp.top).offset(20)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(30)
    }
    
    todayDateView.snp.makeConstraints { make in
      make.top.equalTo(todayEmotionImageView.snp.bottom).offset(10)
      make.centerX.equalToSuperview()
    }
    
    attachedImageCollectionView.snp.makeConstraints { make in
      make.top.equalTo(todayDateView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(viewModel.selectData.imageList.isEmpty
                          ? 0 : 100)
    }
    
    inputDiaryView.snp.makeConstraints { make in
      make.top.equalTo(self.attachedImageCollectionView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview()
    }
    
    footerView.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview()
    }
  }
  
  override func setupView() {
    setupKeyboardNotifications()
    
    setupCustomBackButton()
    
    setupSwipeGesture()
    
    fetchEditData()
    
    DispatchQueue.main.async { [weak self] in
      self?.view.backgroundColor = .azBlack
    }
    
    let date = Date(
      timeIntervalSince1970: TimeInterval(viewModel.selectData.calendarDate) / 1000
    )
    let datePart = DateFormatter.formattedString(date, format: "yyyy.MM.dd")
    let dayOfWeekPart = DateFormatter.formattedString(date, format: "EEEE")
    DispatchQueue.main.async { [weak self] in
      self?.todayDateView.text = "\(datePart)\n\(dayOfWeekPart)"
    }
    
    let showPopupTapGesture = UITapGestureRecognizer(target: self,
                                                     action: #selector(showBottomSheetTrigger))
    todayEmotionImageView.addGestureRecognizer(showPopupTapGesture)
    
    footerView.backgroundColor = .azBlack
    let galleryTapGesture = UITapGestureRecognizer(target: self,
                                                   action: #selector(galleryTrigger))
    footerView.galleryIcon.addGestureRecognizer(galleryTapGesture)
    
    let saveTapGesture = UITapGestureRecognizer(target: self, action: #selector(saveTrigger))
    footerView.saveIcon.addGestureRecognizer(saveTapGesture)
    
    attachedImageCollectionView.delegate = self
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tapGesture)
  }
}

extension RecordWriteViewController: UIGestureRecognizerDelegate {
  private func setupCustomBackButton() {
    let largeConfig = UIImage.SymbolConfiguration(pointSize: 16,
                                                  weight: .bold, scale: .large)
    let iconImage = UIImage(systemName: "chevron.left",
                            withConfiguration: largeConfig)
    let backButton = UIBarButtonItem(
      image: iconImage,
      style: .plain,
      target: self,
      action: #selector(customBackButtonTapped)
    )
    backButton.tintColor = .azWhite
    navigationItem.leftBarButtonItem = backButton
  }
  
  @objc private func customBackButtonTapped() {
    if viewModel.isChangeContent {
      showAlertToConfirmExit()
    } else {
      navigationController?.popViewController(animated: true)
    }
  }
  
  private func setupSwipeGesture() {
    navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if viewModel.isChangeContent {
      showAlertToConfirmExit()
      return false
    }
    return true
  }
  
  private func showAlertToConfirmExit() {
    let alert = UIAlertController(
      title: L10n.Exit.Warning.title,
      message: L10n.Exit.Warning.message,
      preferredStyle: .alert
    )
    let stayAction = UIAlertAction(title: L10n.Continue.writing, style: .default, handler: nil)
    let exitAction = UIAlertAction(title: L10n.exit, style: .cancel) {_ in
      self.navigationController?.popViewController(animated: true)
    }
    alert.addAction(stayAction)
    alert.addAction(exitAction)
    present(alert, animated: true, completion: nil)
  }
}

private extension RecordWriteViewController {
  func fetchEditData() {
    if viewModel.selectData.createTime != 0 {
      viewModel.setNotImageData {
        self.updateNotImageView()
      }
      
      self.updateImageView()
    }
  }
  
  func updateNotImageView() {
    if !self.viewModel.content.isEmpty {
      DispatchQueue.main.async { [weak self] in
        self?.inputDiaryView.text = self?.viewModel.content
      }
      inputDiaryView.textColor = .azWhite
    }
    
    emotionalImageTapTrigger(selectEmotionType: viewModel.emotionType)
  }
  
  func updateImageView() {
    viewModel.updateSelectedAssetIdentifiers(viewModel.imageList.map{$0.0})
    attachedImageCollectionView.setImages(viewModel.imageList)
  }
}

private extension RecordWriteViewController {
  func setupKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification, object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification, object: nil
    )
  }
  
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
        as? NSValue {
      let keyboardHeight = keyboardFrame.cgRectValue.height
      adjustFooterViewForKeyboard(show: true, keyboardHeight: keyboardHeight)
    }
  }
  
  @objc func keyboardWillHide(notification: NSNotification) {
    adjustFooterViewForKeyboard(show: false, keyboardHeight: 0)
  }
  
  func adjustFooterViewForKeyboard(show: Bool, keyboardHeight: CGFloat) {
    footerView.snp.updateConstraints { make in
      if show {
        make.bottom.equalToSuperview().offset(-(keyboardHeight)+30)
      } else {
        make.bottom.equalToSuperview()
      }
    }
    
    scrollView.contentInset = UIEdgeInsets(
      top: 0.0,
      left: 0.0,
      bottom: keyboardHeight + footerView.frame.size.height,
      right: 0.0
    )
    
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
}

private extension RecordWriteViewController {
  @objc func showBottomSheetTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "emotion_select"])
    
    let bottomSheetVC = EmotionalBottomSheetViewController()
    bottomSheetVC.delegate = self
    
    if let sheet = bottomSheetVC.sheetPresentationController {
      sheet.prefersGrabberVisible = true
    }
    
    present(bottomSheetVC, animated: true)
    viewModel.updateIsChangeContent(true)
  }
  
  @objc func galleryTrigger() {
    Amp.track(event: "button_click", properties: ["button_name": "gallery"])
    
    var configuration = PHPickerConfiguration(photoLibrary: .shared())
    configuration.filter = .images
    configuration.selectionLimit = 5
    configuration.selection = .ordered
    configuration.preselectedAssetIdentifiers = viewModel.selectedAssetIdentifiers
    configuration.preferredAssetRepresentationMode = .current
    
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = self
    present(picker, animated: true, completion: nil)
  }
  
  @objc func saveTrigger() {
    view.endEditing(true)
    LoadingIndicator.showLoading()
    
    let isUpdate = viewModel.selectData.createTime != 0
    let imageCount = attachedImageCollectionView.images.count
    let hasEmotion = viewModel.emotionType != .none
    
    viewModel.updateImageList(attachedImageCollectionView.images)
    
    Task { [weak self] in
      guard let self else { return }
      do {
        try await self.viewModel.createRecordTirgger()
        
        Amp.track(event: "record_save", properties: [
          "is_update": isUpdate,
          "image_count": imageCount,
          "has_emotion": hasEmotion,
          "content_length": self.viewModel.content.count
        ])
        
        let calendarDate = self.viewModel.selectData.calendarDate
        let date = Date(timeIntervalSince1970: TimeInterval(calendarDate) / 1000)
        let dayOfyear = DateFormatter.formattedString(date, format: "yyyy")
        let dayOfmonth = DateFormatter.formattedString(date, format: "M")
        
        if let year = Int(dayOfyear),
           let month = Int(dayOfmonth) {
          do {
            try await self.calendarViewModel.fetchMonthRecordTrigger(
              year: year, month: month
            ) { }
          } catch {
            handleError(self.coordinator!, L10n.Common.error)
          }
          
          WidgetCenter.shared.reloadAllTimelines()
          LoadingIndicator.hideLoading()
          handleError(self.coordinator!, L10n.Common.diarySaved)
        }
      } catch {
        Amp.track(event: "record_save_fail", properties: [
          "is_update": isUpdate,
          "error": error.localizedDescription
        ])
        handleError(self.coordinator!, L10n.Common.error)
      }
    }
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}

extension RecordWriteViewController: AttachedImageCollectionViewDelegate {
  func collectionViewZeroHeightTrigger() {
    DispatchQueue.main.async { [weak self] in
      self?.attachedImageCollectionView.snp.updateConstraints { make in
        make.height.equalTo(0.5)
      }
    }
  }
  
  func removeAssetIdentifier(_ identifier: String) {
    viewModel.removeAssetIdentifier(identifier)
  }
}

extension RecordWriteViewController: EmotionalBottomSheetViewViewDelegate {
  func emotionalImageTapTrigger(selectEmotionType: EmotionType) {
    Amp.track(event: "emotion_selected", properties: ["emotion_type": selectEmotionType.rawValue])
    
    if let image = UIImage(named: selectEmotionType.rawValue) {
      viewModel.updateEmotionType(selectEmotionType)
      
      DispatchQueue.main.async { [weak self] in
        self?.todayEmotionImageView.backgroundColor = .clear
        self?.todayEmotionImageView.image = image
      }
      
      let originalWidth = image.size.width
      let originalHeight = image.size.height
      let aspectRatio = originalHeight / originalWidth
      let desiredWidth: CGFloat = 80
      let desiredHeight = desiredWidth * aspectRatio
      DispatchQueue.main.async { [weak self] in
        self?.todayEmotionImageView.snp.updateConstraints { make in
          make.width.equalTo(desiredWidth)
          make.height.equalTo(desiredHeight)
        }
      }
    }
  }
}

extension RecordWriteViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    viewModel.updateContent(textView.text)
    viewModel.updateIsChangeContent(true)
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == L10n.Record.howWasYourDay {
      guard textView.textColor == .azLightGray.withAlphaComponent(0.5) else { return }
      textView.text = nil
      textView.textColor = .azWhite
    }
  }
}

extension RecordWriteViewController: PHPickerViewControllerDelegate {
  func picker(
    _ picker: PHPickerViewController,
    didFinishPicking results: [PHPickerResult]
  ) {
    picker.dismiss(animated: true, completion: nil)
    
    let dispatchGroup = DispatchGroup()
    
    var newSelections = [String: PHPickerResult]()
    for result in results {
      let identifier = result.assetIdentifier!
      newSelections[identifier] = viewModel.selections[identifier] ?? result
    }
    
    viewModel.updateSelections(newSelections)
    viewModel.updateSelectedAssetIdentifiers(results.compactMap { $0.assetIdentifier })
    
    var imagesDict = [String: UIImage]()
    
    for (identifier, result) in viewModel.selections {
      dispatchGroup.enter()
      let itemProvider = result.itemProvider
      if itemProvider.canLoadObject(ofClass: UIImage.self) {
        itemProvider.loadObject(ofClass: UIImage.self) { image, error in
          if let image = image as? UIImage {
            imagesDict[identifier] = image
          }
          dispatchGroup.leave()
        }
      } else {
        if let idx = viewModel.imageList.firstIndex(where: {$0.0 == identifier}) {
          imagesDict[identifier] = viewModel.imageList[idx].1
        }
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: .main) { [weak self] in
      guard let self = self else { return }
      var selectedImages: [(String, UIImage)] = []
      for identifier in self.viewModel.selectedAssetIdentifiers {
        if let image = imagesDict[identifier] {
          selectedImages.append((identifier, image))
        }
      }
      
      if results.count == selectedImages.count {
        Amp.track(event: "images_attached", properties: ["image_count": selectedImages.count])
        
        DispatchQueue.main.async { [weak self] in
          self?.attachedImageCollectionView.setImages(selectedImages)
          self?.attachedImageCollectionView.snp.updateConstraints { make in
            make.height.equalTo(100)
          }
        }
      }
    }
  }
}
