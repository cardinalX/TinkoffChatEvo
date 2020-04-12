//
//  Channel+CoreDataClass.swift
//  
//
//  Created by Макс Лебедев on 11.04.2020.
//
//

import Foundation
import CoreData

@objc(Channel)
public class Channel: NSManagedObject {
  public var isOnline: Bool {
    return self.lastActivity.timeIntervalSince(Date()) > -600
  }
}
