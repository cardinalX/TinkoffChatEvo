//
//  ConversationsListViewController.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 28.02.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit
import Firebase

class ConversationsListViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  private var channels: [Channel] = []
  private var documents: [QueryDocumentSnapshot] = []
  
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
    
    let firebaseManager = FirebaseManager()
    firebaseManager.updateChannels(){ models, documents in
      self.channels = models
      self.documents = documents
      
      let conversationCellModels = self.channelsToConversationCellModels(channels: models)
      
      for i in conversationCellModels{
        print(i)
      }
      self.splitedData = self.splitToTableSections(filter: conversationCellModels)

      self.tableView.reloadData()
    }
    print(channels)
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
    //addChannelTapped(sender)
  }
  
  // MARK: - DATA
  
  // Data variable to track our Splited data
  enum TableSection: Int {
    case online = 0, history, total
  }
  var splitedData = [TableSection: [ConversationCell.ConversationCellModel]]()
  
  func splitToTableSections(filter conversationCellModels: [ConversationCell.ConversationCellModel]) -> [TableSection: [ConversationCell.ConversationCellModel]]{
    splitedData[.history] = conversationCellModels.filter({$0.isOnline == false})
    splitedData[.online] = conversationCellModels.filter({$0.isOnline == true})
    return splitedData
  }
  
  func channelsToConversationCellModels(channels: [Channel]) -> [ConversationCell.ConversationCellModel]{
    let conversationCellModels = channels.map { (channel) -> ConversationCell.ConversationCellModel in
      if let model = ConversationCell.ConversationCellModel(channel: channel) {
        print("🎃Succesful \(model) with object channel \(channel)")
        return model
      } else {
        fatalError("Unable to initialize type \(ConversationCell.ConversationCellModel.self) with object \(channel)")
      }
    }
    return conversationCellModels
  }
}

// MARK: - protocol ConfigurableView
protocol ConfigurableView {
  associatedtype ConfigurationModel
  
  func configure(with model: ConfigurationModel)
}

// MARK: - Extension UITableViewDataSource

extension ConversationsListViewController: UITableViewDataSource{
  
  // MARK: Configurate Cell
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = String(describing: ConversationCell.self)
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ConversationCell
      else { return UITableViewCell() }
    
    if  let tableSection = TableSection(rawValue: indexPath.section),
      let dialog = splitedData[tableSection]?[indexPath.row] {
      cell.configure(with: dialog)
    }
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
      let dataBySection = splitedData[tableSection] {
      return dataBySection.count
    }
    return 0
  }
}

// MARK: - Extension UITableViewDelegate

extension ConversationsListViewController: UITableViewDelegate{
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let conversationViewController = ConversationViewController()
    
    if  let tableSection = TableSection(rawValue: indexPath.section){
      conversationViewController.title = splitedData[tableSection]?[indexPath.row].name ?? "Название диалога"
    }
    
    navigationController?.pushViewController(conversationViewController, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 74
  }
}
