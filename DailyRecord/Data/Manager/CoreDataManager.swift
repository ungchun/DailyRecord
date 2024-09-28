//
//  CoreDataManager.swift
//  DailyRecord
//
//  Created by Kim SungHun on 9/28/24.
//

import CoreData

final class CoreDataManager {
  static var shared: CoreDataManager = CoreDataManager()
  
  private init() {}
  
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
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return context
  }
  
  var recordEntity: NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: "Record", in: context)
  }
}
