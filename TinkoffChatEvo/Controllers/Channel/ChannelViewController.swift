//
//  ChannelViewController.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 09.04.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreData

class ChannelViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var contentTextView: UITextView!

  var channelIdentifier: String = "noID"
  private var messagesFB: [MessageFB] = []
  private var messagesCellModels: [MessageViewCell.MessageCellModel] = []
  
  fileprivate let storageManager = StorageManager()
  
  fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Message> = {
    
    // Initialize Fetch Request
    let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
    
    // Add Sort Descriptors
    let sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
    fetchRequest.sortDescriptors = sortDescriptors
    
    if let channel = storageManager.fetchChannelByIdentifier(identifier: channelIdentifier){
      fetchRequest.predicate = NSPredicate(format: "channel == %@", channel)
    } else { print("ERROR fetchingChannel By Identifier at init fetchedResultsController<Message>")}
    // Initialize Fetched Results Controller
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: storageManager.persistentContainer.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
    //"messageList\(channelIdentifier)"
    return fetchedResultsController
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.navigationBar.prefersLargeTitles = false
    view.backgroundColor = UIColor(named: "TinkoffColor")
    navigationController?.navigationBar.barTintColor = UIColor(named: "TinkoffColor")
    navigationController?.navigationBar.backgroundColor = UIColor(named: "TinkoffColor")
    
    tableView.register(UINib(nibName: String(describing: MessageViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: MessageViewCell.self))
    tableView.dataSource = self
    tableView.delegate = self
    fetchedResultsController.delegate = self
    tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 100
    
    tableView.setContentOffset(.zero, animated: true)
    
    do {
        try fetchedResultsController.performFetch()
    } catch {
        let fetchError = error as NSError
        print("Unable to perform Fetch Channels")
        print("\(fetchError), \(fetchError.localizedDescription)")
    }
    
    let firebaseManager = FirebaseManager()
    firebaseManager.updateMessages(documentID: channelIdentifier){ documents in
      
      for document in documents {
        if let model = MessageFB(dictionary: document.data()) {
          self.storageManager.saveMessage(messageFB: model,
                                          messageId: document.documentID,
                                          parentChannelIdentifier: self.channelIdentifier,
                                          successCompletion: {print("\(model) cached successful id: \(document.documentID)")},
                                          failCompletion: { error in print("ERROR caching message. Reason: \(error)")})
        } else {
          fatalError("Unable to initialize type \(MessageFB.self) with dictionary \(document.data())")
        }
      }
      do {
        try self.fetchedResultsController.performFetch()
      } catch {
          let fetchError = error as NSError
          print("Unable to perform Fetch Channels")
          print("\(fetchError), \(fetchError.localizedDescription)")
      }
      self.tableView.reloadData()
    }
    
    let submitByOtherButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    submitByOtherButton.backgroundColor = .green
    submitByOtherButton.setTitle("X", for: .normal)
    submitByOtherButton.addTarget(self, action: #selector(submitByOtherButtonAction), for: .touchUpInside)
    
    self.view.addSubview(submitByOtherButton)
  }
  
  func messagesToMessagesCellModels(messages: [MessageFB]) -> [MessageViewCell.MessageCellModel]{
    let messageCellModels = messages.map { (messageFB) -> MessageViewCell.MessageCellModel in
      if let model = MessageViewCell.MessageCellModel(messageFB: messageFB) {
        return model
      } else {
        fatalError("Unable to initialize type \(MessageViewCell.MessageCellModel.self) with object \(messageFB)")
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
    
    let newMessage = MessageFB(content: content,
                               created: Date(),
                               senderID: UIDevice.current.identifierForVendor!.uuidString + "1df2s",
                               senderName: "Чужой")
    let firebaseManager = FirebaseManager()
    firebaseManager.addMessage(documentID: channelIdentifier, message: newMessage)
    NSLog("Message '\(content)' created by \(UIDevice.current.identifierForVendor!.uuidString)1df2s")
  }
  
  @IBAction func submitMessageButtonTapped(_ sender: Any) {
    guard let content = contentTextView.text else { return }
    if (content == "") { return }
    
    let newMessage = MessageFB(content: content,
                               created: Date(),
                               senderID: UIDevice.current.identifierForVendor!.uuidString,
                               senderName: StorageManager().userName)
    let firebaseManager = FirebaseManager()
    firebaseManager.addMessage(documentID: channelIdentifier, message: newMessage)
    NSLog("Message '\(content)' created by \(StorageManager().userName)")
  }
}

// MARK: - Extension UITableViewDataSource

extension ChannelViewController: UITableViewDataSource{
  
  // MARK: Configurate Cell
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let identifier = String(describing: MessageViewCell.self)
    let message = fetchedResultsController.object(at: indexPath)
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MessageViewCell
      else { return UITableViewCell() }
    
    let cellModel = MessageViewCell.MessageCellModel(message: message)
    cell.configure(with: cellModel)
    cell.transform = CGAffineTransform(scaleX: 1, y: -1)
    
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sections = fetchedResultsController.sections else { return 0 }
    return sections[section].numberOfObjects
  }
  
}

// MARK: - Extension UITableViewDelegate

extension ChannelViewController: UITableViewDelegate{
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension ChannelViewController: NSFetchedResultsControllerDelegate {
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChange anObject: Any,
                  at indexPath: IndexPath?,
                  for type: NSFetchedResultsChangeType,
                  newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      if let indexPath = newIndexPath {
        tableView.insertRows(at: [(indexPath as IndexPath)], with: .automatic)
      }
    case .update:
      if let indexPath = indexPath {
        let message = fetchedResultsController.object(at: indexPath as IndexPath)
        let cellModel = MessageViewCell.MessageCellModel(message: message)
        guard let cell = tableView.cellForRow(at: indexPath as IndexPath) as? MessageViewCell
        else { return }
        cell.configure(with: cellModel)
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
      }
    case .move:
      if let indexPath = indexPath {
        tableView.deleteRows(at: [(indexPath as IndexPath)], with: .automatic)
      }
      if let newIndexPath = newIndexPath {
        tableView.insertRows(at: [(newIndexPath as IndexPath)], with: .automatic)
      }
    case .delete:
      if let indexPath = indexPath {
        tableView.deleteRows(at: [(indexPath as IndexPath)], with: .automatic)
      }
    @unknown default:
      print("@unknown default")
    }
  }
  
  /*
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }*/
  
}
