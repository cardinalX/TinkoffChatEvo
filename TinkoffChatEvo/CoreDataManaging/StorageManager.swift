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
  func getFirstUserManagedObject() -> User?
  func createUserManagedObject(context: NSManagedObjectContext, name: String, info: String?) -> User
  func updateUserProfileUI(execute: @escaping (String, String) -> Void)
  func getUserManagedObject(by name: String) -> User?
  func editFirstUserManagedObject(name: String?, info: String?)
  func getAllUsersManagedObjects() -> [User?]
  //func saveBackgroundContext(successCompletion success: @escaping () -> Void,
  //                           failCompletion failure: @escaping (Error) -> Void)
  func savePrivateContext(successCompletion success: @escaping () -> Void,
                          failCompletion failure: @escaping (Error) -> Void)
}

class StorageManager{
  /// Singleton
  static let instance = StorageManager()

  private init() {}
  
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
  func saveMainContext () {
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
}

// MARK: protocol UserManaging
  
extension StorageManager: UserManaging {
  func savePrivateContext(successCompletion success: @escaping () -> Void,
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
  
  func getFirstUserManagedObject() -> User? {
    let context = privateManagedObjectContext
    let fetchRequest = NSFetchRequest<User>(entityName: String(describing: User.self))
    let users = try? context.fetch(fetchRequest)
    return users?.first
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
  
  func getUserManagedObject(by name: String) -> User? {
    let context = privateManagedObjectContext
    let fetchRequest = NSFetchRequest<User>(entityName: String(describing: User.self))
    fetchRequest.predicate = NSPredicate(format: "name == %@", name)
    let users = try? context.fetch(fetchRequest)
    return users?.first
  }
  
  func createUserManagedObject(context: NSManagedObjectContext, name: String, info: String?) -> User{
    if let user = getFirstUserManagedObject() {
      return user
    }
    let user = User(context: context)
    user.name = name
    user.info = info
    return user
  }
  
  func editFirstUserManagedObject(name: String?, info: String?) {
    if let user = getFirstUserManagedObject() {
      if let userName = name { user.name = userName }
      if let userInfo = info { user.info = userInfo }
    } else { _ = createUserManagedObject(context: privateManagedObjectContext, name: name ?? "Noname", info: info) }
  }

  func getAllUsersManagedObjects() -> [User?] {
    let fetchRequest = NSFetchRequest<User>(entityName: String(describing: User.self))
    do {
      let allUsers = try privateManagedObjectContext.fetch(fetchRequest)
      for user in allUsers {
        print("name - \(user.name ?? "nil"); info = \(user.info ?? "nil")")
        }
      print(allUsers.count)
      return allUsers
    } catch {
      print(error)
    }
    return [nil]
  }
}
