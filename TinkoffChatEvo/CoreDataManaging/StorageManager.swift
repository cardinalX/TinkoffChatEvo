//
//  StorageManager.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 28.03.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import Foundation
import CoreData

class StorageManager {
  // MARK: - Core Data stack
  /*
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
  */
  // MARK: - PersistentContainer realisation
  
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
  /*
  private func saveAtPrivateContext(successCompletion success: @escaping () -> Void,
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
 */
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
  
  private func fetchUserManagedObject() -> User? {
    let context = backgroundContext
    let fetchRequest = NSFetchRequest<User>(entityName: String(describing: User.self))
    do {
      let users = try context.fetch(fetchRequest)
      return users.first
    } catch {
        fatalError("Failed to fetch Users: \(error)")
    }
  }
  
  func updateUserProfileUI(execute: @escaping (String, String) -> Void){
    let context = persistentContainer.viewContext
    context.perform {
      let fetchRequest = NSFetchRequest<User>(entityName: String(describing: User.self))
      let allUsers = try? context.fetch(fetchRequest)
      if let user = allUsers?.first {
        print("\(user.name as Any) FROM updateUserProfileUI")
        execute(user.name ?? "nil", user.info ?? "")
      } else {
        print("Error updating UserProfileUI, no users")
      }
    }
  }
  
  func saveUserProfile(name: String?, info: String?, successCompletion success: @escaping () -> Void, failCompletion failure: @escaping (Error) -> Void) {
    if let user = fetchUserManagedObject() {
      if let userName = name { user.name = userName }
      if let userInfo = info { user.info = userInfo }
    } else {
      let user = User(context: backgroundContext)
      user.name = name ?? "Noname"
      user.info = info
    }
    
    saveBackgroundContext(successCompletion: success, failCompletion: failure)
  }
}

extension StorageManager: ChannelCaching {
  
  func saveChannel(channelFB: ChannelFB, successCompletion success: @escaping () -> Void, failCompletion failure: @escaping (Error) -> Void) {
    if let channelCached = fetchChannelByIdentifier(identifier: channelFB.identifier) {
      if channelCached.name != channelFB.name { channelCached.name = channelFB.name}
      if channelCached.lastActivity != channelFB.lastActivity { channelCached.lastActivity = channelFB.lastActivity}
      if channelCached.lastMessage != channelFB.lastMessage { channelCached.lastMessage = channelFB.lastMessage}
    } else {
      let channelNew = Channel(context: backgroundContext)
      channelNew.identifier = channelFB.identifier
      channelNew.name = channelFB.name
      channelNew.lastActivity = channelFB.lastActivity
      channelNew.lastMessage = channelFB.lastMessage
    }

    saveBackgroundContext(successCompletion: success, failCompletion: failure)
  }
  
  func fetchChannelByIdentifier(identifier: String) -> Channel?{
    let context = backgroundContext
    let fetchRequest = NSFetchRequest<Channel>(entityName: String(describing: Channel.self))
    fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
    do {
      let channel = try context.fetch(fetchRequest)
      return channel.first
    } catch {
      fatalError("Failed to fetch Channel by id:\(identifier). Error: \(error)")
    }
  }

}

extension StorageManager: MessageCaching {
  
  func saveMessage(messageFB: MessageFB, messageId: String, parentChannelIdentifier: String, successCompletion success: @escaping () -> Void, failCompletion failure: @escaping (Error) -> Void) {
    if let messageCached = fetchMessageByIdentifier(identifier: messageId) {
      if messageCached.content != messageFB.content { messageCached.content = messageFB.content}
      if messageCached.created != messageFB.created { messageCached.created = messageFB.created}
      if messageCached.senderID != messageFB.senderID { messageCached.senderID = messageFB.senderID}
      if messageCached.senderName != messageFB.senderName { messageCached.senderName = messageFB.senderName }
    } else {
      if let parentChannel = fetchChannelByIdentifier(identifier: parentChannelIdentifier){
        let messageNew = Message(context: backgroundContext)
        messageNew.channel = parentChannel
        messageNew.content = messageFB.content
        messageNew.created = messageFB.created
        messageNew.senderID = messageFB.senderID
        messageNew.senderName = messageFB.senderName
        messageNew.identifier = messageId
      } else {
        print("ERROR fetching Channel by Identifier. New message not cached")
        return
      }
    }

    saveBackgroundContext(successCompletion: success, failCompletion: failure)
  }
  
  func fetchMessageByIdentifier(identifier: String) -> Message?{
    let context = backgroundContext
    let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
    do {
      let channel = try context.fetch(fetchRequest)
      return channel.first
    } catch {
      fatalError("Failed to fetch Channel by id:\(identifier). Error: \(error)")
    }
  }

}
