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
  private lazy var reference = db.collection("channels")
  
  func updateChannels(completion: @escaping ([Channel], [QueryDocumentSnapshot]) -> Void){
    reference.addSnapshotListener { [weak self] snapshot, error in
      guard let snapshot = snapshot else {
        print("Error fetching snapshot results: \(error!)")
        return
      }
      print(snapshot.documents.description)
      for doc in snapshot.documents {
        print(doc.data())
      }
      print(snapshot.documents.count)
      
      let models = snapshot.documents.map { (document) -> Channel in
        if let model = Channel(dictionary: document.data()) {
          print("🎃Succesful \(model) with dictionary \(document.data())")
          return model
        } else {
          fatalError("Unable to initialize type \(Channel.self) with dictionary \(document.data())")
        }
      }
      
      completion(models, snapshot.documents)
      /*
      self.restaurants = models
      self.documents = snapshot.documents

      if self.documents.count > 0 {
        self.tableView.backgroundView = nil
      } else {
        self.tableView.backgroundView = self.backgroundView
      }

      self.tableView.reloadData()
       */
      
      /*let results = snapshot?.documents.map { (document) -> Channel in
        if let channel = Channel(identifier: document.documentID, name: document.data(), lastMessage: "") {
          return channel
        } else {
          fatalError("Unable to initialize type \(Channel.self) with dictionary \(document.data())")
        }
      }*/
      
    }
  }
}
