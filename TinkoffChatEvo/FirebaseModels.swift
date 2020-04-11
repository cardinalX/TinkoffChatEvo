//
//  FirebaseModels.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 04.04.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Channel {
  let lastActivity: Date
  let lastMessage: String
  let identifier: String
  let name: String
  
  var toDict: [String: Any] {
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
    
    self.init(lastActivity: lastActivity.dateValue(), lastMessage: lastMessage, identifier: identifier, name: name)
  }

}

struct Message {
  let content: String
  let created: Date
  let senderID: String
  let senderName: String
  
  var toDict: [String: Any] {
    return [
      "content": content,
      "created": Timestamp(date: created),
      "senderID": senderID,
      "senderName": senderName,
    ]
  }
}

extension Message {

  init?(dictionary: [String : Any]) {
    let content = dictionary["content"] as? String ?? "No messages yet"
    var senderID = dictionary["senderID"] as? String ?? "mudakID"
    let senderName = dictionary["senderName"] as? String ?? "Noname^$"
    let created = dictionary["created"] as? Timestamp ?? Timestamp(date: Date(timeIntervalSince1970: 0))
    //guard let created = dictionary["created"] as? Timestamp else { return nil }
    
    // чтобы не падало, на случай когда кто-нибудь криво записал новый словарь
    if (dictionary.keys.contains("senderId")) {
      senderID = dictionary["senderId"] as? String ?? "mudakID"
    }
    
    self.init(content: content, created: created.dateValue(), senderID: senderID, senderName: senderName)
  }

}
