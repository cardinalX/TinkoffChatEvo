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
  /*private lazy var messagesCollection: CollectionReference = {
    guard let channelIdentifier = channel?.identifier else { fatalError() }
    return db.collection("channels").document(channelIdentifier).collection("messages")
  }()*/
  
  func addChannel(channel: Channel) {
    channelsCollection.addDocument(data: channel.toDict)
  }
  
  func addMessage(channelRef: DocumentReference?, documentID: String, message: Message){
    //let localMessagesCollection = channelsCollection.document(documentID).collection("messages")
    let localMessagesCollection = channelRef?.collection("messages")
    localMessagesCollection?.addDocument(data: message.toDict)
  }
  
  func updateChannels(completion: @escaping ([Channel], [QueryDocumentSnapshot]) -> Void) {
    channelsCollection.order(by: "lastActivity", descending: true).addSnapshotListener { [weak self] snapshot, error in
      guard let snapshot = snapshot else {
        print("Error fetching snapshot results: \(error!)")
        return
      }
      
      let models = snapshot.documents.map { (document) -> Channel in
        if let model = Channel(dictionary: document.data()) {
          return model
        } else {
          fatalError("Unable to initialize type \(Channel.self) with dictionary \(document.data())")
        }
      }
      
      completion(models, snapshot.documents)
    }
  }
  
  func updateMessages(channelRef: DocumentReference?, documentID: String, completion: @escaping ([Message]) -> Void){
    //let localMessagesCollection = channelsCollection.document(documentID).collection("messages").order(by: "created", descending: true)
    let localMessagesCollection = channelRef?.collection("messages").order(by: "created", descending: true)
    localMessagesCollection?.addSnapshotListener { [weak self] snapshot, error in
      guard let snapshot = snapshot else {
        print("Error fetching snapshot results: \(error!)")
        return
      }
      
      print(snapshot.documents)
      let models = snapshot.documents.map { (document) -> Message in
        if let model = Message(dictionary: document.data()) {
          return model
        } else {
          fatalError("Unable to initialize type \(Message.self) with dictionary \(document.data())")
        }
      }
      
      completion(models)
    }
  }
}
