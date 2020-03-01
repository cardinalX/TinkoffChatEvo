//
//  MessageViewCell.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 01.03.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit

class MessageViewCell: UITableViewCell {
    /*
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    */
    
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var outgoingMessageLabel: UILabel!
    @IBOutlet weak var leftBubbleView: UIView!
    @IBOutlet weak var rightBubbleView: UIView!
    
    struct MessageCellModel {
        let text: String
        let isSender: Bool
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //addSubview(textBubbleView)
        //addSubview(messageTextView)
        
        
        /*addConstraintsWithFormat("H:|-8-[v0(30)]", views: profileImageView)
        addConstraintsWithFormat("V:[v0(30)]|", views: profileImageView)*/
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
        if(model.isSender){
            leftBubbleView.isHidden = true
            rightBubbleView.isHidden = false
            outgoingMessageLabel.text = model.text
            rightBubbleView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            rightBubbleView.layer.cornerRadius = 15
            rightBubbleView.layer.masksToBounds = false
        }
        else {
            leftBubbleView.isHidden = false
            rightBubbleView.isHidden = true
            messageLabel.text = model.text
            leftBubbleView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            leftBubbleView.layer.cornerRadius = 15
            leftBubbleView.layer.masksToBounds = false
        }
        
        
    }
}
