//
//  FirebaseModels.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 04.04.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import Foundation
import Firebase

struct Channel {
  let lastActivity: Date
  let lastMessage: String
  let identifier: String
  let name: String
  
  var dictionary: [String: Any] {
    return [
      "lastActivity": Timestamp(date: lastActivity),
      "lastMessage": lastMessage,
      "identifier": identifier,
      "name": name,
    ]
  }
}

extension Channel {

  init?(dictionary: [String : Any]) {
    let lastMessage = dictionary["lastMessage"] as? String ?? "No messages yet"
    let name = dictionary["name"] as? String ?? "Noname^$"
    let identifier = dictionary["identifier"] as? String ?? "NoID"
    let lastActivity = dictionary["lastActivity"] as? Timestamp ?? Timestamp(date: Date(timeIntervalSince1970: 0))
    
    //guard let lastActivity = dictionary["lastActivity"] as? Timestamp
    //  else { _ = Timestamp(date: Date(timeIntervalSince1970: 0)) }
    
    
    /*guard let lastMessage = dictionary["lastMessage"] as? String,
        let name = dictionary["name"] as? String,
        let identifier = dictionary["identifier"] as? String,
        let lastActivity = dictionary["lastActivity"] as? Timestamp else { return nil }*/
    
    self.init(lastActivity: lastActivity.dateValue(), lastMessage: lastMessage, identifier: identifier, name: name)
  }

}

struct Message {
  let content: String
  let created: Date
  let senderId: String
  let senderName: String
  
  var dictionary: [String: Any] {
    return [
      "content": content,
      "created": Timestamp(date: created),
      "senderId": senderId,
      "senderName": senderName,
    ]
  }
}

extension Message {

  init?(dictionary: [String : Any]) {
    guard let content = dictionary["userId"] as? String,
        let senderId = dictionary["senderId"] as? String,
        let senderName = dictionary["senderName"] as? String,
        let created = dictionary["created"] as? Timestamp else { return nil }
    
    self.init(content: content, created: created.dateValue(), senderId: senderId, senderName: senderName)
  }

}
