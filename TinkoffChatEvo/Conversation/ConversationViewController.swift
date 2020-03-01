//
//  ConversationViewController.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 01.03.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit

class ConversationViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.title = (@"Title")
        //view.backgroundColor = UIColor(named: "TinkoffColor")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = UIColor(named: "TinkoffColor")
        //self.navigationController?.navigationBar.
        
        tableView.register(UINib(nibName: String(describing: MessageViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: MessageViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        //view.layer.cornerRadius = 15
        //view.layer.masksToBounds = true

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setTitleController(dialog: String){
        title = dialog
    }

    // MARK: - Table view data source

    var messages = [MessageViewCell.MessageCellModel(text: "Привет, вот какой-нибудь набросоук текст последнего сообщения в диалоге Входящего", isSender: false),
                    MessageViewCell.MessageCellModel(text: "Привет, сообщение 01 исходящее", isSender: true),
                    MessageViewCell.MessageCellModel(text: "Привет, вот сообщение какое-нибудь сообщениеудь сообщение текст последнего сообщения в диалоге", isSender: true),
                    MessageViewCell.MessageCellModel(text: "Решение этих проблем кроется за созданием абстрактного интерфейса для представления. Таким образом, презентер будет работать только с этой абстракцией, а не самим представлением. Тесты станут простыми, а проблемы решенными.", isSender: false),
                    MessageViewCell.MessageCellModel(text: "Нельзя трактовать Активити как представление (view). Необходимо рассматривать его как слой отображения, а сам контроллер выносить в отдельный класс. А чтобы уменьшить код контроллеров представлений, можно разделить представления или определить субпредставления (subviews) с их собственными контроллерами. Реализация MVC паттерна таким образом, позволяет легко разбивать код на модули.", isSender: false),
                    MessageViewCell.MessageCellModel(text: "Здесь простой подход: легко тестировать, и еще легче представить элементы представления как параметры через интерфейс, а не функции.", isSender: true),
                    MessageViewCell.MessageCellModel(text: "Стоит отметить, что с точки зрения презентера — ничего не изменилось.", isSender: true),
                    MessageViewCell.MessageCellModel(text: "Если взять какой-либо элемент разметки, например кнопку, то можно сказать, что кнопка ничего не делает, кроме того, что производит какие-либо данные, в частности посылает сведения о том что она нажата или нет.", isSender: false),
                    MessageViewCell.MessageCellModel(text: "Заключение Все исходники можно найти здесь." , isSender: false),
                    MessageViewCell.MessageCellModel(text: "Пока " , isSender: true),
        
    ]
    
    // MARK: Configurate Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: MessageViewCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MessageViewCell
            else { return UITableViewCell() }
            
        cell.configure(with: messages[indexPath.row])
        return cell
    }

        
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
        
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
     

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
