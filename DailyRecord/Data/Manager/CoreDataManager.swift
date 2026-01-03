//
//  CoreDataManager.swift
//  DailyRecord
//
//  Created by Kim SungHun on 9/28/24.
//

import CoreData
import CloudKit

final class CoreDataManager {
  static var shared: CoreDataManager = CoreDataManager()
  
  static let cloudKitDidSyncNotification = Notification.Name("cloudKitDidSyncNotification")
  
  private init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(storeRemoteChange(_:)),
      name: .NSPersistentStoreRemoteChange,
      object: nil
    )
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  lazy var persistentContainer: NSPersistentCloudKitContainer = {
    let container = NSPersistentCloudKitContainer(name: "CoreData")
    
    let storeURL = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.ungchun.DailyRecord"
    )?.appendingPathComponent("CoreData.sqlite")
    
    if let storeURL = storeURL {
      let storeDescription = NSPersistentStoreDescription(url: storeURL)
      container.persistentStoreDescriptions = [storeDescription]
      storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
        containerIdentifier: "iCloud.DailyRecord.Containers"
      )
      storeDescription.setOption(
        true as NSNumber,
        forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
      )
    }
    
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.automaticallyMergesChangesFromParent = true
    
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError()
      }
    }
    
    return container
  }()
  
  var context: NSManagedObjectContext {
    let context = persistentContainer.viewContext
    return context
  }
  
  var recordEntity: NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: "Record", in: context)
  }
  
  @objc private func storeRemoteChange(_ notification: Notification) {
    let count = getTotalRecordCount()
    DispatchQueue.main.async {
      NotificationCenter.default.post(
        name: CoreDataManager.cloudKitDidSyncNotification,
        object: nil,
        userInfo: ["count": count]
      )
    }
  }
  
  func getTotalRecordCount() -> Int {
    let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "calendar_date > 0")
    
    do {
      let count = try context.count(for: fetchRequest)
      return count
    } catch {
      return 0
    }
  }
  
  func checkCloudKitRecordExists(completion: @escaping (Bool, Int) -> Void) {
    let container = CKContainer(identifier: "iCloud.DailyRecord.Containers")
    let privateDatabase = container.privateCloudDatabase
    
    let query = CKQuery(
      recordType: "CD_Record",
      predicate: NSPredicate(value: true)
    )
    
    let operation = CKQueryOperation(query: query)
    
    var recordCount = 0
    
    operation.recordMatchedBlock = { _, result in
      if case .success = result {
        recordCount += 1
      }
    }
    
    operation.queryResultBlock = { result in
      DispatchQueue.main.async {
        switch result {
        case .success:
          completion(recordCount > 0, recordCount)
        case .failure:
          completion(false, 0)
        }
      }
    }
    
    privateDatabase.add(operation)
  }
}
