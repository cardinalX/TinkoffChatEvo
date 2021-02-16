//
//  User+CoreDataProperties.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 29.03.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var info: String?
    @NSManaged public var name: String?

}
