//
//  SearchRepository.swift
//  DailyRecord
//
//  Created by Kim SungHun on 3/17/25.
//

import CoreData

final class SearchRepository: DefaultSearchRepository {
  private let coreDataManager = CoreDataManager.shared
}

extension SearchRepository {
  func searchRecords(query: String) throws -> [RecordEntity] {
    let context = coreDataManager.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<Record>(entityName: "Record")
    
    fetchRequest.predicate = NSPredicate(format: "content CONTAINS[cd] %@", query)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "calendar_date", ascending: false)]
    
    do {
      let records = try context.fetch(fetchRequest)
      let recordEntities = records.map { record -> RecordEntity in
        return RecordEntity(
          content: record.content ?? "",
          emotionType: record.emotion_type ?? "",
          imageList: record.image_list ?? [],
          imageIdentifier: record.image_identifier ?? [],
          createTime: Int(record.create_time),
          calendarDate: Int(record.calendar_date)
        )
      }
      
      return recordEntities
    } catch {
      throw error
    }
  }
}
