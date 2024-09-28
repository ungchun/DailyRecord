//
//  RecordRepository.swift
//  DailyRecord
//
//  Created by Kim SungHun on 7/7/24.
//

import CoreData

final class RecordRepository: DefaultRecordRepository {
  private let coreDataManager = CoreDataManager.shared
}

extension RecordRepository {
  func createRecord(data: RecordEntity) async throws {
    if let entity = coreDataManager.recordEntity {
      let managedObject = NSManagedObject(
        entity: entity,
        insertInto: coreDataManager.context
      )
      managedObject.setValue(data.content, forKey: "content")
      managedObject.setValue(data.emotionType, forKey: "emotion_type")
      managedObject.setValue(data.imageList, forKey: "image_list")
      managedObject.setValue(data.imageIdentifier, forKey: "image_identifier")
      managedObject.setValue(data.createTime, forKey: "create_time")
      managedObject.setValue(data.calendarDate, forKey: "calendar_date")
    }
    
    try? coreDataManager.context.save()
  }
  
  func updateRecord(data: RecordEntity) async throws {
    let request = Record.fetchRequest()
    
    guard let records = try? coreDataManager.context.fetch(request) else { return }
    if let targetRecord = records.filter({$0.calendar_date == data.calendarDate}).first {
      targetRecord.content = data.content
      targetRecord.emotion_type = data.emotionType
      targetRecord.image_list = data.imageList as NSObject
      targetRecord.image_identifier = data.imageIdentifier as NSObject
      targetRecord.create_time = Int64(data.createTime)
      targetRecord.calendar_date = Int64(data.calendarDate)
    }
    
    try? coreDataManager.context.save()
  }
  
  func removeRecord(calendarDate: Int) async throws {
    let request = Record.fetchRequest()
    
    guard let records = try? coreDataManager.context.fetch(request) else { return }
    
    if let targetRecord = records.filter({ $0.calendar_date == calendarDate }).first {
      coreDataManager.context.delete(targetRecord)
    }
    
    try? coreDataManager.context.save()
  }
}
