//
//  ChannelViewController.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 09.04.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChannelViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var contentTextView: UITextView!
  
  var channelReference: DocumentReference?
  var docIdentifier: String = ""
  private var messages: [Message] = []
  private var messagesCellModels: [MessageViewCell.MessageCellModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.navigationBar.prefersLargeTitles = false
    view.backgroundColor = UIColor(named: "TinkoffColor")
    navigationController?.navigationBar.barTintColor = UIColor(named: "TinkoffColor")
    navigationController?.navigationBar.backgroundColor = UIColor(named: "TinkoffColor")
    
    tableView.register(UINib(nibName: String(describing: MessageViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: MessageViewCell.self))
    tableView.dataSource = self
    tableView.delegate = self
    tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 100
    
    tableView.setContentOffset(.zero, animated: true)
    
    let firebaseManager = FirebaseManager()
    firebaseManager.updateMessages(documentID: docIdentifier){ models in
      self.messages = models
      
      self.messagesCellModels = self.messagesToMessagesCellModels(messages: models)
      
      self.tableView.reloadData()
    }
    
    let submitByOtherButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    submitByOtherButton.backgroundColor = .green
    submitByOtherButton.setTitle("X", for: .normal)
    submitByOtherButton.addTarget(self, action: #selector(submitByOtherButtonAction), for: .touchUpInside)
    
    self.view.addSubview(submitByOtherButton)
  }
  
  func messagesToMessagesCellModels(messages: [Message]) -> [MessageViewCell.MessageCellModel]{
    let messageCellModels = messages.map { (message) -> MessageViewCell.MessageCellModel in
      if let model = MessageViewCell.MessageCellModel(message: message) {
        return model
      } else {
        fatalError("Unable to initialize type \(MessageViewCell.MessageCellModel.self) with object \(message)")
      }
    }
    return messageCellModels
  }
  
  @IBAction func edgeSwipeBack(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
  
  ///method and button only for testing
  @objc func submitByOtherButtonAction(sender: UIButton!) {
    print("submitByOtherButtonAction")
    guard let content = contentTextView.text else { return }
    if (content == "") { return }
    
    let newMessage = Message(content: content,
                             created: Date(),
                             senderId: UIDevice.current.identifierForVendor!.uuidString + "1df2s",
                             senderName: "Чужой")
    let firebaseManager = FirebaseManager()
    firebaseManager.addMessage(documentID: docIdentifier, message: newMessage)
    NSLog("Message '\(content)' created by StorageManager.instance.getFirstUserManagedObject()?.name")
  }
  
  @IBAction func submitMessageButtonTapped(_ sender: Any) {
    guard let content = contentTextView.text else { return }
    if (content == "") { return }
    
    let newMessage = Message(content: content,
                             created: Date(),
                             senderId: UIDevice.current.identifierForVendor!.uuidString,
                             senderName: StorageManager().userName)
    let firebaseManager = FirebaseManager()
    firebaseManager.addMessage(documentID: docIdentifier, message: newMessage)
    NSLog("Message '\(content)' created by StorageManager.instance.getFirstUserManagedObject()?.name")
  }
}

// MARK: - Extension UITableViewDataSource

extension ChannelViewController: UITableViewDataSource{
  
  // MARK: Configurate Cell
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = String(describing: MessageViewCell.self)
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MessageViewCell
      else { return UITableViewCell() }
    
    cell.configure(with: messagesCellModels[indexPath.row])
    cell.transform = CGAffineTransform(scaleX: 1, y: -1)
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messagesCellModels.count
  }
  
}

// MARK: - Extension UITableViewDelegate

extension ChannelViewController: UITableViewDelegate{
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
