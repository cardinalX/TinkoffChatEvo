//
//  Channel+CoreDataProperties.swift
//  
//
//  Created by Макс Лебедев on 12.04.2020.
//
//

import Foundation
import CoreData


extension Channel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel")
    }

    @NSManaged public var identifier: String
    @NSManaged public var lastActivity: Date
    @NSManaged public var lastMessage: String
    @NSManaged public var name: String
    var isOnline: String? {
      return self.lastActivity.timeIntervalSince(Date()) > -600 ? "Online" : "History"
      //return self.lastActivity.timeIntervalSince(Date()) > -600
    }
    //@NSManaged public var isOnline: Bool
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for messages
extension Channel {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
