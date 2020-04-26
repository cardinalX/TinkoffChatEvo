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
  @IBOutlet weak var submitButton: UIButton!
  
  let longPressGestureRecognizer = UILongPressGestureRecognizer()
  var longPressGestureAnchorPoint: CGPoint?
  
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
    
    contentTextView.delegate = self
    submitButton.layer.cornerRadius = 15
    submitButton.backgroundColor = #colorLiteral(red: 0.2470588235, green: 0.2855573893, blue: 0.9409456253, alpha: 1)
    
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
    
    //self.view.addSubview(submitByOtherButton)
    
    longPressGestureRecognizer.addTarget(self, action: #selector(handleTapGesture(_:)))
    longPressGestureRecognizer.numberOfTouchesRequired = 1
    
    tableView.addGestureRecognizer(longPressGestureRecognizer)
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

  @objc func handleTapGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
    guard longPressGestureRecognizer === gestureRecognizer else { assert(false); return }
    
    longPressGestureAnchorPoint = gestureRecognizer.location(in: view.superview)
    print("longPressGestureAnchorPoint = \(longPressGestureAnchorPoint)")
    
    /*
     let imageView = UIImageView(image: #imageLiteral(resourceName: "emblem"))
    imageView.frame = CGRect(origin: tapGestureAnchorPoint!, size: CGSize(width: 35, height: 35))
    tableView.superview!.addSubview(imageView)
    */
    	/*
    let imageView = UIImageView(image: #imageLiteral(resourceName: "emblem"))
    let dimension = 25 + drand48() * 10
    imageView.frame = CGRect(origin: self.longPressGestureAnchorPoint!, size: CGSize(width: dimension, height: dimension))
    UIView.animate(withDuration: 0.3) {
      self.tableView.superview!.addSubview(imageView)
*/
    
    switch gestureRecognizer.state {
    case .began:
      let imageView = UIImageView(image: #imageLiteral(resourceName: "emblem"))
      let dimension = 25 + drand48() * 10
      imageView.frame = CGRect(origin: self.longPressGestureAnchorPoint!, size: CGSize(width: dimension, height: dimension))
      /*UIView.animate(withDuration: 0.3){
        self.tableView.superview!.addSubview(imageView)
      }*/
      UIView.animate(withDuration: 0.3,
                     delay: 0.2,
                     options: [.repeat, .autoreverse],
                     animations: {
                      self.tableView.superview!.addSubview(imageView)
      }, completion: nil)
    
    case .changed:
      longPressGestureAnchorPoint = gestureRecognizer.location(in: view.superview)
      guard let tapGestureAnchorPoint = longPressGestureAnchorPoint else { assert(false); return }
      
      let gesturePoint = gestureRecognizer.location(in: view)
      self.longPressGestureAnchorPoint = gesturePoint
      
    case .cancelled, .ended:
      longPressGestureAnchorPoint = nil
      
    case .failed, .possible:
      assert(longPressGestureAnchorPoint == nil)
      break
    @unknown default:
      fatalError("unknown gesture")
    }
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

// MARK: extension TextViewDelegate

extension ChannelViewController: UITextViewDelegate {
  
  func textViewDidChange(_ textView: UITextView) {
    guard let text = textView.text else {
      return
    }
    if (text.isEmpty) {
      UIView.animate(withDuration: 0.5) {
        self.submitButton.isEnabled = false
        self.submitButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
      }
    } else if(text.count >= 1 && !submitButton.isEnabled){
      UIView.animate(withDuration: 0.5) {
        self.submitButton.isEnabled = true
        self.submitButton.backgroundColor = #colorLiteral(red: 0.2454464734, green: 0.2855573893, blue: 0.9409456253, alpha: 1)
        self.submitButton.frame.size.height *= 0.85
        self.submitButton.frame.size.width *= 0.85
        //self.submitButton.layer.
        
        //self.submitButton.heightAnchor.constraint(equalTo: self.submitButton.heightAnchor, multiplier: 0.85).isActive = true
        //self.submitButton.widthAnchor.constraint(equalTo: self.submitButton.widthAnchor, multiplier: 0.85).isActive = true
        
        //self.submitButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //self.submitButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
      }
    }
  }
}
