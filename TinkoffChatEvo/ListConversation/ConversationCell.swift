//
//  ConversationCell.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 29.02.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {

    @IBOutlet weak var dialogNameLabel: UILabel!
    @IBOutlet weak var textLastMessage: UILabel!
    @IBOutlet weak var dateLastMessage: UILabel!
    
    struct ConversationCellModel {
        let name: String
        let message: String?
        let date: Date
        let isOnline: Bool
        let hasUnreadMessages: Bool
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
// MARK: - extension ConfigurableView
extension ConversationCell: ConfigurableView{
    
    typealias ConfigurationModel = ConversationCellModel
    
    func configure(with model: ConfigurationModel) {
        dialogNameLabel.text = model.name
        textLastMessage.text = model.message ?? "No messages yet"
        if model.hasUnreadMessages {
            textLastMessage.font = UIFont.boldSystemFont(ofSize: 15.0)
        }
        if (model.message == nil){
            textLastMessage.font = UIFont(name: "GeezaPro", size: 15.0)
        }
        
        // TODO: скорее всего так довольно ресурсоемко, подумать еще
        let dateFormatter = DateFormatter()
        if Calendar.current.isDateInToday(model.date) {
            dateFormatter.dateFormat = "HH:mm"
        }
        else {dateFormatter.dateFormat = "dd MMM"}
        dateLastMessage.text = dateFormatter.string(from: model.date)
        
        if model.isOnline { backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9568627451, blue: 0.7254901961, alpha: 1) }
        else { backgroundColor = .white}
    }
}

