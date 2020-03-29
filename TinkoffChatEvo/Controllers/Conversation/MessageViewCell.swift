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
  
  struct MessageCellModel {
    let text: String
    let isSender: Bool
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}

// MARK: - extension ConfigurableView
extension MessageViewCell: ConfigurableView{
  typealias ConfigurationModel = MessageCellModel
  
  func configure(with model: ConfigurationModel) {
    if model.isSender {
      leftBubbleView.isHidden = true
      rightBubbleView.isHidden = false
      sendedMessageLabel.text = model.text
      rightBubbleView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
      rightBubbleView.layer.cornerRadius = 15
    } else {
      leftBubbleView.isHidden = false
      rightBubbleView.isHidden = true
      receivedMessageLabel.text = model.text
      leftBubbleView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
      leftBubbleView.layer.cornerRadius = 15
    }
  }
}
