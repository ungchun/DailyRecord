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
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CoreData")
    
    let storeURL = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.ungchun.DailyRecord"
    )?.appendingPathComponent("CoreData.sqlite")
    
    if let storeURL = storeURL {
      let storeDescription = NSPersistentStoreDescription(url: storeURL)
      container.persistentStoreDescriptions = [storeDescription]
    }
    
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()
  
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  var recordEntity: NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: "Record", in: context)
  }
}
