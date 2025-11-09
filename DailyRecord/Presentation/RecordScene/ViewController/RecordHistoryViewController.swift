//
//  RecordHistoryViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/23/24.
//

import UIKit
import WidgetKit

import SnapKit

final class RecordHistoryViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: RecordCoordinator?
  
  private let viewModel: RecordViewModel
  private let calendarViewModel: CalendarViewModel
  
  // MARK: - Views
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    return scrollView
  }()
  
  private let contentView: UIView = {
    let view = UIView()
    return view
  }()
  
  private let todayEmotionImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.tintColor = .azGray700
    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = true
    return imageView
  }()
  
  private let createDateView: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "omyu_pretty", size: 16)
    label.textColor = .azGray700
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private let imageCarouselView = ImageCarouselView()
  
  private lazy var inputDiaryView: UITextView = {
    let textView = UITextView()
    textView.font = UIFont(name: "omyu_pretty", size: 16)
    textView.textColor = .azGray900
    textView.backgroundColor = .clear
    textView.isScrollEnabled = false
    textView.isEditable = false
    return textView
  }()
  
  // MARK: - Init
  
  init(
    viewModel: RecordViewModel,
    calendarViewModel: CalendarViewModel
  ) {
    self.viewModel = viewModel
    self.calendarViewModel = calendarViewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Amp.track(event: "screen_view", properties: ["screen_name": "record_view"])
  }
  
  // MARK: - Functions
  
  override func addView() {
    [scrollView].forEach {
      view.addSubview($0)
    }
    
    scrollView.addSubview(contentView)
    
    [todayEmotionImageView, createDateView,
     imageCarouselView, inputDiaryView].forEach {
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
      make.width.height.equalTo(0)
    }
    
    createDateView.snp.makeConstraints { make in
      make.top.equalTo(todayEmotionImageView.snp.bottom).offset(10)
      make.centerX.equalToSuperview()
    }
    
    imageCarouselView.snp.makeConstraints { make in
      make.top.equalTo(createDateView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(0)
    }
    
    inputDiaryView.snp.makeConstraints { make in
      make.top.equalTo(imageCarouselView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview()
    }
  }
  
  override func setupView() {
    setupNavigationBar()
    
    DispatchQueue.main.async { [weak self] in
      self?.view.backgroundColor = .azGray50
    }
    
    let date = Date(
      timeIntervalSince1970: TimeInterval(viewModel.selectData.calendarDate) / 1000
    )
    let datePart = DateFormatter.formattedString(date, format: "yyyy.MM.dd")
    let dayOfWeekPart = DateFormatter.formattedString(date, format: "EEEE")
    DispatchQueue.main.async { [weak self] in
      self?.createDateView.text = "\(datePart)\n\(dayOfWeekPart)"
    }
    
    if let image = UIImage(named: viewModel.selectData.emotionType) {
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
    
    if !viewModel.selectData.imageList.isEmpty {
      viewModel.setImageData {
        if !self.viewModel.imageList.isEmpty {
          self.imageCarouselView.setImages(self.viewModel.imageList.map{$0.1})
          DispatchQueue.main.async { [weak self] in
            self?.imageCarouselView.snp.updateConstraints { make in
              make.height.equalTo(100)
            }
          }
        }
      }
    }
    
    DispatchQueue.main.async { [weak self] in
      self?.inputDiaryView.text = self?.viewModel.selectData.content
      self?.inputDiaryView.setLineSpacing(lineSpacing: 8)
    }
  }
}

extension RecordHistoryViewController {
  private func setupNavigationBar() {
    let largeConfig = UIImage.SymbolConfiguration(pointSize: 16,
                                                  weight: .medium, scale: .large)
    let iconImage = UIImage(systemName: "ellipsis",
                            withConfiguration: largeConfig)
    let editButtonItem = UIBarButtonItem(
      image: iconImage,
      primaryAction: nil,
      menu: menu
    )
    navigationItem.rightBarButtonItem = editButtonItem
  }
  
  private var menu: UIMenu {
    return UIMenu(title: "",
                  image: nil,
                  identifier: nil,
                  options: [], children: menuItems)
  }
  
  private var menuItems: [UIAction] {
    return [UIAction(title: L10n.Action.edit,
                     image: UIImage(systemName: "pencil"),
                     handler: { _ in
      Amp.track(event: "button_click", properties: ["button_name": "record_edit"])
      self.coordinator?.showWriteViewController(self.viewModel)}),
            UIAction(title: L10n.Action.delete,
                     image: UIImage(systemName: "trash"),
                     attributes: .destructive,
                     handler: { _ in
      Amp.track(event: "button_click", properties: ["button_name": "record_delete"])
      
      let alert = UIAlertController (
        title: L10n.Alert.deleteDiaryTitle,
        message: L10n.Alert.deleteDiaryMessage,
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: L10n.Action.cancel, style: .default) { _ in
        Amp.track(event: "record_delete_cancel")
      })
      alert.addAction(UIAlertAction(title: L10n.Action.confirmDelete, style: .destructive) { _ in
        Task { [weak self] in
          guard let self else { return }
          do {
            try await self.viewModel.removeRecordTirgger()
            
            Amp.track(event: "record_delete_success")
            
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
              handleError(self.coordinator!, L10n.Common.diaryDeleted)
            }
          } catch {
            Amp.track(
              event: "record_delete_fail",
              properties: ["error": error.localizedDescription]
            )
            handleError(self.coordinator!, L10n.Common.error)
          }
        }
      })
      self.present(alert, animated: true, completion: nil)
    })]
  }
}
