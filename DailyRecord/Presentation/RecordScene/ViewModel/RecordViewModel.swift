//
//  RecordViewModel.swift
//  DailyRecord
//
//  Created by Kim SungHun on 6/15/24.
//

import UIKit
import CoreData

final class RecordViewModel: BaseViewModel {
  
  // MARK: - Properties
  
  private let coreDataManager: CoreDataManager = CoreDataManager.shared
  private let recordUseCase: DefaultRecordUseCase
  
  var selectData: RecordEntity
  
  var content: String = "" // 글 내용
  var imageList: [(String, UIImage)] = [] // 첨부 이미지와 식별자
  var emotionType: EmotionType = .none
  
  private var calendarDate: Int = 0 // 선택 날짜
  private var createTime: Int = 0 // 생성(수정) 시간
  private var isUpdateState: Bool // 수정하기
  
  // MARK: - Init
  
  init(
    recordUseCase: DefaultRecordUseCase,
    selectData: RecordEntity
  ) {
    self.recordUseCase = recordUseCase
    self.selectData = selectData
    self.isUpdateState = selectData.createTime == 0 ? false : true
  }
}

extension RecordViewModel {
  
  // MARK: - Functions
  
  func createRecordTirgger() async throws {
    self.calendarDate = selectData.calendarDate
    var createImageListValue: [(String, Data)] = []
    
    for (identifier, image) in self.imageList {
      if let imageData = image.jpegData(compressionQuality: 0.1) {
        createImageListValue.append((identifier, imageData))
      }
    }
    
    let recordRequest = RecordEntity(
      content: self.content,
      emotionType: emotionType.rawValue,
      imageList: createImageListValue.map{$0.1},
      imageIdentifier: createImageListValue.map{$0.0},
      createTime: Int(Date().millisecondsSince1970),
      calendarDate: self.calendarDate
    )
    
    if isUpdateState {
      try await recordUseCase.updateRecord(data: recordRequest)
    } else {
      try await recordUseCase.createRecord(data: recordRequest)
    }
  }
  
  func removeRecordTirgger() async throws {
    self.calendarDate = selectData.calendarDate
    try await recordUseCase.removeRecord(calendarDate: self.calendarDate)
  }
}

extension RecordViewModel {
  func setNotImageData(completion: @escaping () -> Void) {
    content = selectData.content
    emotionType = EmotionType(rawValue: selectData.emotionType) ?? .none
    createTime = selectData.createTime
    completion()
  }
  
  func setImageData(completion: @escaping () -> Void) {
    let imageLists = selectData.imageList
    let imageIdentifiers = selectData.imageIdentifier
    let dispatchGroup = DispatchGroup()
    var loadedImages: [(String, UIImage)] = Array(repeating: ("", UIImage()),
                                                  count: imageLists.count)
    
    for idx in imageLists.indices {
      dispatchGroup.enter()
      loadImage(from: imageLists[idx]) { image in
        if let image = image {
          if imageLists.count == imageIdentifiers.count {
            loadedImages[idx] = (imageIdentifiers[idx], image)
          } else {
            loadedImages[idx] = ("", image)
          }
        }
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: .main) {
      self.imageList = loadedImages
      completion()
    }
  }
  
  private func loadImage(
    from data: Data,
    completion: @escaping (UIImage?) -> Void
  ) {
    let image = UIImage(data: data)
    DispatchQueue.main.async {
      completion(image)
    }
  }
}
