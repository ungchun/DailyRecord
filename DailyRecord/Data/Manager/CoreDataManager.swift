//
//  CoreDataManager.swift
//  DailyRecord
//
//  Created by Kim SungHun on 9/28/24.
//

import CoreData

final class CoreDataManager {
  static var shared: CoreDataManager = CoreDataManager()
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CoreData")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  var recordEntity: NSEntityDescription? {
    return  NSEntityDescription.entity(forEntityName: "Record", in: context)
  }
}
