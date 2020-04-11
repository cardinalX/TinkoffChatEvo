//
//  MessageViewCell.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 01.03.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit

class MessageViewCell: UITableViewCell {
  
  @IBOutlet weak var receivedMessageLabel: UILabel!
  @IBOutlet weak var sendedMessageLabel: UILabel!
  @IBOutlet weak var leftBubbleView: UIView!
  @IBOutlet weak var rightBubbleView: UIView!
  @IBOutlet weak var sendedLabelTime: UILabel!
  @IBOutlet weak var receivedLabelTime: UILabel!
  
  struct MessageCellModel {
    let content: String
    let isSender: Bool
    let created: Date
    
    init(content: String, isSender: Bool, created: Date) {
      self.content = content
      self.created = created
      self.isSender = isSender
    }
    
    init?(message: Message) {
      self.content = message.content
      self.created = message.created
      self.isSender = message.senderID == UIDevice.current.identifierForVendor!.uuidString
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
}

// MARK: - extension ConfigurableView
extension MessageViewCell: ConfigurableView{
  typealias ConfigurationModel = MessageCellModel
  
  func configure(with model: ConfigurationModel) {
    
    // TODO: скорее всего так довольно ресурсоемко, подумать еще
    let dateFormatter = DateFormatter()
    if Calendar.current.isDateInToday(model.created) {
      dateFormatter.dateFormat = "HH:mm"
    } else {
      dateFormatter.dateFormat = "dd MMM"
    }
    
    if model.isSender {
      leftBubbleView.isHidden = true
      rightBubbleView.isHidden = false
      sendedMessageLabel.text = model.content
      sendedLabelTime.text = dateFormatter.string(from: model.created)
      rightBubbleView.backgroundColor =  #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1) // #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
      rightBubbleView.layer.cornerRadius = 20
    } else {
      leftBubbleView.isHidden = false
      rightBubbleView.isHidden = true
      receivedMessageLabel.text = model.content
      receivedLabelTime.text = dateFormatter.string(from: model.created)
      leftBubbleView.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.8549019608, blue: 0.2431372549, alpha: 1)
      leftBubbleView.layer.cornerRadius = 20
    }
  }
}
