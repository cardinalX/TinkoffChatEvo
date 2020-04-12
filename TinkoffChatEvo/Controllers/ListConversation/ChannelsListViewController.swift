//
//  ConversationsListViewController.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 28.02.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreData

class ChannelsListViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  private var channelsFB: [ChannelFB] = []
  private var documents: [QueryDocumentSnapshot] = []
  
  fileprivate let storageManager = StorageManager()
  
  fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Channel> = {
    // Initialize Fetch Request
    let fetchRequest: NSFetchRequest<Channel> = Channel.fetchRequest()
    
    // Add Sort Descriptors
    let sortDescriptors = [NSSortDescriptor(key: "lastActivity", ascending: false), NSSortDescriptor(key: "name", ascending: true)]
    //let sortDescriptors = [NSSortDescriptor(key: "isOnline", ascending: true)]
    fetchRequest.sortDescriptors = sortDescriptors
    
    // Initialize Fetched Results Controller
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.storageManager.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: "conversationsList")
    //let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.storageManager.persistentContainer.viewContext, sectionNameKeyPath: "isOnline", cacheName: "conversationsList")
    
    return fetchedResultsController
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Tinkoff Chat"
    self.navigationController?.navigationBar.prefersLargeTitles = true
    view.backgroundColor = UIColor(named: "TinkoffColor")
    navigationController?.navigationBar.barTintColor = UIColor(named: "TinkoffColor")
    navigationController?.navigationBar.backgroundColor = UIColor(named: "TinkoffColor")
    
    if #available(iOS 13.0, *) {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"), style: .plain, target: self, action: #selector(userProfileTapped(sender:)))
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.bubble.fill"), style: .plain, target: self, action: #selector(addChannelTapped(sender:)))
    } else {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(userProfileTapped(sender:)))
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addChannelTapped(sender:)))
    }
    
    tableView.register(UINib(nibName: String(describing: ConversationCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: ConversationCell.self))
    tableView.dataSource = self
    tableView.delegate = self
    //fetchedResultsController.delegate = self
    
    do {
        try fetchedResultsController.performFetch()
    } catch {
        let fetchError = error as NSError
        print("Unable to perform Fetch Channels")
        print("\(fetchError), \(fetchError.localizedDescription)")
    }

    print("========CACHE=======")
    if let fetchedObjects = fetchedResultsController.fetchedObjects {
      for cached in fetchedObjects {
        print(cached)
        channelsFB.append(ChannelFB(lastActivity: cached.lastActivity,
                                    lastMessage: cached.lastMessage,
                                    identifier: cached.identifier,
                                    name: cached.name))
      }
      splitedChannelsFB = splitToTableSections(from: channelsFB)
    }
    print("========CACHE=======")
    
    let firebaseManager = FirebaseManager()
    firebaseManager.updateChannels(){ models, documents in
      self.channelsFB = models
      self.documents = documents
      
      self.splitedChannelsFB = self.splitToTableSections(from: self.channelsFB)
      
      for channel in models {
        print(channel)
      }
      for i in documents {
        print(i.data())
        print(i.documentID)
      }
      print(documents)
      self.tableView.reloadData()
      
      //let storageManager = StorageManager()
      for channelFB in models {
        self.storageManager.saveChannel(channelFB: channelFB, successCompletion: {print("\(channelFB) cached successful")}, failCompletion: { error in print("ERROR caching channel. Reason: \(error)")})
      }
    }
 
  }
  
  @objc func userProfileTapped(sender: AnyObject) {
    print("userProfileTapped")
    
    let storyBoard = UIStoryboard(name: "ProfileViewController", bundle: nil)
    guard let profileViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
      else { print("Error when unwrapping VC withIdentifier ProfileViewController"); return}
    
    self.present(profileViewController, animated: true, completion: nil)
  }
  
  @objc func addChannelTapped(sender: AnyObject) {
    print("addChannelTapped")
    
    let alertCtrl = UIAlertController(title: "Введите название канала", message: nil, preferredStyle: .alert)
    alertCtrl.addTextField()

    let submitAction = UIAlertAction(title: "Добавить", style: .default) { [weak alertCtrl] _ in
      guard let answer = alertCtrl?.textFields?[0].text else { return }
      if (answer == "") { return }
      
      let newChannel = ChannelFB(lastActivity: Date(), lastMessage: "Channel created", identifier: UUID().uuidString, name: answer)
      let firebaseManager = FirebaseManager()
      firebaseManager.addChannel(channel: newChannel)
      NSLog("Channel '\(answer)' created")
    }
    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) {
        UIAlertAction in
        NSLog("Cancel Pressed")
    }

    alertCtrl.addAction(submitAction)
    alertCtrl.addAction(cancelAction)
    present(alertCtrl, animated: true)
    
  }
  
  // MARK: - DATA
  
  // Data variable to track our Splited data
  enum TableSection: Int {
    case online = 0, history, total
  }
  var splitedChannelsFB = [TableSection: [ChannelFB]]()
  
  func splitToTableSections(from channels: [ChannelFB]) -> [TableSection: [ChannelFB]]{
    splitedChannelsFB[.online] = channels.filter({$0.lastActivity.timeIntervalSince(Date()) > -600})
    splitedChannelsFB[.history] = channels.filter({$0.lastActivity.timeIntervalSince(Date()) <= -600})
    return splitedChannelsFB
  }
}

