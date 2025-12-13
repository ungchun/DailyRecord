//
//  PdfExportViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 1/16/25.
//

import UIKit
import PDFKit

import SnapKit

final class PdfExportViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: ProfileCoordinator?
  
  private let viewModel: PdfExportViewModel
  
  // MARK: - Views
  
  private lazy var titleView: UIStackView = {
    let stackView = UIStackView(
      arrangedSubviews: [leftButton, monthLabel, rightButton]
    )
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.spacing = 8
    return stackView
  }()
  
  private let monthLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.appFont(size: 20)
    label.textColor = .azGray900
    label.textAlignment = .center
    return label
  }()
  
  private let leftButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
    let image = UIImage(systemName: "chevron.left", withConfiguration: config)
    
    var configuration = UIButton.Configuration.plain()
    configuration.image = image
    configuration.contentInsets = NSDirectionalEdgeInsets(
      top: 10, leading: 10, bottom: 10, trailing: 10
    )
    button.configuration = configuration
    
    button.tintColor = .azGray700
    return button
  }()
  
  private let rightButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
    let image = UIImage(systemName: "chevron.right", withConfiguration: config)
    
    var configuration = UIButton.Configuration.plain()
    configuration.image = image
    configuration.contentInsets = NSDirectionalEdgeInsets(
      top: 10, leading: 10, bottom: 10, trailing: 10
    )
    button.configuration = configuration
    
    button.tintColor = .azGray700
    return button
  }()
  
  private let recordCountLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.appFont(size: 18)
    label.textColor = .azGray900
    return label
  }()
  
  private let shareButton: UIButton = {
    let button = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 18)
    let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: config)
    button.setImage(image, for: .normal)
    button.tintColor = .azGray900
    return button
  }()
  
  private lazy var headerStackView: UIStackView = {
    let spacer = UIView()
    spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
    
    let stackView = UIStackView(arrangedSubviews: [recordCountLabel, spacer, shareButton])
    stackView.axis = .horizontal
    stackView.alignment = .center
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
    label.text = L10n.exportDiaryPDF
    label.font = UIFont.appFont(size: 16)
    label.textColor = .azGray800
    label.numberOfLines = 0
    label.textAlignment = .left
    return label
  }()
  
  private let infoDescriptionLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.exportDiaryPDFDescription
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
  
  // MARK: - Init
  
  init(viewModel: PdfExportViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Amp.track(event: "screen_view", properties: ["screen_name": "pdf_export"])
  }
  
  // MARK: - Functions
  
  override func addView() {
    view.addSubview(headerStackView)
    view.addSubview(infoBoxView)
    infoBoxView.addSubview(infoLabelStackView)
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
    
    headerStackView.snp.makeConstraints { make in
      make.top.equalTo(infoBoxView.snp.bottom).offset(24)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  override func setupView() {
    view.backgroundColor = .azGray50
    
    navigationController?.navigationBar.tintColor = .azGray900
    navigationItem.titleView = titleView
    
    setupShareButton()
    setupMonthNavigation()
    updateMonthLabel()
  }
}

private extension PdfExportViewController {
  func setupShareButton() {
    shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
  }
  
  func setupMonthNavigation() {
    leftButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
    rightButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
  }
  
  func updateMonthLabel() {
    monthLabel.text = DateFormatter.localizedYearMonth(viewModel.currentDate)
    
    updateButtonState()
    
    if let year = Int(
      DateFormatter.formattedString(
        viewModel.currentDate,
        format: "yyyy"
      )
    ), let month = Int(
      DateFormatter.formattedString(
        viewModel.currentDate,
        format: "M"
      )
    ) {
      Task { [weak self] in
        guard let self else { return }
        do {
          try await self.viewModel.fetchMonthRecordTrigger(
            year: year, month: month
          ) {
            DispatchQueue.main.async {
              self.updateRecordCount()
            }
          }
        } catch {
          handleError(self.coordinator!, L10n.Common.error)
        }
      }
    }
  }
  
  func updateButtonState() {
    guard let nextDate = Calendar.current.date(
      byAdding: .month, value: 1, to: viewModel.currentDate
    ) else { return }
    
    let shouldHideNextButton = nextDate > Date()
    rightButton.alpha = shouldHideNextButton ? 0 : 1
  }
  
  func updateRecordCount() {
    let count = viewModel.records.count
    recordCountLabel.text = L10n.Pdf.selectedMonthDiaryCount(count)
  }
  
  @objc func previousMonth() {
    Amp.track(event: "button_click", properties: ["button_name": "pdf_previous_month"])
    
    viewModel.updateCurrentDate(
      Calendar.current.date(
        byAdding: .month, value: -1, to: viewModel.currentDate
      ) ?? viewModel.currentDate
    )
    
    DispatchQueue.main.async { [weak self] in
      self?.updateMonthLabel()
    }
  }
  
  @objc func nextMonth() {
    guard let nextDate = Calendar.current.date(
      byAdding: .month,
      value: 1,
      to: viewModel.currentDate
    ), nextDate <= Date() else {
      return
    }
    
    Amp.track(event: "button_click", properties: ["button_name": "pdf_next_month"])
    
    viewModel.updateCurrentDate(nextDate)
    
    DispatchQueue.main.async { [weak self] in
      self?.updateMonthLabel()
    }
  }
  
  @objc func shareButtonTapped() {
    Amp.track(event: "button_click", properties: ["button_name": "pdf_share"])
    
    guard !viewModel.records.isEmpty else {
      showAlert(message: L10n.Pdf.noDiaryInMonth)
      return
    }
    
    generateAndSharePDF()
  }
  
  func generateAndSharePDF() {
    let pdfData = createPDF()
    
    let fileName = DateFormatter.formattedString(Date(), format: "yyMMdd")
    let tempURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("\(fileName).pdf")
    
    do {
      try pdfData.write(to: tempURL)
      
      let activityVC = UIActivityViewController(
        activityItems: [tempURL],
        applicationActivities: nil
      )
      
      if let popoverController = activityVC.popoverPresentationController {
        popoverController.sourceView = shareButton
        popoverController.sourceRect = shareButton.bounds
      }
      
      present(activityVC, animated: true)
    } catch {
      showAlert(message: L10n.Pdf.generationFailed)
    }
  }
  
  func createPDF() -> Data {
    let pdfMetaData = [
      kCGPDFContextCreator: L10n.App.name,
      kCGPDFContextTitle: "\(L10n.App.name)_\(DateFormatter.localizedYearMonth(viewModel.currentDate))"
    ]
    
    let format = UIGraphicsPDFRendererFormat()
    format.documentInfo = pdfMetaData as [String: Any]
    
    let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 size
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    
    let data = renderer.pdfData { context in
      let pageWidth: CGFloat = 495
      let leftMargin: CGFloat = 50
      
      for (_, record) in viewModel.records.enumerated() {
        context.beginPage()
        
        var yPosition: CGFloat = 50
        let itemSpacing: CGFloat = 30
        
        let recordDate = Date(timeIntervalSince1970: TimeInterval(record.calendarDate / 1000))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .long
        let dateText = dateFormatter.string(from: recordDate)
        
        let dateFont = UIFont.appFont(size: 20)
        ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        let dateAttributes: [NSAttributedString.Key: Any] = [
          .font: dateFont,
          .foregroundColor: UIColor.black
        ]
        dateText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: dateAttributes)
        yPosition += 20 + itemSpacing
        
        if record.emotionType != "none",
           let emotionImage = UIImage(named: record.emotionType),
           emotionImage.size.width > 0,
           emotionImage.size.height > 0 {
          let emotionSize: CGFloat = 45
          let emotionRect = CGRect(
            x: leftMargin, y: yPosition, width: emotionSize, height: emotionSize
          )
          emotionImage.draw(in: emotionRect)
          yPosition += emotionSize + itemSpacing
        }
        
        if !record.imageList.isEmpty {
          let maxImagesPerRow = 2
          let fixedImageSize: CGFloat = 120
          let maxImages = min(record.imageList.count, 4)
          
          var currentColumn = 0
          var renderedImages = 0
          
          for i in 0..<maxImages {
            let imageData = record.imageList[i]
            if let image = UIImage(data: imageData),
               image.size.width > 0,
               image.size.height > 0 {
              let xPosition = leftMargin + (fixedImageSize + itemSpacing)
              * CGFloat(currentColumn)
              let imageRect = CGRect(
                x: xPosition, y: yPosition, width: fixedImageSize, height: fixedImageSize
              )
              image.draw(in: imageRect)
              renderedImages += 1
              
              currentColumn += 1
              if currentColumn >= maxImagesPerRow {
                currentColumn = 0
                yPosition += fixedImageSize + itemSpacing
              }
            }
          }
          
          if currentColumn > 0 {
            yPosition += fixedImageSize + itemSpacing
          }
        }
        
        let contentFont = UIFont.appFont(size: 16) ?? UIFont.systemFont(ofSize: 16)
        let contentAttributes: [NSAttributedString.Key: Any] = [
          .font: contentFont,
          .foregroundColor: UIColor.darkGray
        ]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        let lines = record.content.components(separatedBy: "\n")
        let lineHeight: CGFloat = 20
        
        for line in lines {
          if line.isEmpty {
            if yPosition + lineHeight > 792 {
              context.beginPage()
              yPosition = 50
            }
            yPosition += lineHeight
            continue
          }
          
          let lineSize = (line as NSString).boundingRect(
            with: CGSize(width: pageWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: contentAttributes,
            context: nil
          )
          
          let requiredHeight = lineSize.height + 5
          let remainingSpace = 792 - yPosition
          
          if requiredHeight <= remainingSpace {
            let lineRect = CGRect(
              x: leftMargin, y: yPosition, width: pageWidth, height: requiredHeight
            )
            (line as NSString).draw(in: lineRect, withAttributes: contentAttributes)
            yPosition += requiredHeight
          } else if remainingSpace >= 80 {
            let lineRect = CGRect(
              x: leftMargin, y: yPosition, width: pageWidth, height: remainingSpace - 10
            )
            (line as NSString).draw(in: lineRect, withAttributes: contentAttributes)
            
            context.beginPage()
            yPosition = 50
            
            let newLineRect = CGRect(
              x: leftMargin, y: yPosition, width: pageWidth, height: requiredHeight
            )
            (line as NSString).draw(in: newLineRect, withAttributes: contentAttributes)
            yPosition += requiredHeight
          } else {
            context.beginPage()
            yPosition = 50
            let lineRect = CGRect(
              x: leftMargin, y: yPosition, width: pageWidth, height: requiredHeight
            )
            (line as NSString).draw(in: lineRect, withAttributes: contentAttributes)
            yPosition += requiredHeight
          }
        }
      }
    }
    
    return data
  }
  
  func showAlert(message: String) {
    let alert = UIAlertController(
      title: nil,
      message: message,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: L10n.Common.confirm, style: .default))
    present(alert, animated: true)
  }
}
