//
//  FirebaseManager.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 04.04.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import Foundation
import Firebase

class FirebaseManager {
  private lazy var db = Firestore.firestore()
  private lazy var channelsCollection = db.collection("channels")
  /*var channelDocumentId: String?
  private lazy var messagesCollection: CollectionReference = {
    guard let channelIdentifier = channelDocumentId else { fatalError("no channelDocumentId") }
    return db.collection("channels").document(channelIdentifier).collection("messages")
  }()*/
  
  func addChannel(channel: ChannelFB) {
    channelsCollection.addDocument(data: channel.toDict)
  }
  
  func addMessage(documentID: String, message: MessageFB){
    let localMessagesCollection = channelsCollection.document(documentID).collection("messages")
    localMessagesCollection.addDocument(data: message.toDict)
  }
  
  func updateChannels(completion: @escaping ([ChannelFB], [QueryDocumentSnapshot]) -> Void) {
    channelsCollection.order(by: "lastActivity", descending: true).addSnapshotListener { [weak self] snapshot, error in
      guard let snapshot = snapshot else {
        print("Error fetching snapshot results: \(error!)")
        return
      }
      
      let models = snapshot.documents.map { (document) -> ChannelFB in
        var documentData = document.data()
        documentData["identifier"] = document.documentID
        if let model = ChannelFB(dictionary: documentData) {
          return model
        } else {
          fatalError("Unable to initialize type \(ChannelFB.self) with dictionary \(document.data())")
        }
      }
      
      completion(models, snapshot.documents)
    }
  }
  
  func updateMessages(documentID: String, completion: @escaping ([MessageFB]) -> Void){
    let localMessagesCollection = channelsCollection.document(documentID).collection("messages").order(by: "created", descending: true)
    localMessagesCollection.addSnapshotListener { [weak self] snapshot, error in
      guard let snapshot = snapshot else {
        print("Error fetching snapshot results: \(error!)")
        return
      }
      
      print(snapshot.documents)
      let models = snapshot.documents.map { (document) -> MessageFB in
        if let model = MessageFB(dictionary: document.data()) {
          return model
        } else {
          fatalError("Unable to initialize type \(MessageFB.self) with dictionary \(document.data())")
        }
      }
      
      completion(models)
    }
  }
}