// MARK: - protocol ConfigurableView
protocol ConfigurableView {
  associatedtype ConfigurationModel
  
  func configure(with model: ConfigurationModel)
}

// MARK: - UITableViewDataSource

extension ChannelsListViewController: UITableViewDataSource{
  
  // MARK: Configurate Cell
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = String(describing: ConversationCell.self)
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ConversationCell
      else { return UITableViewCell() }
    
    if  let tableSection = TableSection(rawValue: indexPath.section),
      let channelFB = splitedChannelsFB[tableSection]?[indexPath.row] {
      cell.configure(with: ConversationCell.ConfigurationModel(channel: channelFB))
    }
    /*
    // Fetch Note
    print("*****************OBJECT AT**************")
    //print(fetchedResultsController.fetchedObjects)
    let channel = fetchedResultsController.object(at: indexPath)
    print(channel)
    let cellModel = ConversationCell.ConversationCellModel(channel: channel)
    cell.configure(with: cellModel)
 */
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch TableSection(rawValue: section) {
    case .online:
      return "Online"
    default:
      return "History"
    }
  }
  
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return TableSection.total.rawValue
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     if let tableSection = TableSection(rawValue: section),
      let dataBySection = splitedChannelsFB[tableSection] {
      return dataBySection.count
    }
    return 0
    /*
    guard let sections = fetchedResultsController.sections else { return 0 }
    return sections[section].numberOfObjects
     */
  }
}

// MARK: - UITableViewDelegate

extension ChannelsListViewController: UITableViewDelegate{
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let channelViewController = ChannelViewController()

    if let tableSection = TableSection(rawValue: indexPath.section){
      
      channelViewController.title = splitedChannelsFB[tableSection]?[indexPath.row].name ?? "Название диалога"
      channelViewController.channelIdentifier = splitedChannelsFB[tableSection]?[indexPath.row].identifier ?? "noID"
    }
    
    navigationController?.pushViewController(channelViewController, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 74
  }
}

// MARK: - Fetched Results Controller Delegate

extension ChannelsListViewController: NSFetchedResultsControllerDelegate {
  
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
        let channel = fetchedResultsController.object(at: indexPath as IndexPath)
        let cellModel = ConversationCell.ConversationCellModel(channel: channel)
        guard let cell = tableView.cellForRow(at: indexPath as IndexPath) as? ConversationCell
          else { return }
        cell.configure(with: cellModel)
        
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
}

