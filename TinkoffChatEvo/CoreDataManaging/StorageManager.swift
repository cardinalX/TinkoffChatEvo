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
}

protocol backgroundSaving {
  func saveBackgroundContext()
}

class StorageManager {
  
  /// Singleton
  static let instance = StorageManager()
  lazy var backgroundContext = persistentContainer.newBackgroundContext()

  private init() {}
  
  // MARK: - Core Data stack
  
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
  
  // MARK: - Core Data Saving support
  
  func saveBackgroundContext () {
    if backgroundContext.hasChanges{
      backgroundContext.perform {
        do {
          try self.backgroundContext.save()
        } catch {
          let error = error as Error
          fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
      }
    }
  }
  
  func saveBackgroundContext(successCompletion success: @escaping () -> Void,
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
  }
}

// MARK: protocol UserManaging
  
extension StorageManager: UserManaging {
  func getFirstUserManagedObject() -> User? {
    let context = backgroundContext
    let fetchRequest = NSFetchRequest<User>(entityName: String(describing: User.self))
    let users = try? context.fetch(fetchRequest)
    return users?.first
  }
  
  func updateUserProfileUI(execute: @escaping (String, String) -> Void){
    let context = backgroundContext
    context.perform {
      let fetchRequest = NSFetchRequest<User>(entityName: String(describing: User.self))
      let allUsers = try? context.fetch(fetchRequest)
      if let user = allUsers?.first {
        print(user.name as Any)
        execute(user.name ?? "nil", user.info ?? "")
      } else {
        print("Error updating UserProfileUI, no users")
      }
    }
  }
  
  func getUserManagedObject(by name: String) -> User? {
    let context = backgroundContext
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
    } else { _ = createUserManagedObject(context: backgroundContext, name: name ?? "Noname", info: info) }
  }

  func getAllUsersManagedObjects() -> [User?] {
    let fetchRequest = NSFetchRequest<User>(entityName: String(describing: User.self))
    do {
      let allUsers = try backgroundContext.fetch(fetchRequest)
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
