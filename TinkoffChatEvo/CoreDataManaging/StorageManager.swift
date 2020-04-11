//
//  StorageManager.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 28.03.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import Foundation
import CoreData

protocol UserManaging {
  func updateUserProfileUI(execute: @escaping (String, String) -> Void)
  func saveUserProfile(name: String?,
                       info: String?,
                       successCompletion success: @escaping () -> Void,
                       failCompletion failure: @escaping (Error) -> Void)
  var userName: String { get }
}

class StorageManager{
  // MARK: - Core Data stack
  
  lazy var appDocumentsDirectory: URL = {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls[urls.count-1]
  }()
  
  lazy var managedObjectModel: NSManagedObjectModel = {
    if let urlOfModel = Bundle.main.url(forResource: "TinkoffChatEvo", withExtension: "momd") {
      let model = NSManagedObjectModel(contentsOf: urlOfModel)
      return model ?? NSManagedObjectModel()
    }
    return NSManagedObjectModel()
  }()
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.appDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    } catch {
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
      dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
      dict[NSUnderlyingErrorKey] = error as NSError
      let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
      abort()
    }
    return coordinator
  }()
  
  lazy var mainManagedObjectContext: NSManagedObjectContext = {
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()
  
  lazy var privateManagedObjectContext: NSManagedObjectContext = {
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()
   
  
  // MARK: - Core Data Saving support
  private func saveMainContext () {
      if mainManagedObjectContext.hasChanges {
          do {
              try mainManagedObjectContext.save()
          } catch {
              let nserror = error as NSError
              NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
              abort()
          }
      }
  }
  
  // MARK: - PersistentContainer realisation
  /*
  lazy var backgroundContext = persistentContainer.newBackgroundContext()
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "TinkoffChatEvo")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        assertionFailure(error.localizedDescription)
      }
      print("Container is ready to use")
    })
    return container
  }()
  
  // MARK - Core Data Saving support
   
  func saveBackgroundContext() {
    if backgroundContext.hasChanges{
      backgroundContext.perform {
        do {
          try self.backgroundContext.save()
        } catch {
          let error = error as Error
        }
      }
    }
  }
  */
  /*func saveBackgroundContext(successCompletion success: @escaping () -> Void,
                             failCompletion failure: @escaping (Error) -> Void) {
    if backgroundContext.hasChanges{
      backgroundContext.perform {
        do {
          try self.backgroundContext.save()
          success()
        } catch {
          let error = error as Error
          failure(error)
        }
      }
    }
  }*/
  
  private func savePrivateContext(successCompletion success: @escaping () -> Void,
                          failCompletion failure: @escaping (Error) -> Void) {
    if privateManagedObjectContext.hasChanges{
      privateManagedObjectContext.perform {
        do {
          try self.privateManagedObjectContext.save()
          success()
        } catch {
          let error = error as Error
          failure(error)
        }
      }
    }
  }
}

// MARK: protocol UserManaging
  
extension StorageManager: UserManaging {
  var userName: String {
    get {
      guard let user = fetchUserManagedObject() else{
        return "Noname"
      }
      return user.name ?? "Noname"
    }
  }
  
  private func createUserManagedObject(context: NSManagedObjectContext, name: String, info: String?) -> User{
    if let user = fetchUserManagedObject() {
      return user
    }
    let user = User(context: context)
    user.name = name
    user.info = info
    return user
  }
  
  private func fetchUserManagedObject() -> User? {
    let context = privateManagedObjectContext
    let fetchRequest = NSFetchRequest<User>(entityName: String(describing: User.self))
    do {
      let users = try context.fetch(fetchRequest)
      return users.first
    } catch {
        fatalError("Failed to fetch Users: \(error)")
    }
  }
  
  func updateUserProfileUI(execute: @escaping (String, String) -> Void){
    let context = privateManagedObjectContext
    context.perform {
      let fetchRequest = NSFetchRequest<User>(entityName: String(describing: User.self))
      let allUsers = try? context.fetch(fetchRequest)
      if let user = allUsers?.first {
        print(user.name as Any)
        self.mainManagedObjectContext.perform{
          execute(user.name ?? "nil", user.info ?? "")
        }
      } else {
        print("Error updating UserProfileUI, no users")
      }
    }
  }
  
  func saveUserProfile(name: String?, info: String?, successCompletion success: @escaping () -> Void, failCompletion failure: @escaping (Error) -> Void) {
    if let user = fetchUserManagedObject() {
      if let userName = name { user.name = userName }
      if let userInfo = info { user.info = userInfo }
    } else { _ = createUserManagedObject(context: privateManagedObjectContext, name: name ?? "Noname", info: info) }
    
    savePrivateContext(successCompletion: success, failCompletion: failure)
  }
}
